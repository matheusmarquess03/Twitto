class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :tweets
  has_many :comments, through: :tweet
  has_many :likeables, dependent: :destroy
  has_many :liked_tweets, through: :likeables, source: :tweet
  has_one_attached :profile_image

  def liked?(tweet)
    liked_tweets.include?(tweet)
  end

  def like(tweet)
    if liked_tweets.include?(tweet)
      liked_tweets.destroy(tweet)
    else
      liked_tweets<<tweet
    end
    public_target = "tweet_#{@tweet.id}_public_likes"
    broadcast_replace_later_to "public_likes", partial:"likes/likes_count", locals:{tweet:@tweet}
  end

end
