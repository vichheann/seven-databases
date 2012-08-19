#!/bin/bash
#!/bin/bash
mongod --replSet $2 --dbpath ./mongo$1 --port 2701$1 --rest --nojournal --oplogSize 20 --noprealloc
