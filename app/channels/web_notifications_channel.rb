class WebNotificationsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "web_notifications_channel"
    current_user.update(online: true)
  end
  
  def unsubscribed
    current_user.update(online: false)
    ActionCable.server.broadcast 'user_channel_' + User.first.id.to_s, update: current_user.id
  end
  
end