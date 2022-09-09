class TweetsController<ApplicationController

  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  include NotificationHelper
  include BroadcastTweetHelper

  def index
    @tweets = Tweet.all.order("created_at DESC")
    @tweet = current_user.tweets.new
  end

  def show
    @tweet= Tweet.find(params[:id])
  end


  def create
    @tweet =current_user.tweets.new(tweet_params)

    respond_to do |format|
      if @tweet.save
        format.turbo_stream
        #   redirect_to root_path,notice: "Post created"
      else
        flash[:error]="Wrong inputs!! Something is missing"
        render :index
      end
    end
    broadcastTweet(@tweet)
  end

  def destroy
    @tweet = current_user.tweets.find(params[:id])
    @tweet.destroy
    redirect_to profile_path, status: 303
  end

  def like
    @tweet= Tweet.find(params[:id])
    current_user.like(@tweet)
  end

  def like_button
    respond_to do |format|
      format.turbo_stream
    end
  end

  def retweet
    @tweet= Tweet.find(params[:id])

    @retweet=current_user.tweets.new(tweet_id:@tweet.id,user_id:current_user.id)
    #create notification for user
    notification= Notification.create(recipient:@tweet.user,actor:current_user,action:"retweet",notifiable:@retweet)
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
  end

  def likeables
    @tweet= Tweet.find(params[:id])
  end

  private

  def tweet_params
    params.require(:tweet).permit(:body,:tweet_id,:tweet_image)
  end

end