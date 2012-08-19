#!/bin/bash
mongo localhost:27020/test<<HERE
db.fs.chunks.ensureIndex({files_id: 1});
HERE

mongo localhost:27020/admin<<HERE
db.runCommand({ shardcollection : "test.fs.chunks", key : { files_id : 1 }})
HERE
