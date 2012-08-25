require 'neography'

@neo = Neography::Rest.new({:server => "ubuntudev12"})

puts "begin processing..."

def get_or_create_node(node)
  station = @neo.get_node_index("station", "name", node)
  if (station == nil)
    station = @neo.create_unique_node("station", "name", node, {:name => node})
  end
  return station
end

def load(file)
  count = 0
  File.open(file).each do |line|
    line_name, from, to = line.split(";")
    next unless line_name && from && to

    from_node = get_or_create_node(from.strip)
    to_node = get_or_create_node(to.strip)

    type = ""

    case line_name[0]
      when "A","B","C","D","E"
        type = "RER"
      when "M"
        type = "METRO"
      when "T"
        type = "TRAMWAY"
      when "W"
        type = "WALK"
      else
        type = "TRAIN"
    end

    @neo.create_relationship("to", from_node, to_node, {:line => line_name.strip, :line_type => type})

    puts "  #{count} relationships loaded" if (count += 1) % 100 == 0
  end

  puts "done!"

end

load ARGV[0]