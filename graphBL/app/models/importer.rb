class Importer
  def self.define_indexes
    GraphDatabase.execute_query "CREATE INDEX ON :Point(code)"
    GraphDatabase.execute_query "CREATE INDEX ON :Point(cluster_id)"
    GraphDatabase.execute_query "CREATE INDEX ON :Point(score)"
    GraphDatabase.execute_query "CREATE INDEX ON :Distance(value)"
  end

  def self.import_points
    print "points"
    points_queries = HashUtils.load_json_file('db/points.json').in_groups_of(1000, false) do |points_group|
      print "."
      points = []
      points_group.map do |point|
        node_id    = point["node_id"]
        descriptor = JSON.parse point["geom"]
        geometry   = descriptor["coordinates"]
        points << "(point_#{node_id}:Point{ code: #{node_id}, lat: #{geometry[0]}, lon: #{geometry[1]} })"
      end
      GraphDatabase.in_transaction "CREATE #{points.join(', ')}"
    end
    GraphDatabase.in_transaction "MATCH (point:Point) SET point.id = id(point)"
    puts ""
  end

  def self.import_tracks
    print "tracks"
    errors = []
    tracks_queries = HashUtils.load_json_file('db/tracks.json').each_with_index do |track, i|
      print "." if i % 1000 == 0
      edge_id    = track["edge_id"]
      start_node = track["start_node"]
      end_node   = track["end_node"]
      track_type = track["road_type"]
      length     = track["length"]*100000
      descriptor = JSON.parse track["geom"]
      geometry   = descriptor["coordinates"]
      if start_node == end_node
        print "F"
        errors << "IGNORED! TRACKS, Line #{i} - start_node == end_node"
      else
        begin
          GraphDatabase.in_transaction " \
            MATCH (point_1:Point), (point_2:Point) \
            WHERE point_1.code = #{start_node} \
              AND point_2.code = #{end_node} \
            CREATE (point_1)-[track:#{track_type.capitalize}{ \
              geometry: '#{geometry}', \
              length: #{ length || 0.0 } \
            }]->(point_2)"
        rescue Neography::NeographyError => err
          puts err.message     # Neo4j error message
          puts err.code        # HTTP error code
          puts err.stacktrace  # Neo4j Java stacktrace
          errors << "ERRO! TRACKS, Line #{i}"
        end
      end
    end
    GraphDatabase.in_transaction "MATCH A-[R1:Bike]-B, A-[R2:Car]-B DELETE R2" #just cleaning
    puts ""
    errors.each {|erro| puts erro} if errors.present?
  end
end
