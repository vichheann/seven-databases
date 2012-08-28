require 'sinatra'
require 'redis'
require 'redis/distributed'
require 'hiredis'

redis = Redis::Distributed.new(["redis://ubuntudev12:6379/", "redis://ubuntu1:6379/"], :driver => :hiredis)

helpers do
  def hash(url)
    Zlib::crc32(url).to_s(32)
  end
end

get '/' do
  erb :index
end

post '/' do
  url = params[:url]
  if (url && !url.empty?)
    @shortcode = hash(url)
    redis.set(@shortcode, url)
  end
  erb:index
end

get '/:shortcode' do
  url = redis.get("#{params[:shortcode]}")
  redirect url || '/'
end
