import org.apache.spark.graphx._
import org.apache.spark.rdd.RDD
import scala.util.hashing.MurmurHash3
import org.apache.spark.sql.SparkSession
import org.apache.spark.SparkConf

object FlightGraph {
 def main(args: Array[String]) {

val conf = new SparkConf().setAppName("Spark SQL basic example").set("spark.cassandra.connection.host", args(1))

val spark = SparkSession.builder().config(conf).getOrCreate()
import spark.implicits._
val df_1 = spark.read.format("csv").option("header", "true").load("hdfs://"+args(0)+":9000/flights.csv")
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
graph.triplets.sortBy(_.attr, ascending=false).map(triplet =>"There were " + triplet.attr.toString + " flights from " + triplet.srcAttr + " to " + triplet.dstAttr + ".").take(10).foreach(println)
graph.triplets.sortBy(_.attr, ascending=false).take(10).foreach(println)
val topRoutes = graph.triplets.sortBy(_.attr, ascending=false).map(triplet=>(triplet.srcAttr, triplet.dstAttr, triplet.attr.toString)).toDF("source", "destination", "flights")
topRoutes.take(10).foreach(println)
topRoutes.write.format("org.apache.spark.sql.cassandra").options(Map("table"->"freqflights", "keyspace"->"test")).save()

//graph.inDegrees.join(airportVertices).sortBy(_._2._1, ascending=false).take(1).foreach(println)
//graph.outDegrees.join(airportVertices).sortBy(_._2._1, ascending=false).take(1).foreach(println)
//val ranks = graph.pageRank(0.0001).vertices
//val ranksAndAirports = ranks.join(airportVertices).sortBy(_._2._1, ascending=false).map(_._2._2)
//ranksAndAirports.take(10).foreach(println)

}

}
