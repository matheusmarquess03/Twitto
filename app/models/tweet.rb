class Tweet < ApplicationRecord
  belongs_to :user
  belongs_to :tweet, optional: true
  has_many :comments, dependent: :destroy
  has_many :likeables, dependent: :destroy
  has_many :likes, through: :likeables, source: :user

  validates :body, presence: true, unless: :tweet_id

  def tweet_type
    if tweet_id?
      "retweet"
    else
      "tweet"
    end
  end
end
