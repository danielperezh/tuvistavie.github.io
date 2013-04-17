class CreateDynamicSettings < ActiveRecord::Migration
  def change
    create_table :dynamic_settings do |t|
      t.datetime :last_tweet_check
      t.text :twitter_consumer_key
      t.text :twitter_consumer_secret
      t.text :oauth_token
      t.text :oauth_token_secret

      t.timestamps
    end
  end
end
