class Comment < ActiveRecord::Base
  include MarkdownHelper
  attr_accessible :content, :gravatar_name, :name

  belongs_to :comment

  def as_json(*args)
    super.tap do |h|
      h[:formatted_date] = I18n.l(created_at, :format => :posted)
      h[:formatted_content] = markdown content
    end
  end
end
