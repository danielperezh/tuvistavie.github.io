class AddWorkToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :work_place, :string
    add_column :admins, :work_position, :string
    add_column :admins, :work_url, :string
  end
end
