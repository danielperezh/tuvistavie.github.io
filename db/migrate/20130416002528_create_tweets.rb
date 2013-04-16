class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.datetime :posted
      t.text :content
      t.text :twitter_id

      t.timestamps
    end

    add_index :tweets, :twitter_id, :unique => true
  end
end
