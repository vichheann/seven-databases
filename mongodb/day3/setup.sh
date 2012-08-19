#!/bin/bash
rm -fr mongo*
for i in {1..6}; # bash 3+
  do mkdir mongo$i;
done
mkdir mongocfg
