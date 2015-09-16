package org.neo4j.example.unmanagedextension;

import java.io.IOException;
import java.io.PrintStream;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;

import org.neo4j.example.unmanagedextension.AStar.relationsCustomTypes;
import org.neo4j.graphalgo.WeightedPath;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.graphdb.Transaction;

@Path("/service")
public class PathPlanner {
	GraphDatabaseService graphDb;	
	WeightedPath path = null;
	
	 public PathPlanner( @Context GraphDatabaseService graphDb ){
        this.graphDb = graphDb;
    }
	
	@GET
    @Path("/bike_lane_proposal/from/{from}/to/{to}")
    @Produces("application/json")
    public Response bikeLaneProposal(@PathParam("from") Long from, @PathParam("to") Long to) {
		Transaction tx = graphDb.beginTx();
		try{
			Node nodeA = graphDb.getNodeById(from);
			Node nodeB = graphDb.getNodeById(to);
//       Double bikePenality = 0.2;
//       do{
//    	   path = AStar.calculate(nodeA, nodeB, bikePenality);
//    	   if(path != null && foundNewBikeLane()) return getFormattedResponse();
//    	   bikePenality += 0.1;
//       } while(bikePenality <= 1.0);
//       return Response.noContent().build();
			tx.success();
	    } catch (Exception e) {
		    tx.failure();
	        System.err.println(e.getMessage());
	    } finally {
	      tx.finish();
	    }
		return Response.ok().entity( "oi" ).build();
	}
	
	private Boolean foundNewBikeLane(){
		for (Relationship relation : path.relationships()){
			if(relation.isType(relationsCustomTypes.Car)) return true;
		}
		return false;
	}
	
	private Response getFormattedResponse(){
		return Response.ok().entity( path.toString() ).build();
	}
       
//       Map<String, Object> astarMap = new HashMap<String, Object>();
//		astarMap.put("time", path.weight());
//		
//		List<Object> nodes = new ArrayList<Object>();
//		for ( Node node : path.nodes() )
//		    {
//			 Map<String, Object> nodeMap = new HashMap<String, Object>();
//      		 nodeMap.put("id", node.getId());
//      		 nodeMap.put("x", node.getProperty("x"));
//      		 nodeMap.put("y", node.getProperty("y"));
//		     nodes.add(nodeMap);
//           }
//		astarMap.put("nodes", nodes);
//		
//		List<Object> relationships = new ArrayList<Object>();
//		for ( Relationship relationship : path.relationships() )
//		    {
//       		 Map<String, Object> relMap = new HashMap<String, Object>();
//                relMap.put("id", relationship.getId());
//                relMap.put("rel_type", relationship.getType().name());
//                relMap.put("start_node", relationship.getStartNode().getId());
//                relMap.put("end_node", relationship.getEndNode().getId());
//                relMap.put("time", relationship.getProperty("time"));
//		         relationships.add(relMap);
//           }
//
//		astarMap.put("relationships", relationships);
//
//		ObjectMapper objectMapper = new ObjectMapper();
//       return Response.ok().entity(objectMapper.writeValueAsString(astarMap)).build();
}
