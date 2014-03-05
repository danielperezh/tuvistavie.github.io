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
  attr_accessible :content, :title, :tags_attributes, :friendly_id, :main_picture, :published

  has_many :comments, :dependent => :delete_all
  has_and_belongs_to_many :tags, :uniq => true

  before_save :set_friendly_id
  before_save :fix_tags
  before_destroy :remove_tags

  scope :published, ->{ where(published: true) }

  accepts_nested_attributes_for :tags, :allow_destroy => true

  self.per_page = Settings.posts.per_page

  def self.scoped_for(signed_in)
    signed_in ? Post.unscoped : Post
  end

  def to_param
    return id if friendly_id.nil?
    [id, friendly_id.parameterize].join("-")
  end

  def self.find_by_tag(tag_name, locale=I18n.locale)
    tags = Tag.find_by_name(tag_name)
    raise ActiveRecord::RecordNotFound if tags.nil?
    ids = tags.posts.pluck(:id)
    Post.with_translations(I18n.locale).where(:id => ids)
  end

  def set_friendly_id
    if I18n.locale == :en && friendly_id.blank?
      update_attribute :friendly_id, title
    end
  end

  def remove_tags
    tags.each do |tag|
      tag.destroy if tag.posts.count == 1
    end
  end

  private
  def fix_tags
    return if tags.nil?
    tag_list = tags.clone
    tags.clear
    tag_list.each do |t|
      if t.id.nil?
        tag = Tag.find_by_name(t.name)
        if tag.nil?
          tags.build(:name => t.name)
        else
          tags << tag
        end
      else
        tags << t
      end
    end
  end
end
