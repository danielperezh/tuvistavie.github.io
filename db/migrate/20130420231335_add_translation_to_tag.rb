class AddTranslationToTag < ActiveRecord::Migration
    def self.up
        change_column :tags, :name, :string
        Tag.create_translation_table!({
            :name => :string
        }, {
            :migrate_data => true
        })
    end

    def self.down
        Tag.drop_translation_table! :migrate_data => true
        change_column :tags, :name, :text
    end
end
