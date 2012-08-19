## Day3: clustering

Just read [this](http://docs.mongodb.org/manual/tutorial/convert-replica-set-to-replicated-shard-cluster/)
and for [GridFS](http://www.mongodb.org/display/DOCS/Choosing+a+Shard+Key#ChoosingaShardKey-GridFS).

I made some scripts to create the cluster and load cities.

1. ./setup.sh
2. screen -c screen.cfg
3. ./setup_replSet.sh # and wait a little before proceeding the next step
4. ./setup_shard_and_load.sh
5. ./setup_gridfs.sh

Check the setup

    mongo localhost:27020/test<<HERE
    db.stats();
    db.printShardingStatus();
    HERE

Then you can load `day3.js` and do some queries.

## License

Copyright (C) 2012 [@2h2n](https://twitter.com/2h2n/)

