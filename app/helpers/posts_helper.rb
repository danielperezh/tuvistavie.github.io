module PostsHelper

    def format_tags(tags)
        tags_list = tags.map { |t| link_to t.name, posts_path(:tag => t.name) }.join(', ')
        I18n.t('posts.category', :tags => tags_list).html_safe
    end
end
