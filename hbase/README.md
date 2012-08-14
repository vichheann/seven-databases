# Seven-databases

Homework for "Seven databases in seven weeks" book. So this is the HBase week ...

## Install

Grab the binaries [here](https://www.apache.org/dyn/closer.cgi/hbase/).
Then edit `conf/hbase-site.xml` and set the property `hbase.rootdir`.

### Setup Compression

If you want to use other compression algorithm (`gz` is the only one available), you'll have to do more work.

#### LZO

Refer to the project web [site](http://www.oberhumer.com/opensource/lzo/) for more infos about this algorithm.

Then follow these instructions [here](https://github.com/toddlipcon/hadoop-lzo). You gonna build some stuff, so `apt-get install build-essential autoconf liblzo2-dev default-java ant` if not already done before.

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

Check out the project web [site](https://code.google.com/p/snappy/) which was created & currently used at Google.

Do `apt-get install snappy-dev` first, then

    cd $HBASE_HOME/lib/native/{os.arch}
    ln -s libsnappy.so /usr/lib/libsnappy.so

You will need the native library `libhadoop.so` available from the `hadoop-common` project [here](https://hadoop.apache.org/common/releases.html#Download).

Copy the lib in `$HBASE_HOME/lib/native/{os.arch}/` and add `org.apache.hadoop.io.compress.SnappyCodec` in the list of codecs in `$HBASE_HOME/conf/hbase-site.xml`

Check if it's all right:

    $HBASE_HOME/bin/hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile snappy

Happy compressing !

### Setup Thrift

Again, some compile & install work!

Find your way from [here](https://thrift.apache.org/docs/install/)

Before `make install`-ing `thrift` on my ubuntu, I had to install some ruby gems since I'm using `rvm`

    gem install mongrel --pre
    # --pre if using ruby 1.9. You must also have ruby with openssl
    gem instal rspec -v1.3.2

Easier on mac

    brew install thrift
    gem install thrift

### AWS

To avoid being charged to much by AWS, let's use the [Free Usage Tier Offer](https://aws.amazon.com/free/). I have to specify the image and hardware id in the `hbase.properties`

    # AWS free offer allows micro image only
    whirr.hardware-id=t1.micro
    # I choose Europe for me
    whirr.location-id=eu-west-1
    # Ubuntu 12.04 Precise 64 bits
    whirr.image-id=eu-west-1/ami-e901069d

You can find more ubuntu image-id [here](http://cloud-images.ubuntu.com/releases/).

### Whirr

Download [here](https://www.apache.org/dyn/closer.cgi/whirr/) or `brew install whirr`.

Then, I tried to launch the cluster. All was fine, I could see the instances on the EC2 Dashboard until `whirr` stopped with:

    Unable to start the cluster. Terminating all nodes.
    org.apache.whirr.net.DnsException: java.net.ConnectException: Connection refused
	    at org.apache.whirr.net.FastDnsResolver.apply(FastDnsResolver.java:83)
	    at org.apache.whirr.net.FastDnsResolver.apply(FastDnsResolver.java:40)
	    ....

So a little googling leads me to this [issue](https://issues.apache.org/jira/browse/WHIRR-459) which will be fixed in `whirr 0.72` ....


## TODO

*  [] Retry to launch the cluster on AWS with a good version of 'whirr'
*  [] Use MapRed to import data

## License

Copyright (C) 2012 [@2h2n](https://twitter.com/2h2n/)

