class AddExtensions < ActiveRecord::Migration
  def change
    execute "create extension postgis"
    execute "create extension postgis_topology"
  end
end
