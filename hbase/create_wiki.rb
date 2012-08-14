require 'java'

import 'org.apache.hadoop.hbase.HConstants'
import 'org.apache.hadoop.hbase.HColumnDescriptor'
import 'org.apache.hadoop.hbase.HTableDescriptor'
import 'org.apache.hadoop.hbase.client.HBaseAdmin'
java_import 'org.apache.hadoop.hbase.io.hfile.Compression$Algorithm'
java_import 'org.apache.hadoop.hbase.regionserver.StoreFile$BloomType'


def drop_if_exists(admin, table_name)
  if (admin.tableExists(table_name))
    admin.disableTable(table_name)
    admin.deleteTable(table_name)
  end
end

admin = HBaseAdmin.new(@hbase.configuration)

table_name = 'wiki2'
drop_if_exists(admin, table_name)
wiki = HTableDescriptor.new(table_name)
text = HColumnDescriptor.new('text')
text.setCompressionType(Algorithm::GZ) 
text.setBloomFilterType(BloomType::ROW) 
text.setMaxVersions(HConstants::ALL_VERSIONS)
wiki.addFamily(text)

revision = HColumnDescriptor.new('revision')
revision.setMaxVersions(HConstants::ALL_VERSIONS)
wiki.addFamily(revision)

admin.createTable(wiki)

table_name = 'links2'
drop_if_exists(admin, table_name)
links = HTableDescriptor.new(table_name)
to = HColumnDescriptor.new('to')
to.setBloomFilterType(BloomType::ROWCOL)
to.setMaxVersions(1)
links.addFamily(to)

from = HColumnDescriptor.new('from')
from.setBloomFilterType(BloomType::ROWCOL)
from.setMaxVersions(1)
links.addFamily(from)

admin.createTable(links)

exit

=begin
create 'wiki',
      {NAME=>'text', COMPRESSION=>'GZ', BLOOMFILTER=>'ROW', VERSIONS=>org.apache.hadoop.hbase.HConstants::ALL_VERSIONS},
      {NAME=>'revision', VERSIONS=>org.apache.hadoop.hbase.HConstants::ALL_VERSIONS}

create 'links', {NAME=>'to', VERSIONS=>1, BLOOMFILTER=>'ROWCOL'},
                {NAME=>'from', VERSIONS=>1, BLOOMFILTER=>'ROWCOL'}
=end
