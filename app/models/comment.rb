class Comment < ActiveRecord::Base
  include MarkdownHelper
  attr_accessible :content, :gravatar_email, :author, :answer_to_id

  belongs_to :comment

  def as_json(*args)
    super.tap { |h| h[:formatted_content] = markdown content }
  end
end
