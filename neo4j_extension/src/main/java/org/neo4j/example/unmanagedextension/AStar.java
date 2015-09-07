package org.neo4j.example.unmanagedextension;

import org.neo4j.graphalgo.CostEvaluator;
import org.neo4j.graphalgo.EstimateEvaluator;
import org.neo4j.graphalgo.GraphAlgoFactory;
import org.neo4j.graphalgo.PathFinder;
import org.neo4j.graphalgo.WeightedPath;
import org.neo4j.graphdb.Direction;
import org.neo4j.graphdb.Expander;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.graphdb.RelationshipType;
import org.neo4j.kernel.Traversal;

public class AStar {
	static enum relationsCustomTypes implements RelationshipType
	{
	    Bike, Car
	}
	
	static Expander pathTypes = Traversal.expanderForTypes(relationsCustomTypes.Bike, Direction.BOTH, relationsCustomTypes.Car, Direction.BOTH);
	
	static EstimateEvaluator<Double> estimateEvaluator = new EstimateEvaluator<Double>(){
        public Double getCost( final Node node, final Node goal )
        {
            double dx = (Double) node.getProperty( "lat" ) - (Double) goal.getProperty( "lat" );
            double dy = (Double) node.getProperty( "lon" ) - (Double) goal.getProperty( "lon" );
            return Math.sqrt( dx*dx + dy*dy );
        }
    };
    
    public static CostEvaluator<Double> getCostEvaluator(final Double bikePenality){
    	return new CostEvaluator<Double>() {		
	 	   public Double getCost(Relationship relationship, Direction direction) {
	 		   Double length = (Double) relationship.getProperty("length"); 
	 		   return relationship.isType(relationsCustomTypes.Bike) ? length*bikePenality : length;
	 	   }
	    };
    } 
    
    public static WeightedPath calculate(Node nodeA, Node nodeB, Double bikePenality){
    	PathFinder<WeightedPath> astar = GraphAlgoFactory.aStar(
     		   pathTypes,
     		   getCostEvaluator(bikePenality),
     		   estimateEvaluator );
        return astar.findSinglePath( nodeA, nodeB );
    }
}
