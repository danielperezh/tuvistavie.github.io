class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_url
  before_filter :set_locale
  before_filter :load_profile
  before_filter :load_recent_posts
  before_filter :load_new_tweets

  def set_url
    base_url = Rails.application.routes.recognize_path request.url rescue root_path
    @url_info = base_url.merge(params) if not base_url.nil?
  end

  def load_profile
    @profile = Admin.first.profile
  end

  def load_recent_posts
    num = Settings.posts.recents_number
    posts = Post.with_translations(I18n.locale)
    @recent_posts = posts.limit(num).order("posts.created_at DESC")
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

  def locale_is_available(locale_name)
    I18n.available_locales.include?(locale_name.to_sym)
  end

  def set_locale
    if params.has_key? :locale and locale_is_available(params[:locale])
      I18n.locale = params[:locale].to_sym
    elsif session.has_key? :locale and locale_is_available(session[:locale])
      I18n.locale = session[:locale].to_sym
    else
      country = get_country_code
      I18n.locale = :ja if country == 'jp'
    end
    session[:locale] = I18n.locale
  end
end
