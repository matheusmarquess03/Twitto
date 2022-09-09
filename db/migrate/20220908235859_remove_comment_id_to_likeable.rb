class RemoveCommentIdToLikeable < ActiveRecord::Migration[7.0]
  def change
    remove_column :likeables, :comment_id, :integer
  end
end
