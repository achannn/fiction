import consumer from "channels/consumer"

const channel = consumer.subscriptions.create({channel: "ChatsChannel", chapter_id: 20}, {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data)
  }
});

window.channel = channel;
