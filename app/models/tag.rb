class Tag < ActiveRecord::Base
  translates :name
  attr_accessible :name

  has_and_belongs_to_many :posts, :uniq => true

  def self.find_by_name(name, locale=I18n.locale)
    tags = Tag.with_translations(locale)
    tags.where('tag_translations.name' => name).first
  end
end
