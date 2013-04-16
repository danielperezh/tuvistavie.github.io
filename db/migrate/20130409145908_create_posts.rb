class CreatePosts < ActiveRecord::Migration
    def up
        create_table :posts do |t|
            t.timestamps
        end
        Post.create_translation_table! :title => :string, :content => :text
    end

    def down
        drop_table :posts
        Post.drop_translation_table!
    end
end
