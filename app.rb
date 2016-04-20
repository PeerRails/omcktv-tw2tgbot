require 'twitter'
require 'telegram/bot'
require "redis"
require 'daemons'
require 'dotenv'
require_relative 'lib/livetwee'
require_relative 'lib/redis_client'
require_relative 'lib/tg_bot'

Dotenv.load

def daemonize_rb
  Daemons.daemonize
end

def loop_bot
  loop do
    puts "kek"
    sleep(60)
  end
end

def init
  if ENV['TWITTER_CONSUMER_KEY'].nil? || ENV['TWITTER_CONSUMER_SECRET'].nil? || ENV['TWITTER_ACCESS_TOKEN'].nil? || ENV['TWITTER_ACCESS_SECRET'].nil?
    abort("no twitter keys")
  elsif ENV['TG_BOT_API_TOKEN'].nil?
    abort("No Telegram Bot API Token!")
  elsif ENV['REDIS_URL'].nil?
    abort('no redis url!')
  end

end

init()
