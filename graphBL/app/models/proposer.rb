class Proposer
  def self.execute options={}
    options[:clusters] ||= 2
    options[:scorer] ||= true
    options[:pairs_to_pick] ||= 50
    Cluster.execute(options[:clusters])
    Scorer.execute if options[:scorer]
    PairPicker.execute
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
    end
  end
end
