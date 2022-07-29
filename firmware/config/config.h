#ifndef _CONFIG_
#define _CONFIG_

// SENSOR SCT-013
#define PIN_SCT 34

// HOME VOLTAGE (230v EU, 120v USA)
#define HOME_VOLTAGE 230


const String API_ENDPOINT = "http://smartenergymonitoring.dei.estg.ipleiria.pt/api";

const char MQTT_HOST[] = "broker.hivemq.com";
int MQTT_HOST_PORT = 1883;

#endif