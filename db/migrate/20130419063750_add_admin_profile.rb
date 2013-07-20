class AddAdminProfile < ActiveRecord::Migration
  def up
    Admin.create_translation_table! :profile => :text, :long_profile => :text
  end

  def down
    Admin.drop_translation_table!
  end
end
