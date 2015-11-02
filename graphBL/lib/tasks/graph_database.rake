namespace :db do
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
      points = GraphDatabase.execute_query("MATCH (point:Point)-[r:Bike]-() return distinct id(point), point.lat, point.lon")
        .map{ |v| { id: v[0], lat: v[1], lon: v[2] } }
      GraphDatabase.begin_transaction
        points.each_with_index do |point, index|
          puts "point #{index}..." if index % 100 == 0
          begin
            ["Bike", "Car"].each { |relation_type| SpatialMisc.connect_through_proximity_points(point, relation_type) }
            SpatialMisc.delete_proximity_points(point)
          rescue => e
            logger.error e.message
            e.backtrace.each { |line| logger.error line }
          end
        end
      GraphDatabase.end_transaction
      #just cleaning
      GraphDatabase.execute_query "MATCH A-[R1:Bike]-B, A-[R2:Car]-B DELETE R2"
      GraphDatabase.execute_query "MATCH A-[R1:Bike]-B, A-[R2:Bike]-B WHERE id(R1) <> id(R2) DELETE R2"
      GraphDatabase.execute_query "MATCH A-[R1:Car]-B, A-[R2:Car]-B WHERE id(R1) <> id(R2) DELETE R2"
    end
    puts "Done in #{time.seconds} seconds"
  end

  task :clean => :environment do
    Rake::Task['neo4j:reset_yes_i_am_sure'].invoke
  end

  task :setup => :environment do
    %w(clean import turn_spatial unify_points).each do |command|
      puts "calling #{command}..."
      Rake::Task["db:#{command}"].invoke
    end
  end
end
