class PairPicker
  def self.execute pair_quantity
    GraphDatabase.execute_query <<-EOF
      MATCH (a:Point)-[distance:Distance]->(b:Point)
      WHERE a.cluster_id <> b.cluster_id
      WITH a as point_a, b as point_b, distance as distance
      ORDER BY distance.value
      LIMIT #{pair_quantity}
        RETURN point_a, point_b, distance
        ORDER BY (point_a.score + point_b.score)/2
    EOF
  end
end
