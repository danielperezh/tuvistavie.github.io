class Comment < ActiveRecord::Base
  include MarkdownHelper
  before_validation :set_answer_to_id

  attr_accessible :content, :gravatar_email, :author, :answer_to_id

  belongs_to :comment

  validates :content, :author,  :presence => true

  def set_answer_to_id
    unless answer_to_id.nil?
      original_comment = Comment.find(answer_to_id) rescue nil
      if original_comment.nil?
        errors.add :answer_to_id, 'Invalid answer_to id'
      elsif original_comment.answer_to_id
        update_attribute :answer_to_id, original_comment.answer_to_id
      end
    end
  end

  def as_json(*args)
    super.tap { |h| h[:formatted_content] = markdown content }
  end
end
