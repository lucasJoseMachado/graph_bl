class SpatialMisc
  def self.find_point_by_lat_lng point
    point = GraphDatabase.execute_query("
      START n=node:points('bbox:[#{point.lat}, #{point.lng}, #{point.lat}, #{point.lng}]')
      RETURN id(n)
      LIMIT 1
    ")[0]
  end

  def self.delete_intermediate_points
    # TODO deletar os pontos que estão apenas entre dois outros pontos, ou seja, pontos que não agregam ao modelo
  end

  def self.turn_spatial
    GraphDatabase.connection.add_point_layer("points")
    GraphDatabase.connection.create_spatial_index("points")
    GraphDatabase.execute_query("MATCH (point:Point) return distinct id(point)")
      .map{|v| v[0]}
      .compact
      .each_with_index do |point_id, index|
      puts "point #{index}..." if index % 1000 == 0
      GraphDatabase.connection.add_node_to_layer("points", GraphDatabase.connection.get_node(point_id))
    end
  end

  def self.connect_through_proximity_points point, relation_type
    GraphDatabase.in_transaction "START proximity_point = node:points('withinDistance:[#{point[:lat]}, #{point[:lon]}, 0.030]') \
      WHERE id(proximity_point) <> #{point[:id]} \
      WITH proximity_point as proximity_point \
        MATCH (proximity_point)-[old_relation:#{relation_type}]-(related_node), \
              (point:Point) \
        WHERE id(point) = #{point[:id]} \
          AND id(point) <> id(related_node) \
        CREATE (point)-[new_relation:#{relation_type}{geometry: old_relation.geometry}]->(related_node)"
  end

  def self.delete_proximity_points point
    GraphDatabase.in_transaction "START proximity_point = node:points('withinDistance:[#{point[:lat]}, #{point[:lon]}, 0.005]') \
      WHERE id(proximity_point) <> #{point[:id]} \
      WITH proximity_point as proximity_point \
        MATCH (proximity_point) \
        OPTIONAL MATCH (proximity_point)-[old_relation]-(related_node) \
        DELETE proximity_point, old_relation"
  end
end
