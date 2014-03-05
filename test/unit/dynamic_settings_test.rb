# == Schema Information
#
# Table name: dynamic_settings
#
#  id                      :integer          not null, primary key
#  last_tweet_check        :datetime
#  twitter_consumer_key    :text
#  twitter_consumer_secret :text
#  oauth_token             :text
#  oauth_token_secret      :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  dropbox_session         :string(255)
#

require 'test_helper'

class DynamicSettingsTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
