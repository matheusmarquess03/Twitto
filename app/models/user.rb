class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :tweets, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_tweets,through: :likes,source_type: "Tweet",source: :likeable
  has_many :liked_comments,through: :likes,source_type: "Comment",source: :likeable
  has_many :active_friendships,class_name:"Friendship",foreign_key:"follower_id",dependent: :destroy
  has_many :following, through: :active_friendships,source: :followed
  has_many :passive_friendships,class_name:"Friendship",foreign_key:"followed_id",dependent: :destroy
  has_many :followers, through: :passive_friendships,source: :follower
  has_many :notifications,foreign_key: :recipient_id
  has_one_attached :profile_image

  def follow(user)
    active_friendships.create(followed_id: user.id)
    #create notification for follow
    notification = Notification.create(recipient:user,actor: current_user,action:"followed",notifiable:user)
    NotificationRelayJob.perform_later(notification)
    notify(notification)

  end

  def unfollow(user)
    active_friendships.find_by(followed_id: user.id).destroy
    #create notification for unfollow
    notification=Notification.create(recipient:user,actor: current_user,action:"unfollowed",notifiable:user)
    NotificationRelayJob.perform_later(notification)

    notify(notification)

  end

  def following?(user)
    following.include?(user)
  end

  def liked?(tweet)
    liked_tweets.include?(tweet)
  end

  def liked_comment?(comment)
    liked_comments.include?(comment)
  end

  def like(tweet)
    if liked_tweets.include?(tweet)
      liked_tweets.destroy(tweet)
      #create unlike notification
      notification=Notification.create(recipient:tweet.user,actor:current_user,action:"unlike",notifiable:tweet)
      NotificationRelayJob.perform_later(notification)
    else
      liked_tweets<<tweet
      #create like notification
      notification=Notification.create(recipient:tweet.user,actor:current_user,action:"like",notifiable:tweet)
      NotificationRelayJob.perform_later(notification)
    end

    notify(notification)

    public_target="tweet_#{tweet.id}_public_likes"
    broadcast_replace_later_to "public_likes",
                               target:public_target,
                               partial:"likes/like_count",
                               locals:{tweet:tweet}
  end

  def like_comment(comment)
    if liked_comments.include?(comment)
      liked_comments.destroy(comment)
    else
      liked_comments<<comment
    end
  end

end
