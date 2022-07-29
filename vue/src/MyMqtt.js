import mqtt from "mqtt";

export default {
  client: null,
  topics: [],
  connection: {
    host: "broker.hivemq.com",
    port: 8000,
    endpoint: "/mqtt",
    clean: true, // Reserved session
    connectTimeout: 1000000, // Time out
    reconnectPeriod: 900000, // Reconnection interval
    clientId: "clientID-" + Math.round(Math.random() * 10000),
    username: "",
    password: "",
  },
  connect(callback) {
    // ws unencrypted WebSocket connection
    // wss encrypted WebSocket connection
    const { host, port, endpoint, ...options } = this.connection;
    const connectUrl = `ws://${host}:${port}${endpoint}`;
    try {
      this.client = mqtt.connect(connectUrl, options);
    } catch (error) {
      console.log("mqtt.connect error", error);
    }
    this.client.on("connect", () => {
      this.subscribe(this.topics);
      console.log("Connection succeeded!");
    });
    this.client.on("error", (error) => {
      console.log("Connection failed", error);
    });
    this.client.on("message", (topic, message) => {
      callback(topic, message)
    });
  },
  subscribe(topics) {
    for (let i = 0; i < topics.length; i++) {
      let found = false;

      for (let j = 0; j < this.topics.length; j++) {
        if (topics[i] === this.topics[j]) {
          found = true;
          break;
        }
      }
      if (!found) {
        this.topics.push(topics[i]);
      }
    }

    topics.forEach((topic) => {
      this.client.subscribe(topic, 0, (error, res) => {
        if (error) {
          //console.log("Error subscribing to \"" + topic + "\"");
          return;
        }
        //console.log("Subscribed to \"" + topic + "\"");
      });
    });
  },
  unsubscribe(topics) {
    topics.forEach((topic) => {
      this.client.unsubscribe(topic, (error) => {
        if (error) {
          //console.log("Error unsubscribing to \"" + topic + "\"");
          return;
        }
        this.topics = this.topics.filter((item) => {
          return item != topic
        })
      });
    });
  },
  publish(topic, message) {
    this.client.publish(topic, message, 0, (error) => {
      if (error) {
        //console.log("Error publishing to \"" + topic + "\"");
        return;
      }
    });
  },
};