/*
Find:
1.
  http://docs.neo4j.org/chunked/stable/rest-api.html
2.
  http://jung.sourceforge.net/doc/api/index.html

*/

//load common.groovy

def path_to(Graph g, String name1, String name2) {
  from = g.V.filter{it.name==name1}.next()
  to = g.V.filter{it.name==name2}.next()
  (from.costars.loop(1){
    it.loops <4 & !it.object.equals(to)
  }.filter{it.equals(to)}.path().next()).name.grep{it};
}

path_to(g, 'Elvis Presley', 'Kevin Bacon')