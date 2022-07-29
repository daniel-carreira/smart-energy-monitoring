#include "clock.h"

long getTimestampOfNow(WiFiClient client) {
  HTTPClient http;
  http.begin(client, "http://showcase.api.linx.twenty57.net/UnixTime/tounix?date=now");
  int responseCode = http.GET();

  if (responseCode > 0) {
	String payload = http.getString();
	return payload.substring(1, payload.length() - 1).toInt();
  }

  http.end();
  return 0;
}