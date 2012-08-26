require 'redis'

redis = Redis.new(:host => "ubuntudev12")

puts redis.brpop("queue", :timeout => 300)
