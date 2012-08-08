require 'java'
import 'org.apache.hadoop.hbase.client.HTable'
import 'org.apache.hadoop.hbase.client.Put'

=begin
Find: (using the shell)
 - delete individual column values in a row:
        delete 'table' 'row' 'col'
        delete 'table' 'row' 'col:qualifier'
 - delete an entire row:
        deleteall 'table' 'row'
=end

def jbytes( *args )
  args.map{ |arg| arg.to_s.to_java_bytes }
end

# need some refactoring here but that's ok for now
def put_many(table_name, row, column_value)
  table = HTable.new(@hbase.configuration, table_name)
  p = Put.new(*jbytes(row))
  column_value.each_pair { |name, value|
    sub_strings = name.split(':')
    column = sub_strings[0]
    qualifier = ""
    if sub_strings.length == 2
      qualifier = sub_strings[1]
    end
    p.add(*jbytes(column, qualifier, value))
  }
  table.put(p)
end

def little_test
  put_many 'wiki', 'Some title', {"text" => "Some article test",
                                  "revision:author" => "jschmoe",
                                  "revision:comment" => "no comment"}
end