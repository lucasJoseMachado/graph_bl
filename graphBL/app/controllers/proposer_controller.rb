class ProposerController < ApplicationController
  def propose
    @proposal = Proposer.execute(params)
    render json: @proposal
  end

  def add_bike_lane
    if params[:points].present?
      @point_a = SpatialMisc.find_point_by_lat_lng params[:points][0]
      @point_b = SpatialMisc.find_point_by_lat_lng params[:points][1]
      params[:path] = PathPlanner.execute @point_a, @point_b
    end
    if params[:path].present?
      Proposer.add_bike_lanes params[:path]['relationships']
    end
    render nothing: true
  end

  def path
    @point_a = params[:point_a]
    @point_b = params[:point_b]
    @path = PathPlanner.execute @point_a, @point_b
    render json: @path
  end

  def get_pairs
    @pairs = PairPicker.execute
    render json: @pairs
  end

  def clusterer
    @clusters = Cluster.execute params[:min_clusters]
    render nothing: true
  end

  def calculate_score
    Scorer.execute
    render nothing: true
  end

  def change_edge_type
    Edge.change_type(params[:edge])
    render nothing: true
  end
end
