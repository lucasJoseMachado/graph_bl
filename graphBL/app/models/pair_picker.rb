class PairPicker
  def self.execute
    pairs = GraphDatabase.execute_query("#{self.pair_select_query} LIMIT 200").flatten
    # pairs.uniq do |pair|
    #   [ pair['origin']['cluster_id'], pair['destination']['cluster_id'] ]
    # end
  end

  private
    def self.pair_select_query
      "MATCH (a)-[r:Bike]-(c:Point)
        WHERE a.score <> 0
          AND c.cluster_id = a.cluster_id
      WITH DISTINCT a as a
        MATCH (a)-[r:Car]-(c:Point)
        WHERE c.cluster_id <> a.cluster_id OR c.cluster IS NULL
      WITH DISTINCT a as a
        MATCH (b)-[r:Bike]-(c:Point)
          WHERE id(a) < id(b)
            AND b.score <> 0
            AND a.cluster_id < b.cluster_id
            AND c.cluster_id = b.cluster_id
      WITH DISTINCT a as a, b as b
        MATCH (b)-[r:Car]-(c:Point)
        WHERE c.cluster_id <> b.cluster_id OR c.cluster IS NULL
      WITH DISTINCT a as a, b as b
        RETURN {origin: {id: a.id, cluster_id: a.cluster_id, score: a.score}, destination: {id: b.id, cluster_id: b.cluster_id, score: b.score}}
        ORDER BY (a.score + b.score) DESC"
    end
end
