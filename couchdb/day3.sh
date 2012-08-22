# Find
#1.
#  https://wiki.apache.org/couchdb/Built-In_Reduce_Functions
#2.
#  https://wiki.apache.org/couchdb/HTTP_database_API#Changes
#3.
#  https://wiki.apache.org/couchdb/Replication
#4.
#  https://gist.github.com/832610

couchdb_server=ubuntudev12:5984

# 3
curl -X PUT "http://$couchdb_server/music/_design/misc" \
    -H "Content-type: application/json" \
    -d '{"language":"javascript","views": {"conflicts": {"map":"function(doc){(doc._conflicts||[]).forEach(function(rev){emit(rev, doc._id);}); }"}}}'