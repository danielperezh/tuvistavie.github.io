module ApplicationHelper
  def get_locale_url_info(url_info, locale)
    url_info[:locale] = locale
    tag_name = url_info.delete(:tag)
    if tag_name
      tag = Tag.find_by_name_with_any_locale(tag_name)
      if tag
        # reload tag with correct locale
        url_info[:tag] = Globalize.with_locale(locale) { Tag.find(tag.id).name }
      end
    end
    url_info
  end

  def cache_if(condition, name={}, options=nil, &block)
    if condition
      cache(name, *options, &block)
    else
      yield
    end
  end

  def cache_unless(condition, name={}, options=nil, &block)
    cache_if(!condition, name, options, &block)
  end
end
