class PathPlanner
  def self.execute point_a, point_b
    GraphDatabase.api.bike_lane_proposal.from(point_a).to(point_b).get
  end
end
