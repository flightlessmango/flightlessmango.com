class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_channel_#{current_user.id}"
  end
  
  def unsubscribed
  end
end