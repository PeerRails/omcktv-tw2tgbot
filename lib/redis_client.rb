class RedisClient
  def initialize(url)
    @url = url
  end

  def get_tweet_key(id)
    client.get("tweet_#{id}")
  end

  def set_tweet_key(id)
    client.set("tweet_#{id}", 'true')
  end

  def set_owner(name)
    client.set("tguser_#{name}", "owner")
  end

  def get_owner(name)
    client.set("tguser_#{name}")
  end

  def store_chat(chat_id)
    client.set("chat_#{chat_id}", "true")
  end

  def get_chat(chat_id)
    client.set("char_#{chat_id}")
  end

  private

    def client
      Redis.new(:url => @url)
    end
end
