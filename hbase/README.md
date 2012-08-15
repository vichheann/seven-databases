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

### Using EC2 on AWS

To avoid being charged to much by AWS, let's use the [Free Usage Tier Offer](https://aws.amazon.com/free/). We have to specify the image and hardware id in the `hbase.properties`

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

**UPDATE**

Woohoo, I made it! Here how I completed day 3

*  To fix the previous issue, Google is really my friend. My ISP DNS server was the guilty one, so I picked the famous 8.8.8.8 from Google as it is said [here](https://mail-archives.apache.org/mod_mbox/whirr-user/201204.mbox/%3CCAHZL8y_qQjBm6qeSSRAiL0ac1Lsb-hZ9Do8sW2j09GT3gD6oow@mail.gmail.com%3E).
*  Next, it seems that `whirr` default url to `zookeeper` tarball was [wrong](https://issues.apache.org/jira/browse/WHIRR-617). So add this to your `hbase.property` file:

         whirr.zookeeper.tarball.url=http://apache.osuosl.org/zookeeper/zookeeper-3.4.3/zookeeper-3.4.3.tar.gz



*  Now you can run `whirr` ... but it won't work. The generated setup script on each instance tries to install some package like `java` but sometime failed, depending on the machine & location. This is described [here](https://issues.apache.org/jira/browse/WHIRR-528).
But don't panic, and take a deep breath:
  *  Log in to each instance with `ssh` and

            sudo apt-get update
            sudo apt-get install openjdk-6-jdk

     I also have to create a symbolic link

            cd /usr/lib/jvm
            sudo ln -s java-6-openjdk-amd64 java-6-openjdk

  *  Recall 'sudo /tmp/setup-{user}.sh' and then on the master node

            sudo /tmp/configure-zookeeper_hadoop-namenode_hadoop-jobtracker_hbase-master/configure-zookeeper_hadoop-namenode_hadoop-jobtracker_hbase-master.sh

  * And on the `regionserver` nodes

            sudo /tmp/configure-hadoop-datanode_hadoop-tasktracker_hbase-regionserver/configure-hadoop-datanode_hadoop-tasktracker_hbase-regionserver.sh


* Check the servers status

        /usr/local/hbase/bin/hbase shell

    and call the `status` command. This should be ok on any nodes.

* if it's not working (and it might be), you can do that:

    * On the master node

            sudo service zookeeper start
            sudo -u hadoop /usr/local/hadoop/bin/hadoop-daemon.sh start namenode
            sudo -u hadoop /usr/local/hadoop/bin/hadoop-daemon.sh start jobtracker
            sudo -u hadoop /usr/local/hbase/bin/hbase-daemon.sh start master

   *  On a regionserver node

            sudo -u hadoop /usr/local/hadoop/bin/hadoop-daemon.sh start namenode
            sudo -u hadoop /usr/local/hadoop/bin/hadoop-daemon.sh start tasktracker
            sudo -u hadoop /usr/local/hbase/bin/hbase-daemon.sh start regionserver


I'm not sure you'll need to do all this but that's how I managed to setup a hbase cluster with EC2. Hope this help! Happy Clouding!

## TODO

*  [x] Retry to launch the cluster on AWS with a good version of 'whirr'
*  [] Use MapRed to import data

## License

Copyright (C) 2012 [@2h2n](https://twitter.com/2h2n/)

