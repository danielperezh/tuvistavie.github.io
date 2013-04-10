module ApplicationHelper
    class HTMLwithAlbino < Redcarpet::Render::HTML
        def block_code(code, language)
            Albino.colorize(code, language)
        end
    end

    def markdown(text, options={})
        options.reverse_merge!({
            :filter_html => true,
            :autolink => true,
            :fenced_code_blocks => true,
        })
        md = Redcarpet::Markdown.new(HTMLwithAlbino, options)
        md.render(text).html_safe
    end
end
