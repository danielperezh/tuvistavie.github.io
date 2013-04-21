class AddInfoToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :small_picture, :string
    add_column :admins, :large_picture, :string
    add_column :admins, :first_name, :string
    add_column :admins, :last_name, :string
    add_column :admins, :nickname, :string
  end
end
