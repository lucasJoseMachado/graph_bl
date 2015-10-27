class PathPlanner
  def self.execute point_a, point_b
    # path = GraphDatabase.connection.get_extension("/example/bike_lane_proposal/from/#{point_a}/to/#{point_b}")
    request = Net::HTTP.get(URI.parse("http://localhost:7474/example/bike_lane_proposal/from/#{point_a}/to/#{point_b}"))
    if request.present?
      path = JSON.parse(request)
    end
    path
  end

  def self.simple_path point_a, point_b
    path = GraphDatabase.execute_query("START source=node(#{point_a}), destination=node(#{point_b})
      MATCH p = shortestPath(source-[:Bike|:Car*]-destination)
      RETURN extract(n IN relationships(p)| {id: id(n), geometry: n.geometry})")
    path = path.flatten if path.present?
    {'relationships' => path}
  end
end
