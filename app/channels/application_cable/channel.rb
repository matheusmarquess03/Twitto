module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def subscribed
      stream_from "notifications:#{current_user.id}"
    end

    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
      stop_all_streams
    end
  end
end
