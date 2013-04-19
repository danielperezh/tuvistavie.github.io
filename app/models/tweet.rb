class Tweet < ActiveRecord::Base
    attr_accessible :content, :posted, :twitter_id

    def self.most_recent
        Tweet.limit(1).order("twitter_id DESC").first
    end

    def self.fetch_new
        params = {
            :count => Settings.twitter.display_tweets + 3,
            :exclude_replies => true,
            :trim_user => true,
            :include_rts => false
        }
        last_tweet = Tweet.most_recent
        params[:since_id] = last_tweet.twitter_id if not last_tweet.nil?
        tweets = Twitter.user_timeline(params)
        tweets.each do |tweet|
            Tweet.create(
                :twitter_id => tweet[:id],
                :content => tweet[:text],
                :posted => tweet[:created_at]
            )
        end
    end


end
