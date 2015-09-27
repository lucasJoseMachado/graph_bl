class PairPicker
  def self.execute
    GraphDatabase.execute_query("
      MATCH (a)-[r:Bike]-(c:Point)
        WHERE a.score <> 0
          AND c.cluster_id = a.cluster_id
      WITH DISTINCT a as a
        MATCH (a)-[r]-(c:Point)
        WHERE c.cluster_id <> a.cluster_id OR c.cluster IS NULL
      WITH DISTINCT a as a
        MATCH (b)-[r:Bike]-(c:Point)
          WHERE id(a) < id(b)
            AND b.score <> 0
            AND a.cluster_id <> b.cluster_id
            AND c.cluster_id = b.cluster_id
      WITH DISTINCT a as a, b as b
        MATCH (b)-[r]-(c:Point)
        WHERE c.cluster_id <> b.cluster_id OR c.cluster IS NULL
      WITH DISTINCT a as a, b as b
        RETURN {origin: {id: a.id, score: a.score}, destination: {id: b.id, score: b.score}}
        ORDER BY (a.score + b.score) DESC
        LIMIT 100")
    .flatten
  end
end
