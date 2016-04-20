class RedOni
  def initialize(url)
    @url = url
  end

  def get_tweet_key(id)
    client.get("tweet_#{id}")
  end

  def set_tweet_key(id)
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
    client.set("tguser_#{name}", nil)
  end

  def store_chat(chat_id)
    client.set("chat_#{chat_id}", "true")
  end

  def get_chat(chat_id)
    client.get("char_#{chat_id}")
  end

  def remove_chat(chat_id)
    client.set("char_#{chat_id}", nil)
  end

  def get_chats
    client.lrange("chats", 0, 0)
  end

  private

    def client
      Redis.new(:url => @url)
    end
end
