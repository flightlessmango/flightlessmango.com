import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  connected() {
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    $('.progress .progress-bar').css("width", data + '%')
  }
});
