# Seven-databases

Homework for "Seven databases in seven weeks" book. So this is the postgresql week ...

## Install

Super easy on ubuntu

    sudo apt-get install postgresql

Check that `postgresql-contrib` is installed.

I couldn't find a client package with `homebrew` and since I don't want to install the server, I also try [pgAdmin](http://www.pgadmin.org/download/)

Modify configuration files `/etc/postgresql/9.1/main/pg_hba.conf` and `/etc/postgresql/9.1/main/postgresql.conf` to allow access from network if you use remote access.

Create the needed extensions for the book

    book=# create extension tablefunc;
    CREATE EXTENSION
    book=# create extension pg_trgm;
    CREATE EXTENSION
    book=# create extension dict_xsyn;
    CREATE EXTENSION
    book=# create extension fuzzystrmatch;
    CREATE EXTENSION

Check for instance with this command

    $ psql book -c "select '1'::cube;"
    cube
    ------
    (1)
    (1 row)

## License

Copyright (C) 2012 [@2h2n](https://twitter.com/2h2n/)

