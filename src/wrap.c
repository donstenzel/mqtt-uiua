#include <stdint.h>
#include <MQTTClient.h>
#include <stdlib.h>
#include <string.h>

static MQTTClient client = NULL;

int create(const char* serverURI, const char* clientId) {
    if (client != NULL) {
        return -1;
    }

    return MQTTClient_create(&client, serverURI, clientId, MQTTCLIENT_PERSISTENCE_NONE, NULL);
}

int connect(const char* username, const char* password) {
    MQTTClient_connectOptions opts = MQTTClient_connectOptions_initializer;
    opts.username = username;
    opts.password = password;

    return MQTTClient_connect(client, &opts);
}

int disconnect() {
    return MQTTClient_disconnect(client, 60);
}

void destroy() {
    MQTTClient_destroy(&client);
}

int publish(const char* topic, int payloadlen, const void* payload, int qos, int retained, int* dt) {
    return MQTTClient_publish(client, topic, payloadlen, payload, qos, retained, dt);
}

int subscribe(const char* topic, int qos) {
    return MQTTClient_subscribe(client, topic, qos);
}

int unsubscribe(const char* topic) {
    return MQTTClient_unsubscribe(client, topic);
}

int receive(char** topic, int* topicLen, MQTTClient_message** payload, int timeout) {
    return MQTTClient_receive(client, topic, topicLen, payload, timeout);
}

unsigned char* get_payload(const MQTTClient_message* msg, int* out_len) {
    if (!msg) return NULL;
    unsigned char* buffer = malloc(msg->payloadlen);
    if (!buffer) return NULL;
    memcpy(buffer, msg->payload, msg->payloadlen);
    *out_len = msg->payloadlen;
    return buffer;
}

void free_msg(MQTTClient_message* msg) {
    MQTTClient_freeMessage(&msg);
}

int is_connected() {
    return MQTTClient_isConnected(client);
}

void wait(int dt, unsigned long timeout) {
    MQTTClient_waitForCompletion(client, dt, timeout);
}

void yield() {
    MQTTClient_yield();
}

int get_pending(int *out_tokens, int *out_length) {
    int *tokens = NULL;
    int rc = MQTTClient_getPendingDeliveryTokens(client, &tokens);
    if (rc != 0 || tokens == NULL) {
        out_tokens = NULL;
        *out_length = 0;
        return rc;
    }

    int count = 0;
    while (tokens[count] != -1) {
        count++;
    }

    out_tokens = malloc(sizeof(int) * count);
    if (!out_tokens) {
        free(tokens);
        out_tokens = NULL;
        *out_length = 0;
        return -1;
    }

    for (int i = 0; i < count; ++i) {
        out_tokens[i] = tokens[i];
    }

    free(tokens);

    *out_length = count;
    return 0;
}
