class DynamicSettings < ActiveRecord::Base
    attr_accessible :last_tweet_check, :oauth_token, :oauth_token_secret, :twitter_consumer_key, :twitter_consumer_secret

    def self.update_tweet_check_time(settings=nil)
        settings ||= DynamicSettings.first
        settings.last_tweet_check = Time.now
        settings.save
    end


end
