class PairPicker
  def self.execute pair_quantity
    GraphDatabase.execute_query("
      MATCH (a:Point)-[distance:Distance]->(b:Point)
      WHERE a.cluster_id <> b.cluster_id
      WITH a as point_a, b as point_b, distance as distance
      ORDER BY distance.value
      LIMIT #{pair_quantity}
        RETURN point_a, point_b, distance
        ORDER BY (point_a.score + point_b.score)/2")
    #TODO retirar após fazer o calculo das distancias
    GraphDatabase.execute_query("
      match (a:Point), (b:Point)
      where id(a) = 147 AND id(b) = 682
      return {origin: {id: a.id, score: a.score}, destination: {id: b.id, score: b.score}, distance: 1}
      limit 1")
    .flatten
  end
end
