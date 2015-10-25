class LayersController < ApplicationController
  before_action :set_layer, only: [:car, :bike]

  def car
    render json: @layer
  end

  def bike
    render json: @layer
  end

  def index
  end

  private
    def set_layer
      @layer = GraphDatabase.execute_query(
        <<-EOF
          MATCH (start:Point)-[track:#{params[:action].camelize}]->(end:Point)
          RETURN distinct id(track), track.geometry, CASE (start.cluster_color = end.cluster_color) WHEN true THEN start.cluster_color ELSE null END
        EOF
      ).map{ |track| { geometry: JSON.parse(track[1]), cluster_color: track[2], id: track[0] } }.group_by{ |v| v[:cluster_color] }
    end
end
