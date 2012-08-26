require 'redis'

redis = Redis.new(:host => "ubuntudev12")

redis.lpush("queue", gets.chomp)
