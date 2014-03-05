# == Schema Information
#
# Table name: tweets
#
#  id         :integer          not null, primary key
#  posted     :datetime
#  content    :text
#  twitter_id :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class TweetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
