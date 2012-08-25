Gremlin.defineStep('costars', [Vertex, Pipe], {
  _().sideEffect{start=it}.outE('ACTED_IN').inV.inE('ACTED_IN').outV.filter{!start.equals(it)}.dedup
  })

import com.tinkerpop.blueprints.pgm.impls.neo4j.Neo4jGraph
g = new Neo4jGraph("/home/vic/database/neo4j/data/graph.db")

bacon = g.V.filter{it.name=='Kevin Bacon'}.next()