class Scorer
  def self.execute
    GraphDatabase.execute_script <<-EOF
      import edu.uci.ics.jung.algorithms.importance.BetweennessCentrality
      temp_graph = new TinkerGraph()
      g.V.both('Bike').unique().each { temp_graph.addVertex( it.id ) }
      g.E.has('label', 'Bike').each { temp_graph.addEdge(temp_graph.getVertex(it.inV.next().id), temp_graph.getVertex(it.outV.next().id), 'Bike') }
      scorer = new BetweennessCentrality(new GraphJung(temp_graph), true, false)
      scorer.setRemoveRankScoresOnFinalize(false)
      scorer.evaluate()
      g.V.both('Bike').unique().each { it.score = scorer.getVertexRankScore(it) }
    EOF
  end
end
