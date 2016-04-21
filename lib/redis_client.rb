class RedOni
  def initialize(url)
    @url = url
  end

  def get_tweet_key(id)
    client.get("tweet_#{id}")
  end

  def set_tweet_key(id)
    p "Saving tweet_#{id}"
    client.set("tweet_#{id}", 'true')
  end

  def set_last_tweet(id)
    client.set("last_tweet", id)
  end

  def get_last_tweet(id)
    client.get("last_tweet")
  end

  def set_owner(name)
    client.set("tguser_#{name}", "owner")
  end

  def get_owner(name)
    client.get("tguser_#{name}")
  end

  def remove_owner(name)
    client.del("tguser_#{name}")
  end

  def store_chat(chat_id)
    client.lpush "chats", chat_id
    client.set("chat_#{chat_id}", "true")
  end

  def get_chat(chat_id)
    client.get("chat_#{chat_id}")
  end

  def remove_chat(chat_id)
    client.del("chat_#{chat_id}")
    client.lrem("chats", -1, chat_id)
  end

  def get_chats
    client.lrange("chats", 0, -1)
  end

  private

    def client
      Redis.new(:url => @url)
    end
end
