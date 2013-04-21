module ApplicationHelper

    def get_locale_url_info(url_info, locale)
        url_info['locale'] = locale
        url_info
    end

    def safe_cl_image_tag(public_id, **params)
        public_id = '' if public_id.nil?
        cl_image_tag(public_id, **params)
    end
end
