class Post < ActiveRecord::Base
  translates :content, :title
  attr_accessible :content, :title, :tags_attributes, :friendly_id

  has_many :comments
  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :tags, :allow_destroy => true

  self.per_page = Settings.posts.per_page

  def to_param
    friendly_id.nil? ? id : [id, friendly_id.parameterize].join("-")
  end

  def add_tags!(tags)
    tags.each_value do |tag_hash|
      tag = Tag.find_by_name(tag_hash[:name], tag_hash[:locale])
      if tag.nil?
        self.tags.build(:name => tag_hash[:name], :locale => tag_hash[:locale])
      else
        self.tags << tag
      end
    end
  end
end
