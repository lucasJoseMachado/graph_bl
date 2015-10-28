class SpatialMisc
  def self.find_point_by_lat_lng point
    point['lon'] ||= point['lng']
    result = GraphDatabase.execute_query("
      START n=node:points('withinDistance:[#{point['lon']}, #{point['lat']}, 0.1]')
      RETURN n.id
      LIMIT 1")[0][0] rescue nil
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
    GraphDatabase.in_transaction "START proximity_point = node:points('withinDistance:[#{point[:lat]}, #{point[:lon]}, 0.012]') \
      WHERE id(proximity_point) <> #{point[:id]} \
      WITH proximity_point as proximity_point \
        MATCH (point:Point)
        WHERE id(point) = #{point[:id]}
      WITH point as point, proximity_point as proximity_point \
        MATCH (proximity_point)-[old_relation:#{relation_type}]-(related_node), \
        WHERE id(point) <> id(related_node) \
        CREATE (point)-[new_relation:#{relation_type}{geometry: old_relation.geometry}]->(related_node)"
  end

  def self.delete_proximity_points point
    GraphDatabase.in_transaction "START proximity_point = node:points('withinDistance:[#{point[:lat]}, #{point[:lon]}, 0.012]') \
      WHERE id(proximity_point) <> #{point[:id]} \
      WITH proximity_point as proximity_point \
        OPTIONAL MATCH (proximity_point)-[old_relation]-(related_node) \
        DELETE proximity_point, old_relation"
  end
end
