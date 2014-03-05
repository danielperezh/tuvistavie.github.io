# == Schema Information
#
# Table name: comments
#
#  id             :integer          not null, primary key
#  author         :string(255)
#  content        :text
#  gravatar_email :string(255)
#  post_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  answer_to_id   :integer
#

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
