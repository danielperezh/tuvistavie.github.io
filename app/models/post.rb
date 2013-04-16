class Post < ActiveRecord::Base
    translates :content, :title, :fallbacks_for_empty_translations => true
    attr_accessible :content, :title

    def to_param
        title = Globalize.with_locale(:en) { title }
        title.nil? ? id : [id, title.parameterize ].join("-")
    end

end

