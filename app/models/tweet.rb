# == Schema Information
#
# Table name: tweets
#
#  id         :integer          not null, primary key
#  posted     :datetime
#  content    :text
#  twitter_id :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tweet < ActiveRecord::Base
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
        tweets = Twitter.rest_client.user_timeline(params)
        tweets.each do |tweet|
            Tweet.create(
                :twitter_id => tweet[:id],
                :content => tweet[:text],
                :posted => tweet[:created_at]
            )
        end
    end


end
