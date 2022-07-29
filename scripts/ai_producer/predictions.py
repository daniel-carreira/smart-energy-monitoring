import queue
import pwinput
import requests
from datetime import datetime
from paho.mqtt import client as mqtt_client
import random
from lib import fhmm_model as fhmm
import pandas as pd
import time


class Api:
    """
    Attributes
    ----------
    endpoint : string
    id : int
    HEADERS : dict
    """

    def __init__(self, endpoint):
        self.endpoint = endpoint

    def login(self, username, password):
        DATA = {'username': username, 'password': password}
        response = requests.post(f'{self.endpoint}/login', data=DATA)

        if (200 <= response.status_code < 300):
            response_json = response.json()
            self.HEADERS = {
                'Authorization': f'Bearer {response_json["access_token"]}'}
            self.id = self.get_user()['id']
            return response_json

        raise Exception(
            f'POST Request to \'{self.endpoint}/login\' failed. Status code: {response.status_code}')

    def get_user(self):
        response = requests.get(f'{self.endpoint}/user', headers=self.HEADERS)
        if (200 <= response.status_code < 300):
            return response.json()

        raise Exception(
            f'GET Request to \'{self.endpoint}/user\' failed. Status code: {response.status_code}')

    def get_clients(self):
        response = requests.get(
            f'{self.endpoint}/users?type=c', headers=self.HEADERS)
        if (200 <= response.status_code < 300):
            return response.json()['data']

        raise Exception(
            f'GET Request to \'{self.endpoint}/users?type=c\' failed. Status code: {response.status_code}')

    def get_user_consumptions(self, userID):
        response = requests.get(
            f'{self.endpoint}/users/{userID}/consumptions?limit=12&observation=0', headers=self.HEADERS)

        if (200 <= response.status_code < 300):
            return response.json()['data']

        raise Exception(
            f'GET Request to \'{self.endpoint}/users/{userID}/equipments\' failed. Status code: {response.status_code}')

    def post_user_observation(self, userID, consumptionID, equipments, consumptions):
        DATA = {
            'consumption_id': consumptionID,
            'equipments': equipments,
            'consumptions': consumptions
        }
        response = requests.post(
            f'{self.endpoint}/users/{userID}/observations', json=DATA, headers=self.HEADERS)

        if (200 <= response.status_code < 300):
            return response.json()['data']

        raise Exception(
            f'POST Request to \'{self.endpoint}/users/{userID}/observations\' failed. Status code: {response.status_code}')


class Broker:
    """
    Attributes
    ----------
    endpoint : string
    port : int
    client : paho.mqtt.client
    """

    def __init__(self, endpoint, port):
        self.endpoint = endpoint
        self.port = port

    def connect(self):
        def on_connect(client, userdata, flags, rc):
            if rc != 0:
                raise Exception(
                    f'CONNECTION to MQTT BROKER in \'{BROKER_ENDPOINT}:{BROKER_PORT}\' failed')

        client = mqtt_client.Client(f'toolkit-mqtt-{random.randint(0, 100)}')
        client.on_connect = on_connect
        client.connect(BROKER_ENDPOINT, BROKER_PORT)
        client.loop_start()
        self.client = client

    def subscribe(self, topic):
        def on_message(client, userdata, msg):
            client_queue.append(int(float(msg.payload.decode())))

        self.client.subscribe(topic)
        self.client.on_message = on_message

    def publish(self, topic, msg=''):
        self.client.publish(topic, msg)


# ENV
API_ENDPOINT = 'http://smartenergymonitoring.dei.estg.ipleiria.pt/api'
BROKER_ENDPOINT = 'broker.hivemq.com'
BROKER_PORT = 1883

# GLOBAL VARIABLES
x_axis = []
y_axis = []

client_queue = []

try:
    # START
    print('---- SEM Energy Disaggregation ----')

    api = Api(API_ENDPOINT)

    # -> AUTHENTICATION
    username = input('Username: ')
    password = pwinput.pwinput()
    api.login(username, password)
    print('-----------------------')

    # -> MQTT BROKER
    broker = Broker(BROKER_ENDPOINT, BROKER_PORT)
    broker.connect()
    broker.subscribe('/post')

    while True:

        while len(client_queue) > 0:
            client = client_queue[0]
            client_queue = client_queue[1:]

            print(
                f'[{datetime.now().strftime("%d/%m/%Y %H:%M:%S")}] CLIENT {client} - LOADING')

            # TRAIN MODEL
            try:
                train = pd.read_csv(f"./datasets/{client}.csv")
                if len(train) == 0:
                    print(
                        f'[{datetime.now().strftime("%d/%m/%Y %H:%M:%S")}] CLIENT {client} - SKIPPED')
                    continue

                list_of_appliance = train.keys()[2:]
                fhmms = fhmm.FHMM()

                fhmms.train(train, list_of_appliance)

                # TEST DATA
                consumptions = api.get_user_consumptions(client)
                if len(consumptions) == 0:
                    print(
                        f'[{datetime.now().strftime("%d/%m/%Y %H:%M:%S")}] CLIENT {client} - SKIPPED')
                    continue

                x_axis = []
                y_axis = []
                for consumption in consumptions:
                    x_axis.append(consumption["timestamp"])
                    y_axis.append(consumption["value"])

                data = {'timestamp': x_axis, 'power': y_axis}
                test = pd.DataFrame(data=data)

                # APPLY MODEL
                predictions = fhmms.disaggregate(test)

                # CONCLUSION
                obs_indexes = []
                obs_values = []

                for equipment in predictions.columns.values:
                    obs_indexes.append(equipment)
                    obs_values.append(predictions[equipment].values[1])

                api.post_user_observation(
                    client, consumptions[1]['id'], obs_indexes, obs_values)
                broker.publish(f'{client}/observation')

                print(
                    f'[{datetime.now().strftime("%d/%m/%Y %H:%M:%S")}] CLIENT {client} - DONE')
                print()

            except FileNotFoundError:
                continue


except Exception as e:
    print(f'[Exception] {e}')
