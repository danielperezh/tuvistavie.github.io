class AddAdminLongProfile < ActiveRecord::Migration
  def up
    add_column :admin_translations, :long_profile, :text
  end

  def down
    remove_column :admin_translations, :long_profile
  end
end
