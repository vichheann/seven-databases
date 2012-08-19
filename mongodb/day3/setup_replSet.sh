#!/bin/bash
# First set and shard
mongo localhost:27011/admin<<HERE
db.runCommand({"replSetInitiate" :
  {"_id" : "firstset", "members" : [{"_id" : 1, "host" : "localhost:27011"},
                                    {"_id" : 2, "host" : "localhost:27012"},
                                    {"_id" : 3, "host" : "localhost:27013"} ]}});
HERE


# Second set and shard
mongo localhost:27014/admin<<HERE
db.runCommand({"replSetInitiate" :
  {"_id" : "secondset", "members" : [{"_id" : 1, "host" : "localhost:27014"},
                                     {"_id" : 2, "host" : "localhost:27015"},
                                     {"_id" : 3, "host" : "localhost:27016"} ]}});
HERE

