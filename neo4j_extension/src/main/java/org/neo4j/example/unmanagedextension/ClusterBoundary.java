package org.neo4j.example.unmanagedextension;


import javax.ws.rs.core.Context;

import org.neo4j.gis.spatial.Layer;
import org.neo4j.gis.spatial.SpatialDatabaseService;
import org.neo4j.gis.spatial.rtree.SpatialIndexReader;
import org.neo4j.graphdb.GraphDatabaseService;

public class ClusterBoundary {
	GraphDatabaseService graphDb;
	SpatialDatabaseService spatialDb;

	public ClusterBoundary(@Context GraphDatabaseService graphDb) {
		this.graphDb = graphDb;
		this.spatialDb = new SpatialDatabaseService(graphDb);
	}
	
	public void execute(){
		Layer layer = spatialDb.getLayer("points");
		SpatialIndexReader spatialIndex = layer.getIndex();
		//TODO ver importação: https://github.com/neo4j-contrib/spatial - mvn dependency:copy-dependencies
	}
	
}
