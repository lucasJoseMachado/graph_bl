class PathPlanner
  def self.execute point_a, point_b
    # path = GraphDatabase.connection.get_extension("/example/bike_lane_proposal/from/#{point_a}/to/#{point_b}")
    request = Net::HTTP.get(URI.parse("http://localhost:7474/example/bike_lane_proposal/from/#{point_a}/to/#{point_b}"))
    if request.present?
      path = JSON.parse(request)
    end
    path
  end
end
