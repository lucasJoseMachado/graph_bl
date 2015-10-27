namespace :db do
  task :create_backup => :environment do
    system "rake neo4j:stop"
    system "rm -rf backups/"
    system "mkdir backups"
    system "cp -r neo4j/data backups/"
    system "rake neo4j:start"
  end

  task :restore_backup => :environment do
    system "rake neo4j:stop"
    system "rm -rf neo4j/data"
    system "cp -r backups/data neo4j/"
    system "rake neo4j:start"
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
      #just cleaning
      GraphDatabase.begin_transaction
        GraphDatabase.in_transaction "MATCH A-[R1:Bike]-B, A-[R2:Car]-B DELETE R2"
        GraphDatabase.in_transaction "MATCH A-[R1:Bike]-B, A-[R2:Bike]-B WHERE id(R1) <> id(R2) DELETE R2"
        GraphDatabase.in_transaction "MATCH A-[R1:Car]-B, A-[R2:Car]-B WHERE id(R1) <> id(R2) DELETE R2"
      GraphDatabase.end_transaction
    end
    puts "Done in #{time.seconds} seconds"
  end

  task :clean => :environment do
    Rake::Task['neo4j:reset_yes_i_am_sure'].invoke
  end

  task :setup => :environment do
    # unify_points
    %w(clean import turn_spatial).each do |command|
      puts "calling #{command}..."
      Rake::Task["db:#{command}"].invoke
    end
  end
end
