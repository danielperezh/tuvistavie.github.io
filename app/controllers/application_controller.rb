class ApplicationController < ActionController::Base
    protect_from_forgery
    before_filter :set_fallbacks
    before_filter :load_recent_posts

    def set_fallbacks
        Globalize.fallbacks = {:en => [:en, :ja], :ja => [:ja, :en] }
    end

    def load_recent_posts
        @recent_posts = Article.limit(4).order("created_at ASC")
    end
end
