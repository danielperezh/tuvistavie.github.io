settings = DynamicSettings.first rescue nil
if not settings.nil?
    Twitter.configure do |config|
      config.consumer_key = settings.twitter_consumer_key
      config.consumer_secret = settings.twitter_consumer_secret
      config.oauth_token = settings.oauth_token
      config.oauth_token_secret = settings.oauth_token_secret
  end
end
