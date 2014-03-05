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

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
