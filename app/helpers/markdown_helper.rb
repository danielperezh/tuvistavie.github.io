module MarkdownHelper
  class CustomHTML < Redcarpet::Render::HTML
    include CloudinaryHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper

    def block_code(code, language)
      if language.nil?
        Pygments.highlight(code)
      else
        Pygments.highlight(code, :lexer => language)
      end
    end

    def image(image_name, title, alt_text)
      if title.nil? || title.empty?
        options = {}
      else
        options = ActiveSupport::JSON.decode(title).symbolize_keys rescue {}
      end
      options[:alt] = alt_text
      cl_image_tag(image_name, **options)
    end
  end

  def markdown(text, options={})
    return nil if text.nil?
    options.reverse_merge!({
      :filter_html => true,
      :autolink => true,
      :fenced_code_blocks => true,
      })
    md = Redcarpet::Markdown.new(CustomHTML, options)
    md.render(text).html_safe
  end
end
