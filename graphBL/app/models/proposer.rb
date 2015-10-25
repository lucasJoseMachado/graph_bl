class Proposer
  def self.execute options={}
    while Rails.cache.read("proposing") do sleep 15 end
    Rails.cache.fetch("propose") do
      Rails.cache.write("proposing", true)
      propose = simple_execute(options)
      Rails.cache.delete("proposing")
      propose
    end
  end

  def self.add_bike_lanes relations
    ids = relations.map{|relation| relation['id']}
    if ids.present?
      GraphDatabase.begin_transaction
        ids.each do |id|
          GraphDatabase.in_transaction "
            MATCH (a:Point)-[r:Car]->(b:Point) WHERE id(r) = #{id}
            WITH a as a, b as b, r as r
              MERGE (a)-[new_r:Bike]->(b)
              SET new_r = r, new_r.nova = 1
            WITH r as r
              DELETE r
          "
        end
      GraphDatabase.end_transaction
      Rails.cache.delete("propose")
    end
  end

  private
    def self.simple_execute options
      options[:clusters] ||= 2
      options[:scorer] ||= true
      options[:pairs_to_pick] ||= 20
      Cluster.execute(options[:clusters])
      Scorer.execute if options[:scorer]
      pairs = PairPicker.execute
      results = []
      pairs.each do |pair|
        pair['path'] = PathPlanner.execute(pair['origin']['id'], pair['destination']['id'])
        if pair['path'].present? && results.all? {|x| x['path'] != pair['path']}
          results << pair
          break if results.count > 49
        end
      end
      results
    end
end
