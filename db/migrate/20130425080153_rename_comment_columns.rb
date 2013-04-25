class RenameCommentColumns < ActiveRecord::Migration
  def change
    rename_column :comments, :name, :author
    rename_column :comments, :gravatar_name, :gravatar_email
  end
end
