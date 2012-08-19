#!/bin/bash
mongo localhost:27020/admin<<HERE
db.runCommand( { addShard : "firstset/localhost:27011,localhost:27012,localhost:27013" } );
db.runCommand( { addShard : "secondset/localhost:27014,localhost:27015,localhost:27016" } )
HERE

mongo localhost:27020/admin<<HERE
db.runCommand( { enablesharding : "test" } );
db.runCommand( { shardcollection : "test.cities", key : {"name":1} })
HERE

mongoimport -h localhost:27020 -db test --collection cities --type json cities1000.json

mongo localhost:27020/test<<HERE
db.cities.ensureIndex({location:"2d"})
HERE
