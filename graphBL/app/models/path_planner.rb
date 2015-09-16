class PathPlanner
  def self.execute point_a, point_b
    GraphDatabase.connection.get_extension("/example/bike_lane_proposal/from/#{point_a}/to/#{point_b}")
  end
end
