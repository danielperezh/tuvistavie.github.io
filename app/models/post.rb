class Post < ActiveRecord::Base
    translates :content, :title, :fallbacks_for_empty_translations => true
    attr_accessible :content, :title, :tags_attributes

    has_many :comments
    has_and_belongs_to_many :tags

    accepts_nested_attributes_for :tags, :allow_destroy => true

    def to_param
        title = Globalize.with_locale(:en) { title }
        title.nil? ? id : [id, title.parameterize ].join("-")
    end

end

