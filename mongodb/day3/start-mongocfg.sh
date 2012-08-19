#!/bin/bash
mongod --configsvr  --dbpath ./mongocfg --port $1 --nojournal --oplogSize 20 --noprealloc --rest
