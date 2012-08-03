#!/bin/bash

riak_server=ubuntudev12:8091

function map() {

curl -X POST -H "content-type:application/json" http://$riak_server/mapred \
     --data \
'{
  "inputs": "rooms",
  "query": [
    {"map":{
      "language":"javascript",
      "source":
        "function(v) {
          var parsed_data = JSON.parse(v.values[0].data);
          var data = {};
          data[parsed_data.style] = parsed_data.capacity;
          return [data];
        }"
      }
    }
  ]
}'

}

function stored_function() {
    curl -X PUT -H "Content-type:application/json" http://$riak_server/riak/my_functions/map_capacity \
    --data \
    'function(v) {
       var parsed_data = JSON.parse(v.values[0].data);
       var data = {};
       data[parsed_data.style] = parsed_data.capacity;
       return [data];
    }'

#"inputs": [ ["rooms", "101"],["rooms", "102"],["rooms", "103"] ],

curl -X POST -H "content-type:application/json" http://$riak_server/mapred \
     --data \
'{
  "inputs":{
     "bucket":"rooms",
     "key_filters":[["string_to_int"], ["less_than", 1000]]
   },
  "query": [
    {"map":{
      "language":"javascript",
      "bucket":"my_functions",
      "key":"map_capacity"
      }
    }
  ]
}'
}

function built-in_function() {
  curl -X POST http://$riak_server/mapred -H "Content-type:application/json" \
       --data \
       '{
          "inputs": [ ["rooms", "101"],["rooms", "102"],["rooms", "103"] ],
          "query": [
            {"map":{
              "language":"javascript",
              "name":"Riak.mapValuesJson"
               }
             }
            ]
          }'
}

function mapreduce() {
   curl -X POST -H "Content-type:application/json" http://$riak_server/mapred \
        --data \
'{
  "inputs": [ ["rooms", "101"],["rooms", "102"],["rooms", "103"] ],
  "query": [
    {"map":{
      "language":"javascript",
      "bucket":"my_functions",
      "key":"map_capacity"
      }
    },
    {"reduce":{
      "language":"javascript",
      "source":
        "function(v) {
          var totals = {};
          for (var i in v) {
            for (var style in v[i]) {
              if (totals[style]) totals[style] += v[i][style];
              else totals[style] = v[i][style];
            }
          }
          return [totals];
        }"
      }
    }
  ]
}'
}

function walking_link() {
  curl -X POST -H "Content-type:application/json" http://$riak_server/mapred \
    --data \
'{
  "inputs":{
     "bucket":"cages",
     "key_filters":[["eq", "2"]]
   },
  "query": [
    {"link":{
      "bucket":"animals",
      "keep":false
      }
    },
    {"map":{
      "language":"javascript",
      "source":
        "function(v) {return [v];}"
      }
    }
  ]
}'
}

function _stored_function() {
    curl -X PUT -H "Content-type:application/json" http://$riak_server/riak/my_functions/map_capacity_by_floor \
    --data \
    'function(v) {
       var data = {};
       var parsed_data = JSON.parse(v.values[0].data);
       data[Math.floor(v.key/100)] = parsed_data.capacity;
       return [data];
     }'

    curl -X PUT -H "Content-type:application/json" http://$riak_server/riak/my_functions/reduce_capacity_by_floor \
    --data \
    'function(v) {
       var totals = {};
       for (var i in v) {
         for (var floor in v[i]) {
            if (totals[floor]) totals[floor] += v[i][floor];
            else totals[floor] = v[i][floor];
         }
       }
       return [totals];
     }'
}

# 1
function capacity_by_floor() {
   curl -X POST -H "Content-type:application/json" http://$riak_server/mapred \
        --data \
'{
  "inputs":"rooms",
  "query": [
    {"map":{
      "language":"javascript",
      "bucket":"my_functions",
      "key":"map_capacity_by_floor"
      }
    },
    {"reduce":{
      "language":"javascript",
      "bucket":"my_functions",
      "key":"reduce_capacity_by_floor"
      }
    }
  ]
}'
}

# 2
function capacity_by_floor_filtered() {
   curl -X POST -H "Content-type:application/json" http://$riak_server/mapred \
        --data \
'{
  "inputs":{
    "bucket":"rooms",
    "key_filters":[["string_to_int"], ["between", 4201, 4399]]
   },
  "query": [
    {"map":{
      "language":"javascript",
      "bucket":"my_functions",
      "key":"map_capacity_by_floor"
      }
    },
    {"reduce":{
      "language":"javascript",
      "bucket":"my_functions",
      "key":"reduce_capacity_by_floor"
      }
    }
  ]
}'
}

case "$1" in
  map_inline)
    map
    ;;
  stored_function)
    stored_function
    ;;
  built-in_function)
    built-in_function
    ;;
  mapreduce)
    mapreduce
    ;;
  walking_link)
    walking_link
    ;;
  capacity_by_floor)
    _stored_function;
    capacity_by_floor
    ;;
  capacity_by_floor_42_43)
    _stored_function;
    capacity_by_floor_filtered
    ;;
  *)
    echo "Usage: day2.sh {mapreduce_inline|stored_function|built-in_function|mapreduce|walking_link|capacity_by_floor|capacity_by_floor_42_43}"
    ;;
esac

echo
