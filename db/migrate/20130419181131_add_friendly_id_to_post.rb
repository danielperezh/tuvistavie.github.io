class AddFriendlyIdToPost < ActiveRecord::Migration
  def change
    add_column :posts, :friendly_id, :string
  end
end
