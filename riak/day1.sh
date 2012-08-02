#!/bin/bash

riak_server=ubuntudev12:8091

function put_animal() {
  curl -v -X PUT "http://$riak_server/riak/animals/$1?returnbody=true" \
       -H "Content-type: application/json" \
       -d "$2"
}

function delete_animal() {
  curl -v -X DELETE "http://$riak_server/riak/animals/$1"
}

function get_animal() {
  curl -i "http://$riak_server/riak/animals/$1"
}

function put_animal_in_cage() {
  curl -v -X PUT "http://$riak_server/riak/cages/$1?returnbody=true" \
       -H "Content-type: application/json" \
       -H "Link: </riak/animals/$3>;riaktag=\"contains\"" \
       -d "$2"
}

function delete_all() {
  delete_animal 'ace'
  delete_animal 'polly'
  delete_cage '1'
  delete_cage '2'
}

function put_all() {
  put_animal 'ace' '{"nickname" : "The Wonder Dog", "breed" : "German Sheperd"}'
  put_animal 'polly' '{"nickname" : "Sweet Polly Purebred", "breed" : "Purebred"}'
}

function link_all() {
  put_animal_in_cage '1' '{"room" : 101}' 'polly'

# cant update metadata only
  curl -v -X PUT "http://$riak_server/riak/cages/2" \
       -H "Content-type: application/json" \
       -H "Link: </riak/animals/ace>;riaktag=\"contains\", </riak/cages/1>;riaktag=\"next_to\"" \
       -d "{"room" : 101}"
}

function delete_cage() {
  curl -v -X DELETE "http://$riak_server/riak/cages/$1"
}

function get_cage() {
  curl -i "http://$riak_server/riak/cages/$1"
}

function put_image() {
  curl -X PUT "http://$riak_server/riak/photos/polly.jpg" \
       -H "Content-type: image/jpeg" \
       -H "Link: </riak/animals/polly>;riaktag=\"photo\"" \
       --data-binary @polly.jpg
}

# 1
function update_polly() {
  polly=`curl http://$riak_server/riak/animals/polly`
  curl -i -X PUT "http://$riak_server/riak/animals/polly" \
       -H "Content-type: application/json" \
       -H "Link: </riak/photos/polly.jpg>;riaktag=\"photo\"" \
       -d "$polly"
}

# 2
function put_pdf() {
  curl -i -X POST "http://$riak_server/riak/pdf" \
       -H "Content-type: application/pdf" \
       --data-binary @AndyGross_BuildingBlocksForAmazonDynamoStyleDistributedSystems.pdf > put_pdf.out
  grep Location put_pdf.out
}

# 3
function put_medicine() {
  curl -i -X PUT "http://$riak_server/riak/medicines/antibiotics" \
       -H "Content-type: image/jpeg" \
       -H "Link: </riak/animals/ace>;riaktag=\"patient\"" \
       --data-binary @medicine.jpeg
}

case "$1" in
  delete)
    delete_all
    ;;
  put)
    put_all
    ;;
  animal)
    get_animal $2
    ;;
  cage)
    get_cage $2
    ;;
  link)
    link_all
    ;;
  image)
    put_image
    ;;
  update_polly)
    update_polly
    ;;
  put_pdf)
    put_pdf 
    ;;
  put_medicine)
    put_medicine 
    ;;
  *)
    echo "Usage: day1.sh {delete|put|animal|cage|link|image}"
    ;;
esac

echo
