class DropDynamicSettings < ActiveRecord::Migration
  def change
    drop_table :dynamic_settings
  end
end
