module Twitter
  def self.rest_client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_ACCESS_KEY']
      config.consumer_secret = ENV['TWITTER_SECRET_KEY']
      config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
      config.access_token_secret = ENV['TWITTER_OAUTH_SECRET']
    end
  end
end
