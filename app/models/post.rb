class Post < ActiveRecord::Base
    translates :content, :title
    attr_accessible :content, :title, :tags_attributes

    has_many :comments
    has_and_belongs_to_many :tags

    accepts_nested_attributes_for :tags, :allow_destroy => true

    self.per_page = Settings.posts.per_page

    def to_param
        t = Globalize.with_locale(:en) { title }
        t.nil? ? id : [id, t.parameterize].join("-")
    end
end