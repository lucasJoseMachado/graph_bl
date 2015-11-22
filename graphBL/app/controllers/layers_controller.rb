class LayersController < ApplicationController
  def planned
    @layer = ActiveRecord::Base.connection.select_all("
      SELECT st_asText(st_force2d((st_dump(geom)).geom)) as geometry, gid as id FROM ciclovias_planejadas
    ").to_hash
    render_layer
  end

  def existing
    @layer = ActiveRecord::Base.connection.select_all("
      SELECT st_asText(st_force2d((st_dump(geom)).geom)) as geometry, gid as id FROM ciclovias_existentes
    ").to_hash
    render_layer
  end

  def index
  end

  private
    def render_layer
      result = @layer.map do |it|
        geom = it["geometry"]
        geom.slice!("LINESTRING(")
        geom.slice!(")")
        geom = geom.split(",")
        geom.map!{|g| g.split(" ")}
        it["geometry"] = geom
        it
      end
      render json: result
    end
end
