#!/bin/bash
# Find:
#   https://wiki.apache.org/couchdb/HTTP_Document_API
#   https://wiki.apache.org/couchdb/Complete_HTTP_API_Reference

couchdb_server=ubuntudev12:5984

# 1
function put_document() {
  curl -v -X PUT "http://$couchdb_server/music/$1" \
       -H "Content-type: application/json" \
       -d "$2"
}

# 2
function create_database() {
  curl -v -X PUT "http://$couchdb_server/$1"
}

function delete_database() {
  curl -v -X DELETE "http://$couchdb_server/$1"
}

# 3
function get_document() {
  curl -v -X GET "http://$couchdb_server/$1"
}


case "$1" in
  put_new_doc)
    put_document 'the_rollingStones' \
    '{"name": "The Rolling Stones", "albums":[{"title":"Out of Our Heads", "year": 1965}, {"title":"Aftermath", "year": 1966}]}'
    ;;
  createdb)
    create_database "movies"
    ;;
  deletedb)
    delete_database "movies"
    ;;
  put_attached_doc)
    data = `echo "Brandon Flowers|Dave Keuning|Ronnie Vannucci, Jr.|Mark Stoermer" | base64`
    put_document 'the_kilers' \
    '{"name": "The Killers", "albums":[{"title":"Hot Fuss", "year": 2004}],"_attachments":{"members.txt": {"content_type": "text/plain","data":"QnJhbmRvbiBGbG93ZXJzfERhdmUgS2V1bmluZ3xSb25uaWUgVmFubnVjY2ksIEpyLnxNYXJrIFN0b2VybWVyCg=="}}}'
    ;;
  get_doc)
    get_document "music/the_kilers/members.txt"
    ;;
  *)
    echo "Usage: day1.sh {put_new_doc|createdb|deletedb|put_attached_doc|get_doc}"
    ;;
esac

echo
