import consumer from "./consumer"

consumer.subscriptions.create("UserChannel", {
  connected() {

  },

  disconnected() {

  },

  received(data) {
    if (window.location.pathname == "/users/dashboard"){
      if (data.update){
        $.get( "/users/refresh_table", function( data ) {});
      }
    }
    
    // $("#dashboard_table").load(location.href + " #dashboard_table");

  }
});
