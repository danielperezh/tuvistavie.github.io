class ApplicationController < ActionController::Base
    protect_from_forgery
    before_filter :set_fallbacks

    def set_fallbacks
        Globalize.fallbacks = {:en => [:en, :ja], :ja => [:ja, :en] }
    end
end
