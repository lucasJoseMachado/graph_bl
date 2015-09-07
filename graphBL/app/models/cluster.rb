class Cluster
  def self.execute min_clusters=0
    clusters = execute_girvan_newman_clusters(min_clusters)
    color_palette = Paleta::Palette.generate(:type => :random, :size => clusters.count)
    GraphDatabase.begin_transaction
    clusters.each_with_index do |cluster, index|
      GraphDatabase.in_transaction <<-EOF
        MATCH ( point:Point )
        WHERE id(point) in #{cluster.map{|value| value.to_i}}
        SET point.cluster_id = #{index}, point.cluster_color = '#{color_palette[index].hex}'
      EOF
    end
    GraphDatabase.end_transaction
    clusters
  end

  private
    def self.execute_girvan_newman_clusters min_clusters
      GraphDatabase.execute_script <<-EOF
          import edu.uci.ics.jung.algorithms.cluster.EdgeBetweennessClusterer;
          temp_graph = new TinkerGraph()
          g.V.both('Bike').unique().each { temp_graph.addVertex( it.id ) }
          g.E.has('label', 'Bike').each { temp_graph.addEdge(temp_graph.getVertex(it.inV.next().id), temp_graph.getVertex(it.outV.next().id), 'Bike') }
          if(#{min_clusters} < temp_graph.E.count()){
            graph_jung = new GraphJung(temp_graph)
            edges_to_remove = 0
            min_clusters = #{min_clusters}
            qt_clusters = -1
            clusters = []
            while(qt_clusters < min_clusters){
              algorithm_instace = new EdgeBetweennessClusterer(edges_to_remove++)
              clusters = algorithm_instace.transform(graph_jung)
              qt_clusters = clusters.size()
            }
            clusters_simplified = []
            clusters.each { temp_elem = []; it.each { temp_elem << it.id }; clusters_simplified << temp_elem }
            clusters_simplified
          }
        EOF
    end
end
