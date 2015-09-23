class PairPicker
  def self.execute pair_quantity
    GraphDatabase.execute_query("
      MATCH (a:Point) WHERE a.score <> 0
      WITH a as a
        MATCH (a)-[r:Car]-(c)
      WITH DISTINCT a as a
        MATCH (b:Point) WHERE a.cluster_id <> b.cluster_id AND id(a) < id(b) AND b.score <> 0
      WITH a as point_a, b as point_b
        RETURN {origin: {id: point_a.id, score: point_a.score}, destination: {id: point_b.id, score: point_b.score}}
        ORDER BY (point_a.score + point_b.score)/2
        LIMIT #{pair_quantity}")
    .flatten
  end
end
