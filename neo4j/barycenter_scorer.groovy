import edu.uci.ics.jung.algorithms.scoring.BarycenterScorer;
// load common.groovy
j = new GraphJung(g);
t = new EdgeLabelTransformer(['ACTED_IN'] as Set, false)

barycenter = new BarycenterScorer<Vertex,Edge>(j,t)

bacon_score = barycenter.getVertexScore(bacon)

connected = [:]
bacon.costars.each{
  score = barycenter.getVertexScore(it)
  if(score<bacon_score) connected[it] = score
}
connected.sort{a,b->a.value<=>b.value}.collect{k,v -> k.name + " => " + v }
