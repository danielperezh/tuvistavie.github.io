class ApplicationController < ActionController::Base
    protect_from_forgery
    before_filter :set_fallbacks
    before_filter :load_recent_posts
    before_filter :load_new_tweets

    def set_fallbacks
        Globalize.fallbacks = {:en => [:en, :ja], :ja => [:ja, :en] }
    end

    def load_recent_posts
        @recent_posts = Article.limit(4).order("created_at DESC")
    end

    def load_new_tweets
        last_tweet = Tweet.most_recent
        if last_tweet and last_tweet.posted <= 3.minutes.ago
            Tweet.fetch_new
        end
        @tweets = Tweet.limit(4).order("posted DESC")
    end
end
