class AddAnswerToIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :answer_to_id, :integer
  end
end
