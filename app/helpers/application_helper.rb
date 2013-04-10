module ApplicationHelper
    class HTMLwithPygments < Redcarpet::Render::HTML
        def block_code(code, language)
            if language.nil?
                Pygments.highlight(code)
            else
                Pygments.highlight(code, :lexer => language)
            end
        end
    end

    def markdown(text, options={})
        options.reverse_merge!({
            :filter_html => true,
            :autolink => true,
            :fenced_code_blocks => true,
        })
        md = Redcarpet::Markdown.new(HTMLwithPygments, options)
        md.render(text).html_safe
    end
end
