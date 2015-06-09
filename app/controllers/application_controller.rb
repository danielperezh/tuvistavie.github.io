class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :set_url
  before_filter :set_fallbacks
  before_filter :load_profile
  before_filter :load_recent_posts
  before_filter :load_new_tweets

  unless Rails.env.development?
    rescue_from StandardError, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ::AbstractController::ActionNotFound, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  def load_profile
    @admin_info = Admin.first
  end

  def set_url
    base_url = Rails.application.routes.recognize_path request.url rescue
    base_url = Rails.application.routes.recognize_path root_path if base_url.nil?
    @url_info = base_url.merge(params.symbolize_keys)
  end

  def load_recent_posts
    num = Settings.posts.recents_number
    posts = Post.published.with_translations(I18n.locale)
    @recent_posts = posts.limit(num).order('posts.created_at DESC')
  end

  def load_new_tweets
    last_check = Time.parse(Rails.cache.read('twitter:last_check') || 1.day.ago.iso8601)
    if last_check < Settings.twitter.tweet_check_interval.minutes.ago
      Tweet.fetch_new
      Rails.cache.write('twitter:last_check', last_check.iso8601)
    end
    @tweets = Tweet.limit(Settings.twitter.display_tweets).order('posted DESC')
  end

  def locale_is_available(locale_name)
    I18n.available_locales.include?(locale_name.to_sym)
  end

  def set_fallbacks
    Globalize.fallbacks = { en: [:en, :ja], ja: [:ja, :en] }
  end

  def set_locale
    if params.key?(:locale) && locale_is_available(params[:locale])
      I18n.locale = params[:locale].to_sym
    elsif cookies.key?(:locale) && locale_is_available(cookies[:locale])
      I18n.locale = cookies[:locale].to_sym
    else
      country = current_country_code
      if country == 'jp'
        I18n.locale = :ja
      else
        I18n.locale = :en
      end
    end
    cookies.permanent[:locale] = I18n.locale
  end

  def upload_files(files)
    return if files.nil?
    files.each_value { |f| upload_file(f) }
  end

  def upload_file(file)
    return if file[:file].nil? || file[:name].empty?
    options = ActiveSupport::JSON.decode(file[:options]).symbolize_keys rescue {}
    options ||= {}
    options[:public_id] = file[:name]
    Cloudinary::Uploader.upload(file[:file], **options)
  end

  private

  def render_404
    respond_to do |format|
      format.html { render template: 'errors/not_found', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500
    respond_to do |format|
      format.html { render template: 'errors/exception', status: 500 }
      format.all { render nothing: true, status: 500 }
    end
  end

  def current_country_code
    @geoip ||= GeoIP.new(Rails.root.join('lib/GeoIP.dat'))
    country = @geoip.country(request.remote_ip)
    code = country.country_code2
    code == '--' ? nil : code.downcase
  end

end
