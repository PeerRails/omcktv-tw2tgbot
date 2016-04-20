require 'twitter'
require 'telegram/bot'
require "redis"
require 'daemons'
require 'dotenv'
require 'logger'
require_relative 'lib/livetwee'
require_relative 'lib/redis_client'
require_relative 'lib/tg_bot'

TGLOG = Logger.new('log/telegram.log')
TWILOG = Logger.new('log/twitter.log')
PWD = File.dirname(__FILE__)

Dotenv.load
BOTTOKEN = ENV['TG_BOT_API_TOKEN']

def red_oni
  RedOni.new(ENV['REDIS_URL'])
end

def blue_oni
  BlueOni.new(ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET'], ENV['TWITTER_ACCESS_TOKEN'], ENV['TWITTER_ACCESS_SECRET'])
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

def listen_chat
  Telegram::Bot::Client.run(BOTTOKEN) do |bot|
    bot.listen do |message|
      TGLOG.info("Command #{command} with #{message.chat.id}")
      case message.text
      when '/start'
        bot.api.send_message(chat_id: message.chat.id, text: "Привет! Добавляю ща чатик в список рассылки")
        red_oni.store_chat(message.chat.id)
      when '/purge'
        bot.api.send_message(chat_id: message.chat.id, text: "Лан, пока, удаляю из списка рассылки")
        red_oni.remove_chat(message.chat.id)
      when '/tweet'
        bot.api.send_message(chat_id: message.chat.id, text: "Пока недоступно")
      when '/last_tweet'
        tweet = blue_oni.get_timeline("omcktv").first.url
        bot.api.send_message(chat_id: message.chat.id, text: tweet)
      when '/last_mention'
        tweet = blue_oni.get_mentions.first.url
        bot.api.send_message(chat_id: message.chat.id, text: tweet)
      end
    end
  end
end

def listen_twitter
  loop {
    Telegram::Bot::Client.run(BOTTOKEN) do |bot|
      tweet = blue_oni.get_timeline("omcktv").first
      mention = blue_oni.get_mentions.first
      chats = red_oni.get_chats
      if red_oni.get_tweet_key(tweet.id).nil?
        chats.each do |chat|
          bot.api.send_message(chat_id: chat, text: tweet.url)
          TWILOG.info("Sending tweet #{tweet.id} to #{chat}")
        end
        red_oni.set_tweet_key(tweet.id)
        TWILOG.info("Saving tweet #{tweet.id} to Redis")
        red_oni.set_last_tweet(tweet.id)
      end
      if red_oni.get_tweet_key(mention.id).nil?
        chats.each do |chat|
          bot.api.send_message(chat_id: chat, text: tweet.url)
          TWILOG.info("Sending tweet #{tweet.id} to #{chat}")
        end
        red_oni.set_tweet_key(tweet.id)
        TWILOG.info("Saving tweet #{tweet.id} to Redis")
      end
    end
    sleep(60)
  }
end

def daemonize_rb
  opts = {
    :app_name => 'omcktwitterbot',
    :log => PWD + "/logs",
    :dir => PWD + "/logs",
    :log_output => true,
    :monitor => true,
    :keep_pid_files => true,
    :multiple => true
  }
  puts "Starting Daemons!"
  task1 = Daemons.call(opts) do
    # first server task

    listen_chat()
  end

  task2 = Daemons.call do
    listen_twitter
  end

  task1.stop
  task2.stop

  exit
end

init()
