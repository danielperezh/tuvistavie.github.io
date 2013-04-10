class Article < ActiveRecord::Base
    translates :content, :title
    attr_accessible :content, :title

    def to_param
        [id, Globalize.with_locale(:en) { title.parameterize }].join("-")
    end

end
