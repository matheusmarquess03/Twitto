class Tweet < ApplicationRecord
  include NotificationHelper
  include BroadcastTweetHelper

  belongs_to :user

  belongs_to :parent_tweet, class_name:"Tweet", foreign_key: 'parent_tweet_id', optional: true,dependent: :destroy

  #has_many replies and retweets
  has_many :child_tweets, class_name:"Tweet",foreign_key: 'parent_tweet_id',dependent: :destroy

  has_many :likes

  validates :body,presence: true,unless: :parent_tweet_id

  has_one_attached :tweet_image

  scope :followers_tweets,->(currentUser){ where(user_id: currentUser.following).order("created_at DESC") }

  scope :my_tweets,->(currentUser){ where(user_id: currentUser).order("created_at DESC") }

  scope :get_replies,->(id){ where(parent_tweet_id: id).order("created_at DESC") }

  after_destroy_commit{ broadcast_remove_to "public_tweets" }

  after_create_commit :send_retweet_notification,if: Proc.new{ tweet_type=="retweet" }

  after_create_commit :broadcast_tweet_retweet



  def send_retweet_notification
    tweet=Tweet.find(self.parent_tweet_id)
    notification = Notification.create(recipient:tweet.user,actor:Current.user,action:"retweet",notifiable: self)
    #binding.pry
    NotificationRelayJob.perform_later(notification)
    notify(notification)
  end

  def broadcast_tweet_retweet
    if self.tweet_type == "tweet"
      broadcastTweet(self)
    elsif self.tweet_type == "reply"
      broadcastRetweet(self)
    end
  end

end