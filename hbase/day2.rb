require 'java'

import 'org.apache.hadoop.hbase.client.HTable'
import 'org.apache.hadoop.hbase.client.Put'
import 'javax.xml.stream.XMLStreamConstants'

=begin
create 'foods', {NAME=>'fact', BLOOMFILTER=>'ROW', COMPRESSION=>'GZ', VERSIONS=>1}
=end

=begin
Launch with cat Food_Display_Table_indented.xml | hbase shell day2.rb 
Should load 2014 rows
Later, you cab query like that
scan 'foods', {FILTER=>"RowFilter(=,'regexstring:Cake doughnut\\|doughnut hole')"}
=end

def jbytes( *args )
  args.map { |arg| arg.to_s.to_java_bytes }
end

factory = javax.xml.stream.XMLInputFactory.newInstance
reader = factory.createXMLStreamReader(java.lang.System.in)

food = nil 
buffer = nil
count = 0

table = HTable.new( @hbase.configuration, 'foods' )
table.setAutoFlush( false )

while reader.has_next
  type = reader.next
  
  if type == XMLStreamConstants::START_ELEMENT
  
    case reader.local_name
    when 'Food_Display_Table' then puts "Starting"
    when 'Food_Display_Row' then food = {} 
    else buffer = []
    end
    
  elsif type == XMLStreamConstants::CHARACTERS
    
    buffer << reader.text unless buffer.nil?
    
  elsif type == XMLStreamConstants::END_ELEMENT
    
    case reader.local_name
    when 'Food_Display_Table' then puts "Done" 
    when 'Food_Display_Row'
      key = *jbytes(food['Food_Code'] + '|' + food['Display_Name'] + '|' + food['Portion_Display_Name'])
      
      p = Put.new( key )
      food.each do |fact, value|
        p.add( *jbytes( "fact", fact, value ) )  if value != ".00000"
      end
      table.put( p )
      
      count += 1
      table.flushCommits() if count % 10 == 0
      if count % 500 == 0
        puts "#{count} records inserted (#{food['Display_Name']})"
      end
    else 
      food[reader.local_name] = buffer.join
    end
  end
end

table.flushCommits()
exit

