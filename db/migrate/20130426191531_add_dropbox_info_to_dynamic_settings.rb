class AddDropboxInfoToDynamicSettings < ActiveRecord::Migration
  def change
    add_column :dynamic_settings, :dropbox_session, :string
  end
end
