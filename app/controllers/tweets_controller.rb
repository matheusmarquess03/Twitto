class TweetsController<ApplicationController

  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  include NotificationHelper
  include BroadcastTweetHelper

  def index
    @tweets = Tweet.followers_tweets
    @tweet = current_user.tweets.new
  end

  def show
    @tweet = Tweet.find(params[:id])
    @replies = Tweet.get_replies(params[:id])
  end


  def create
    @tweet = current_user.tweets.new(tweet_params)

    respond_to do |format|
      if @tweet.save
        format.turbo_stream
        #   redirect_to root_path,notice: "Post created"
      else
        flash[:error]="Wrong inputs!! Something is missing"
        format.html {render :index}
      end
    end
    broadcastTweet(@tweet)
  end

  def destroy
    @tweet = current_user.tweets.find(params[:id])
    @tweet.destroy
    redirect_to profile_path, status: 303 #check staus: :no_content
  end

  def like
    @tweet = Tweet.find(params[:id])
    current_user.like(@tweet)
  end

  def like_button
    respond_to do |format|
      format.turbo_stream
    end
  end

  def retweet
    @tweet = Tweet.find(params[:id])


    @retweet = current_user.tweets.new(parent_tweet_id:@tweet.id,tweet_type: "retweet")
    #create notification for user
    notification = Notification.create(recipient:@tweet.user,actor:current_user,action:"retweet",notifiable:@retweet)
    NotificationRelayJob.perform_later(notification)
    respond_to do |format|
      if @retweet.save
        format.turbo_stream
      else
        format.html{redirect_back fallback_location:@tweet,alert:"Something went wrong while retweeting"}
      end
    end

    broadcastRetweet(@retweet)
    notify(notification)

    #binding.pry

  end

  def likeables
    @tweet= Tweet.find(params[:id])
  end

  def reply
    @tweet = Tweet.find(params[:id])
    @reply = current_user.tweets.create(parent_tweet_id:@tweet.id,body:params[:body],tweet_image: params[:tweet_image],tweet_type: "reply")

    respond_to do |format|
      if @reply.save
        format.turbo_stream
      else
        flash[:error]="Wrong inputs!! Something is missing"
        render :index
      end
    end
  end


  private


  def tweet_params
    params.require(:tweet).permit(:body,:tweet_image,:parent_tweet_id)
  end

end