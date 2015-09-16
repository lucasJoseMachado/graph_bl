class ProposerController < ApplicationController
  respond_to :json

  def propose
    @proposal = Proposer.execute(params)
    respond_to @proposal
  end

  def clusterer
    @clusters = Cluster.execute params[:min_clusters]
    render nothing: true
  end

  def path
    @point_a = params[:point_a]
    @point_b = params[:point_b]
    @path = PathPlanner.execute @point_a, @point_b
    respond_with @path
  end

  def calculate_score
    Scorer.execute
    render nothing: true
  end

  def get_pairs
    @pairs = PairPicker.execute(params[:pairs] || 5)
    respond_with @pairs
  end
end
