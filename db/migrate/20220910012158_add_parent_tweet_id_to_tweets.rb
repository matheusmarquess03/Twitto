class AddParentTweetIdToTweets < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :parent_tweet_id, :integer
    remove_column :tweets, :reply_id, :integer
    remove_column :tweets, :retweet_id, :integer
  end
end
