namespace :backup do
  task :create => :environment do
    system "rake neo4j:stop"
    system "rm -rf backups/"
    system "mkdir backups"
    system "cp -r neo4j/data backups/"
    system "rake neo4j:start"
  end

  task :restore => :environment do
    system "rake neo4j:stop"
    system "rm -rf neo4j/data"
    system "cp -r backups/data neo4j/"
    system "rake neo4j:start"
  end
end
