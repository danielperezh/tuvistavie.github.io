# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ActiveRecord::Base
  translates :name
  attr_accessible :name

  has_and_belongs_to_many :posts, :uniq => true

  def self.find_by_name(name, locale=I18n.locale)
    tags = Tag.with_translations(locale)
    tags.where('tag_translations.name' => name).first
  end

  def self.find_by_name_with_any_locale(name)
    I18n.available_locales.each do |locale|
      tag = Tag.find_by_name(name, locale)
      return tag if tag
    end
  end
end
