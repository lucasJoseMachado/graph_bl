class ProposerController < ApplicationController
  def propose
    @proposal = Proposer.execute(params)
    render json: @proposal
  end

  def add_bike_lane
    if params[:path].present? && params[:path]['is_new_bike_lane']
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
    @pairs = PairPicker.execute(params[:pairs])
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
end
