# Seven-databases

Homework for "Seven databases in seven weeks" book. So this is the HBase week ...

## Install

Grab the binaries [here](https://www.apache.org/dyn/closer.cgi/hbase/).
Then edit `conf/hbase-site.xml` and set the property `hbase.rootdir`.

### Setup Compression

If you want to use other compression algorithm (`gz` is the only one available), you'll have to do more work.

#### LZO

Refer to the project web [site](http://www.oberhumer.com/opensource/lzo/) for more infos about this algorithm.

Then follow these instructions [here](https://github.com/toddlipcon/hadoop-lzo). You gonna build some stuff, so `apt-get install build-essential autoconf liblzo2-dev default-java ant` if not already done.

When compiled, copy the jar in `$HBASE_HOME/lib/` and the native lib in `$HBASE_HOME/lib/native/{os.arch}/`

And add these properties in `$HBASE_HOME/conf/hbase-site.xml`

    <property>
      <name>io.compression.codecs</name>
      <value>org.apache.hadoop.io.compress.GzipCodec,org.apache.hadoop.io.compress.DefaultCodec,com.hadoop.compression.lzo.LzoCodec,com.hadoop.compression.lzo.LzopCodec,org.apache.hadoop.io.compress.BZip2Codec</value>
    </property>
    <property>
      <name>io.compression.codec.lzo.class</name>
      <value>com.hadoop.compression.lzo.LzoCodec</value>
    </property>

Check if it's all right:

    $HBASE_HOME/bin/hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile lzo

### Snappy

Check out the project web [site](https://code.google.com/p/snappy/) which was created & used at Google.

Do `apt-get install snappy-dev` first, then

    cd $HBASE_HOME/lib/native/{os.arch}
    ln -s libsnappy.so /usr/lib/libsnappy.so

You will need the native library `libhadoop.so` available from the `hadoop-common` project [here](https://hadoop.apache.org/common/releases.html#Download).

Copy the lib in `$HBASE_HOME/lib/native/{os.arch}/` and add `org.apache.hadoop.io.compress.SnappyCodec` in the list of codecs in `$HBASE_HOME/conf/hbase-site.xml`

Check if it's all right:

    $HBASE_HOME/bin/hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile snappy

Happy compressing !

## TODO

*  [] Use MapRed to import data

## License

Copyright (C) 2012 [@2h2n](https://twitter.com/2h2n/)

