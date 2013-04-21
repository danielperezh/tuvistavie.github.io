class AddMainPictureToPost < ActiveRecord::Migration
  def change
    add_column :posts, :main_picture, :string
  end
end
