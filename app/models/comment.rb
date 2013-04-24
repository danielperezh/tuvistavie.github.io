class Comment < ActiveRecord::Base
  attr_accessible :content, :gravatar_name, :name

  belongs_to :comment

  def as_json(*args)
    super.tap { |h| h[:formatted_date] = I18n.l(created_at, :format => :posted) }
  end
end
