namespace :extension do
  task :compile_astar => :environment do
    Dir.chdir('../neo4j_extension'){
      system "mvn clean package"
    }
    Dir.chdir('../'){
      system "cp neo4j_extension/target/unmanaged-extension-template-1.0.jar graphBL/neo4j/plugins/"
    }
    system "rake neo4j:stop"
    system "rake neo4j:start"
  end
end

namespace :db do
  task :cache_distances => :environment do
    time = Benchmark.realtime do
      points = GraphDatabase.execute_query("MATCH (point:Point) return distinct id(point)")
        .map{|v| v[0]}
        .each_with_index do |point_id, index|
          GraphDatabase.begin_transaction
          puts "point #{index}..." if index % 100 == 0
          GraphDatabase.in_transaction <<-EOF
            MATCH (a:Point), (b:Point)
            WHERE id(a) = #{point_id}
              AND id(a) > id(b)
            CREATE (a)-[distance:Distance{
              value: SQRT( (a.lat-b.lat)*(a.lat-b.lat) + (a.lon-b.lon)*(a.lon-b.lon) )
            }]->(b)
          EOF
          GraphDatabase.end_transaction
      end
    end
    puts "Done in #{time.seconds} seconds"
  end

  task :import => :environment do
    time = Benchmark.realtime do
      GraphDatabase.begin_transaction
        Importer.define_indexes
        Importer.import_points
        Importer.import_tracks
      GraphDatabase.end_transaction
    end
    puts "Done in #{time.seconds} seconds"
  end

  task :turn_spatial => :environment do
    time = Benchmark.realtime { SpatialMisc.turn_spatial }
    puts "Done in #{time.seconds} seconds"
  end

  task :unify_points => :environment do
    time = Benchmark.realtime do
      points = GraphDatabase.execute_query("MATCH (point:Point) return distinct id(point), point.lat, point.lon")
        .map{ |v| { id: v[0], lat: v[1], lon: v[2] } }
      points.each_with_index do |point, index|
        puts "point #{index}..." if index % 1000 == 0
        begin
          ["Bike", "Car"].each { |relation_type| SpatialMisc.connect_through_proximity_points(point, relation_type) }
          SpatialMisc.delete_proximity_points(point)
        rescue
          print "F"
          next
        end
      end
    end
    puts "Done in #{time.seconds} seconds"
  end

  task :clean => :environment do
    Rake::Task['neo4j:reset_yes_i_am_sure'].invoke
  end

  task :setup => :environment do
    %w(clean import turn_spatial unify_points cache_distances).each do |command|
      puts "calling #{command}..."
      Rake::Task["db:#{command}"].invoke
    end
  end
end
