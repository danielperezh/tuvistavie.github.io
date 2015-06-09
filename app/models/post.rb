# == Schema Information
#
# Table name: posts
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  friendly_id  :string(255)
#  main_picture :string(255)
#  published    :boolean
#

class Post < ActiveRecord::Base
  translates :content, :title

  has_many :comments, dependent: :delete_all
  has_and_belongs_to_many :tags, uniq: true

  before_save :set_friendly_id
  before_save :fix_tags
  before_destroy :remove_tags

  scope :published, -> { where(published: true) }

  accepts_nested_attributes_for :tags, allow_destroy: true

  self.per_page = Settings.posts.per_page

  def self.scoped_for(signed_in)
    signed_in ? Post.unscoped : Post
  end

  def to_param
    return id if friendly_id.nil?
    [id, friendly_id.parameterize].join('-')
  end

  def self.find_by_tag(tag_name, locale = I18n.locale)
    tags = Tag.find_by_name(tag_name)
    fail ActiveRecord::RecordNotFound if tags.nil?
    ids = tags.posts.pluck(:id)
    Post.with_translations(locale).where(id: ids)
  end

  def set_friendly_id
    update_attribute :friendly_id, title if I18n.locale == :en && friendly_id.blank?
  end

  def remove_tags
    tags.each do |tag|
      tag.destroy if tag.posts.count == 1
    end
  end

  private

  def fix_tags
    return if tags.nil?
    tag_list = []
    tags.each do |t|
      name = t.name
      t = Tag.find_by_name(name) if t.id.nil?
      t = tags.build(name: name) if t.nil?
      tag_list << t
    end
    self.tags = tag_list
  end
end
