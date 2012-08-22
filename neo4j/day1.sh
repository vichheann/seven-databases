#!/bin/bash

# Find
# 1.
#  The wiki has been shutdown, current docs is http://docs.neo4j.org/chunked/stable/
#
# 2.
#  https://github.com/tinkerpop/gremlin/wiki/Gremlin-Steps
# 3.
#  The Cypher shell is now called 'Neo4j Shell' and the REST API shell is called 'HTTP'.

# Use the REST API to run Cypher query.
# Besides using the webadmin Cypher shell, you can do
# bin/neo4j-shell -c "cypher 1.7 start n=node(*) return n"

neo4j_server=ubuntudev12:7474

# 1
function get_all_nodes() {
  curl -X POST "http://$neo4j_server/db/data/cypher" \
       -H "Content-type: application/json" \
       -d '{"query":"start n=node(*) return n"}'
}

# 2
function delete_all() {
  curl -X POST "http://$neo4j_server/db/data/ext/GremlinPlugin/graphdb/execute_script" \
       -H "Content-type: application/json" \
       -d '{"script":"g.clear()", "params":{}}'
}

# 3
function the_simpsons() {
  curl -X POST "http://$neo4j_server/db/data/ext/GremlinPlugin/graphdb/execute_script" \
       -H "Content-type: application/json" \
       -d @family.json
}

case "$1" in
  all_nodes)
    get_all_nodes | grep name
    ;;
  delete_all)
    delete_all
    ;;
  family)
    the_simpsons
    ;;
  * )
    ;;
esac
