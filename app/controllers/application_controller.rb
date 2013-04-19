class ApplicationController < ActionController::Base
    protect_from_forgery
    before_filter :set_url
    before_filter :set_fallbacks
    before_filter :set_locale
    before_filter :load_profile
    before_filter :load_recent_posts
    before_filter :load_new_tweets

    def set_url
        @url_info = Rails.application.routes.recognize_path request.url rescue root_path
    end

    def set_fallbacks
        Globalize.fallbacks = {:en => [:en, :ja], :ja => [:ja, :en] }
    end

    def load_profile
        @profile = Admin.first.profile
    end

    def load_recent_posts
        @recent_posts = Post.limit(Settings.posts.recents_number).order("created_at DESC")
    end

    def load_new_tweets
        dynamic_settings = DynamicSettings.first
        if dynamic_settings.last_tweet_check < Settings.twitter.tweet_check_interval.minutes.ago
            Tweet.fetch_new
            DynamicSettings.update_tweet_check_time(dynamic_settings)
        end
        @tweets = Tweet.limit(Settings.twitter.display_tweets).order("posted DESC")
    end

    def get_country_code
        @geoip ||= GeoIP.new(Rails.root.join('lib/GeoIP.dat'))
        country = @geoip.country(request.remote_ip)
        code = country.country_code2
        code == '--' ? nil : code.downcase
    end

    def set_locale
        if params.has_key? :locale and I18n.available_locales.include?(params[:locale].to_sym)
            I18n.locale = params[:locale].to_sym
        else
            country = get_country_code
            I18n.locale = :ja if country == 'jp'
        end
    end
end
