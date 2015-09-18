class LayersController < ApplicationController
  before_action :set_layer, only: [:car, :bike]

  def car
    render json: @layer
  end

  def bike
    render json: @layer
  end

  def point
    @layer = GraphDatabase.execute_query(
      <<-EOF
      MATCH (a:Point)-[r:Bike]-(c:Point)
      RETURN distinct id(a), [a.lat, a.lon], a.cluster_color
      EOF
    ).map{ |point| { geometry: point[1], cluster_color: point[2] } }.group_by{ |v| v[:cluster_color] }
    render json: @layer
  end

  def index
  end

  private
    def set_layer
      @layer = GraphDatabase.execute_query(
        <<-EOF
          MATCH (start:Point)-[track:#{params[:action].camelize}]->(end:Point)
          RETURN distinct id(track), track.geometry
        EOF
      ).map{ |track| { geometry: JSON.parse(track[1]) } }
    end
end
