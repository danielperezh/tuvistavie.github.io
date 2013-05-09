class Post < ActiveRecord::Base
  translates :content, :title
  attr_accessible :content, :title, :tags_attributes, :friendly_id, :main_picture

  has_many :comments, :dependent => :delete_all
  has_and_belongs_to_many :tags

  before_save :set_friendly_id

  accepts_nested_attributes_for :tags, :allow_destroy => true

  self.per_page = Settings.posts.per_page

  def to_param
    return id if friendly_id.nil?
    [id, friendly_id.parameterize].join("-")
  end

  def self.find_by_tag(tag_name, locale=I18n.locale)
    ids = Tag.find_by_name(tag_name).posts.pluck(:id)
    Post.with_translations(I18n.locale).where(:id => ids)
  end

  def set_friendly_id
    if I18n.locale == :en && friendly_id.blank?
      update_attribute :friendly_id, title
    end
  end
end
