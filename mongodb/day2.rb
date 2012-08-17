require 'mongo'
require 'csv'
require 'pp'

# http://api.mongodb.org/ruby/current/file.TUTORIAL.html

connection = Mongo::Connection.new("localhost")
db = connection.db("day2")

goog = db.collection("goog")

goog.drop_indexes unless goog.index_information == {}
goog.drop

def to_utc(value)
  date = Date.parse(value)
  return Time.utc(date.year, date.month, date.day)
end

CSV.foreach("../riak/goog.csv") do |row|
  if (row[0] != 'Date')

    doc = {"date" => to_utc(row[0]), "open" => row[1], "high" => row[2], "low" => row[3], "close" => row[4], "volume" => row[5], "adj close" => row[6]}
    goog.insert(doc)
  end
end

date = to_utc("2010-05-05")
puts "-->Before index"
pp(goog.find("date" => date).explain)

goog.create_index("date")

puts "-->After index"
pp(goog.find("date" => date).explain)

