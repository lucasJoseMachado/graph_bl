namespace :extension do
  task :compile => :environment do
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
