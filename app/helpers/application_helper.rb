module ApplicationHelper

    def get_locale_url_info(url_info, locale)
        url_info['locale'] = locale
        url_info
    end
end
