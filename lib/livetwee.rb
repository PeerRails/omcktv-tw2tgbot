class LiveTwee
  def initialize(consumer_key, consumer_secret, access_token, access_token_secret)
    @consumer_key =  consumer_key
    @consumer_secret = consumer_secret
    @access_token = access_token
    @access_token_secret = access_token_secret
  end

  def get_timeline(user)
    tclient.user_timeline(user)
  end

  def get_mentions
    tclient.mentions_timeline
  end

  def get_tweet(id)
    client.status(id)
  end

  private
    def tclient
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
        config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
        config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
        config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
      end
    end
end
