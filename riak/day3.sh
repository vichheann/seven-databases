#!/bin/bash

riak_server=ubuntudev12:8091

function props() {
  curl -X PUT http://$riak_server/riak/animals -H "Content-type:application/json" \
       -d "{\"props\":$1}"
}

function validator_hook() {
  props '{"precommit":[{"name":"good_score"}]}'
}

# http://forums.pragprog.com/forums/202/topics/10529
# http://wiki.basho.com/Riak-Search---Indexing-and-Querying-Riak-KV-Data.html
function search_hook() {
  props '{"search":true,"precommit":[{"mod":"riak_search_kv_hook", "fun":"precommit"}]}'
}

function put_animals() {
  curl -X PUT http://$riak_server/riak/animals/dragon \
       -H "Content-type: application/json" \
       -d '{"nickname":"Dragon", "breed":"Briard", "score":1}'
  curl -X PUT http://$riak_server/riak/animals/ace \
       -H "Content-type: application/json" \
       -d '{"nickname":"The Wonder Dog", "breed":"German Shepherd", "score":3}'
  curl -X PUT http://$riak_server/riak/animals/rtt \
       -H "Content-type: application/json" \
       -d '{"nickname":"Rin Tin Tin", "breed":"German Shepherd", "score":4}'
}

function put_indexed_animal() {
  curl -X PUT http://$riak_server/riak/animals/blue \
       -H "Content-type: application/json" \
       -H "x-riak-index-mascot_bin: butler" \
       -H "x-riak-index-version_int: 2" \
       -d '{"nickname":"Blue II", "breed":"English Bulldog"}'
}

function put_indexed_score_animals() {
  curl -X PUT http://$riak_server/riak/animals/dragon \
       -H "Content-type: application/json" \
       -H "x-riak-index-score_int: 1" \
       -d '{"nickname":"Dragon", "breed":"Briard", "score":1}'
  curl -X PUT http://$riak_server/riak/animals/ace \
       -H "Content-type: application/json" \
       -H "x-riak-index-score_int: 3" \
       -d '{"nickname":"The Wonder Dog", "breed":"German Shepherd", "score":3}'
  curl -X PUT http://$riak_server/riak/animals/rtt \
       -H "Content-type: application/json" \
       -H "x-riak-index-score_int: 4" \
       -d '{"nickname":"Rin Tin Tin", "breed":"German Shepherd", "score":4}'
  curl -X PUT http://$riak_server/riak/animals/uggie \
       -H "Content-type: application/json" \
       -H "x-riak-index-score_int: 4" \
       -d '{"nickname":"Jack", "breed":"Jack Russell Terrier", "score":4}'
  curl -X PUT http://$riak_server/riak/animals/lassie \
       -H "Content-type: application/json" \
       -H "x-riak-index-score_int: 2" \
       -d '{"nickname":"Lassie", "breed":"Rough Collie", "score":2}'
}


case "$1" in
  validator)
    validator_hook
    curl -i -X PUT http://$riak_server/riak/animals/bruiser -H "Content-type:application/json" \
       -d '{"score":5}'
    ;;
  search)
    search_hook
    put_animals
    curl http://$riak_server/solr/animals/select?q=breed:Shepherd 
    echo
    # http://lists.basho.com/pipermail/riak-users_lists.basho.com/2012-July/008964.html
    curl "http://$riak_server/solr/animals/select?wt=json&q=nickname:Rin%20AND%20breed:Shepherd" | python -mjson.tool 
    ;;
  indexing)
    put_indexed_animal
    curl http://$riak_server/buckets/animals/index/mascot_bin/butler
    ;;
  indexing_score)
    put_indexed_score_animals
    # http://wiki.basho.com/Secondary-Indexes---Configuration-and-Examples.html
    echo "dogs with score between 1-2"
    curl http://$riak_server/buckets/animals/index/score_int/1/2
    echo
    echo "dogs with score between 3-4"
    curl http://$riak_server/buckets/animals/index/score_int/3/4
    ;;
  *)
    echo "Usage: day3.sh {validator|search|indexing|indexing_score}"
    ;;
esac

echo
