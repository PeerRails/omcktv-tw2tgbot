require 'twitter'
require 'telegram/bot'
require "redis"
require 'dotenv'
require 'logger'
require 'twitter-text'
require_relative 'lib/livetwee'
require_relative 'lib/redis_client'
require_relative 'lib/tg_bot'

TGLOG = Logger.new(File.dirname(__FILE__) + '/log/telegram.log')
TWILOG = Logger.new(File.dirname(__FILE__) + '/log/twitter.log')

Dotenv.load(File.dirname(__FILE__) + '/.env')
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
      TGLOG.info("Command #{message.text} with #{message.chat.id}")
      case message.text.downcase
      when /^\/start/
        if red_oni.get_chat(message.chat.id).nil?
          bot.api.send_message(chat_id: message.chat.id, text: "Привет! Добавляю ща чатик в список рассылки")
          red_oni.store_chat(message.chat.id)
        end
      when /^\/purgetheheretics/
        unless red_oni.get_chat(message.chat.id).nil?
          bot.api.send_message(chat_id: message.chat.id, text: "Лан, удаляю из списка рассылки")
          red_oni.remove_chat(message.chat.id)
        end
      when /^\/posttweet/
        bot.api.send_message(chat_id: message.chat.id, text: "Пока недоступно")
      when /^\/notavailable/
        bot.api.send_sticker(chat_id: message.chat.id, sticker: "BQADAgADCwADGuNyCWFvP04VyxHBAg")
      when /^\/last_tweet/
        tweet = blue_oni.get_timeline("omcktv").first
        bot.api.send_message(chat_id: message.chat.id, text: "#{tweet.full_text} #{tweet.url}")
      when /^\/last_mention/
        tweet = blue_oni.get_mentions.first
        bot.api.send_message(chat_id: message.chat.id, text: "#{tweet.full_text} #{tweet.url}")
      when /^\/hug/i
        reciever = message.text[/ (\@[a-zA-Z0-9_]+)/]
        reciever = message.from.first_name if reciever.nil?
        bot.api.send_message(chat_id: message.chat.id, text: "༼ つ ◕_◕ ༽つ\nОбнял #{reciever}")
      when /^\/kappa/
        reciever = message.text[/ (\@[a-zA-Z0-9_]+)/]
        reciever = message.from.first_name if reciever.nil?
        bot.api.send_message(chat_id: message.chat.id, text: "༼ つ ͡ ͡° ͜ ʖ ͡ ͡° ༽つ #{reciever}")
      when /\/yaranaika/
        bot.api.sendSticker(chat_id: message.chat.id, sticker: "BQADAQADAwIAAoRmZwS3q19CWFJchQI")
      when /\/bigguy/
        reciever = message.text[/ (\@[a-zA-Z0-9_]+)/]
        reciever = message.from.first_name if reciever.nil?
        bot.api.send_message(chat_id: message.chat.id, text: "А ты большой парень, #{reciever}")
        bot.api.sendSticker(chat_id: message.chat.id, sticker: "BQADAgAD5wADiyYxB3PBKrw8lWzeAg")
      else
        message = nil
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
          bot.api.send_message(chat_id: chat, text: "#{tweet.full_text} #{tweet.url}")
          TWILOG.info("Sending tweet #{tweet.id} to #{chat}")
        end
        red_oni.set_tweet_key(tweet.id)
        TWILOG.info("Saving tweet #{tweet.id} to Redis")
        red_oni.set_last_tweet(tweet.id)
      end
      if red_oni.get_tweet_key(mention.id).nil?
        chats.each do |chat|
          bot.api.send_message(chat_id: chat, text: "#{mention.full_text} #{mention.url}")
          TWILOG.info("Sending tweet #{mention.id} to #{chat}")
        end
        TWILOG.info("Saving mention #{mention.id} to Redis")
        red_oni.set_tweet_key(mention.id)
      end
      break
    end
    sleep(60)
  }
end

init()
t1 = Thread.new { listen_chat() }
t2 = Thread.new { listen_twitter() }
t1.join
t2.join
#listen_chat()
