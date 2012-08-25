import com.tinkerpop.blueprints.pgm.impls.neo4j.Neo4jGraph
import edu.uci.ics.jung.algorithms.shortestpath.DijkstraShortestPath
import org.apache.commons.collections15.Transformer

//g = new Neo4jGraph("/home/vic/database/neo4j/data/graph.db")

def find_path(g, name1, name2)  {
  w = new Transformer<Edge, Integer>() {
    public Integer transform(Edge link) {
      String type = link.getProperty("line_type")
      if ("METRO".equals(type)) return 1
      if ("TRAMWAY".equals(type)) return 2
      if ("RER".equals(type)) return 3
      if ("TRAIN".equals(type)) return 5
      if ("WALK".equals(type)) return 8
    }
  }

  dijk = new DijkstraShortestPath(new GraphJung(g), w)

  from = g.V.filter{it.name==name1}.next()
  to = g.V.filter{it.name==name2}.next()

  dijk.getPath(from, to).collect{
    e->"${e.outVertex.name} - [${e.getProperty("line")}] -> ${e.inVertex.name}"}
}

def get_line(g) {
  w = new Transformer<Edge, Integer>() {
    public Integer transform(Edge link) {
      ("M14".equals(link.getProperty("line"))) ? 0 : 1
    }
  };
  line_name = 'M14'

  term = g.V.terminus(line_name).next(2)

  from = term[0]
  to = term[1]

  println "Stations of line ${line_name}"
  println "==>${from.name}"

  dijk = new DijkstraShortestPath(new GraphJung(g), w)
  path = dijk.getPath(from, to).collect{e->e.inVertex.name}
}

Gremlin.defineStep('next_station', [Vertex, Pipe], { String line_name ->
  _().outE.filter{it.line==line_name}.inV
  })

Gremlin.defineStep('terminus', [Vertex, Pipe], { String line_name ->
  _().next_station(line_name).filter{it.next_station(line_name).count() == 1}
  })

//find_path(g, 'Louvre Rivoli', 'Trocadero')