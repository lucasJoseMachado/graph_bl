package org.neo4j.example.unmanagedextension;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.core.Context;

import org.neo4j.graphalgo.WeightedPath;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.tooling.GlobalGraphOperations;

public class Warm {
	GraphDatabaseService graphDb;

	public Warm(@Context GraphDatabaseService graphDb) {
		this.graphDb = graphDb;
	}
	
	@GET
    @Path("/warmup")
    public String warmUp() {
        Node start;
        for ( Node n : GlobalGraphOperations.at( graphDb ).getAllNodes() ) {
           n.getPropertyKeys();
           for ( Relationship relationship : n.getRelationships() ) {
              start = relationship.getStartNode();
           }
        }
        for ( Relationship r : GlobalGraphOperations.at( graphDb ).getAllRelationships() ) {
          r.getPropertyKeys();
          start = r.getStartNode();
        }
        return "Warmed up and ready to go!";
    }
}
