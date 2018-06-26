import org.apache.spark.graphx._
import org.apache.spark.rdd.RDD
import scala.util.hashing.MurmurHash3
import org.apache.spark.sql.SparkSession

object FlightGraph {
 def main(args: Array[String]) {

val spark = SparkSession.builder().appName("Spark SQL basic example").getOrCreate()
import spark.implicits._
val df_1 = spark.read.format("csv").option("header", "true").load("small.csv")
val flightsFromTo = df_1.select($"Origin",$"Dest")
val airportCodes = df_1.select($"Origin", $"Dest").flatMap(x => Iterable(x(0).toString, x(1).toString))
val airportVertices: RDD[(VertexId, String)] = airportCodes.rdd.distinct().map(x => (MurmurHash3.stringHash(x), x))
val fEdges : RDD[((VertexId, VertexId), Int)] = flightsFromTo.rdd.map(x =>((MurmurHash3.stringHash(x(0).toString),MurmurHash3.stringHash(x(1).toString)), 1))
val flightEdges = fEdges.reduceByKey(_+_).map(x => Edge(x._1._1, x._1._2,x._2))
val defaultAirport = ("Missing")
val graph = Graph(airportVertices, flightEdges, defaultAirport)
graph.persist()
graph.numVertices
graph.numEdges
graph.triplets.sortBy(_.attr, ascending=false).map(triplet =>"There were " + triplet.attr.toString + " flights from " + triplet.srcAttr + " to " + triplet.dstAttr + ".").take(10)
}

}
