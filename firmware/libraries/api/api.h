#ifndef _API_
#define _API_

#include <ArduinoJson.h>
#include <HTTPClient.h>

#define CREDENTIALS_SIZE 200
#define AUTH_SIZE 2000
#define POST_SIZE 700
#define USER_SIZE 700

struct Auth {
  static long expiresIn;
  static char *accessToken;
  static char *refreshToken;
};

// @POST /login
int login(WiFiClient client, String endpoint, const char* username, const char* password);

// @POST /refresh
void refresh(WiFiClient client, String endpoint, const char* token);

// @POST /users/{id}/consumptions
void postConsumptions(WiFiClient client, String endpoint, float *values, float *variances, long *timestamps, const int size);

// @GET /user
int getId(WiFiClient client, String endpoint);

#endif