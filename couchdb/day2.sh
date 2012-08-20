#!/bin/bash
# Find:
#   https://wiki.apache.org/couchdb/Introduction_to_CouchDB_views
#   https://wiki.apache.org/couchdb/HTTP_view_API#Querying_Options

couchdb_server=ubuntudev12:5984

function create_views() {
  curl -X PUT "http://$couchdb_server/music/_design/random" \
       -H "Content-type: application/json" \
       -d @views.json
}

function get_random() {
  random=`ruby -e "puts rand"`
  curl "http://$couchdb_server/music/_design/random/_view/$1?startkey=$random&limit=1"
}

case "$1" in
  create_views)
    create_views
    ;;
  delete_views)
    rev=`curl http://$couchdb_server/music/_design/random | python -mjson.tool | grep rev | awk '{print $2}' | sed 's/"\(.*\)",/\1/g'`
    curl -X DELETE "http://$couchdb_server/music/_design/random?rev=$rev"
    ;;
  artist|album|track|tag)
    get_random "$1"
    ;;
  *)
    echo "Usage: day2.sh {artist|album|track|tag|create_views|delete_views}"
    ;;
esac

echo
