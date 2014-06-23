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

class DynamicSettings < ActiveRecord::Base
  attr_accessible :last_tweet_check, :oauth_token, :oauth_token_secret, :twitter_consumer_key, :twitter_consumer_secret, :dropbox_session

  def self.update_tweet_check_time(settings=nil)
    settings ||= DynamicSettings.first
    settings.last_tweet_check = Time.now
    settings.save
  end

end
