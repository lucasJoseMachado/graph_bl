package org.neo4j.example.unmanagedextension;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;

import org.codehaus.jackson.map.ObjectMapper;
import org.neo4j.example.unmanagedextension.AStar.relationsCustomTypes;
import org.neo4j.graphalgo.WeightedPath;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.graphdb.Transaction;

@Path("/bike_lane_proposal")
public class PathPlanner {
	GraphDatabaseService graphDb;
	WeightedPath path = null;

	public PathPlanner(@Context GraphDatabaseService graphDb) {
		this.graphDb = graphDb;
	}

	@GET
	@Path("/from/{from}/to/{to}")
	@Produces("application/json")
	public Response bikeLaneProposal(@PathParam("from") Long from, @PathParam("to") Long to) {
		Response result = Response.noContent().build();
		Boolean founded = false;
		Transaction tx = graphDb.beginTx();
		try {
			Node nodeA = graphDb.getNodeById(from);
			Node nodeB = graphDb.getNodeById(to);
			Double bikePenality = 0.2;
			do {
				path = AStar.calculate(nodeA, nodeB, bikePenality);
				if (path != null && foundNewBikeLane()) founded = true;
				bikePenality += 0.1;
			} while (founded == false && bikePenality <= 1.0);
			if (path != null) result = getFormattedResponse();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			tx.finish();
		}
		return result;
	}

	private Boolean foundNewBikeLane() {
		for (Relationship relation : path.relationships()) {
			if (relation.isType(relationsCustomTypes.Car)) return true;
		}
		return false;
	}

	private Response getFormattedResponse() {
		Map<String, Object> astarMap = new HashMap<String, Object>();
		List<Object> relationships = new ArrayList<Object>();
		for (Relationship relationship : path.relationships()) {
			Map<String, Object> relation = new HashMap<String, Object>();
			relation.put("id", relationship.getId());
			relation.put("type", relationship.getType().name());
			relation.put("length", relationship.getProperty("length", new Double(0.0)));
			relation.put("geometry", relationship.getProperty("geometry", ""));
			relationships.add(relation);
		}
		astarMap.put("relationships", relationships);
		astarMap.put("total_length", path.weight());
		astarMap.put("is_new_bike_lane", foundNewBikeLane());
		ObjectMapper objectMapper = new ObjectMapper();
		try {
			return Response.ok().entity(objectMapper.writeValueAsString(astarMap)).build();
		} catch (Exception e) {
			e.printStackTrace();
			return Response.noContent().build();
		}
	}
}
