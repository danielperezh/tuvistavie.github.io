class DynamicSettings < ActiveRecord::Base
  attr_accessible :last_tweet_check, :oauth_token, :oauth_token_secret, :twitter_consumer_key, :twitter_consumer_secret
end
