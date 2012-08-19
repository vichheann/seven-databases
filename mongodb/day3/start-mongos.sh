#!/bin/bash
sleep 3
mongos --configdb localhost:$2 --chunkSize 1 --port $1 
