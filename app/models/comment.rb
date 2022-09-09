class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :tweet

  has_one_attached :comment_image
end
