class GraphDatabase
  @neo = Neography::Rest.new

  def self.connection
    @neo
  end

  def self.within_distance(layer, pointx, pointy, distance)
    connection.find_geometries_within_distance(layer, pointx, pointy, distance).map{ |node| node["data"] }
  end

  def self.execute_query query
    connection.execute_query(query)["data"]
  end

  def self.execute_script script
    connection.execute_script(script)
  end

  def self.begin_transaction
    @tx = connection.begin_transaction
  end

  def self.in_transaction query
    connection.in_transaction(@tx, query)
  end

  def self.end_transaction
    connection.commit_transaction(@tx)
  end

  # def self.post_to_neo4j url, params, ignore_response: false
  #   response = Net::HTTP.post_form(URI.parse("#{'http://localhost:7474/'}#{url}"), params)
  #   result = JSON.parse(response.body)["data"] unless ignore_response
  # end
end
