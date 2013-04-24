class Comment < ActiveRecord::Base
  include MarkdownHelper
  attr_accessible :content, :gravatar_name, :name

  belongs_to :comment

  def as_json(*args)
    super.tap { |h| h[:formatted_content] = markdown content }
  end
end
