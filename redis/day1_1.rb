require 'redis'

=begin
Find
1.
  http://redis.io/commands
=end

redis = Redis.new(:host => "ubuntudev12")

key = "mykey"

puts "#{key}: #{redis.get(key)}"

redis.multi do
  redis.set(key, 0)
  redis.incr(key)
end

puts "#{key}: #{redis.get(key)}"

