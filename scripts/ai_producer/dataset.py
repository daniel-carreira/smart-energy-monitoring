from email import header
import pwinput
import requests
from datetime import datetime
from paho.mqtt import client as mqtt_client
import random
from lib import fhmm_model as fhmm
import pandas as pd
import numpy as np


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

    def get_user_training_examples(self, userID):
        response = requests.get(
            f'{self.endpoint}/users/{userID}/training-examples', headers=self.HEADERS)

        if (200 <= response.status_code < 300):
            return response.json()['data']

        raise Exception(
            f'GET Request to \'{self.endpoint}/users/{userID}/training-examples\' failed. Status code: {response.status_code}')

    def get_user_equipments(self, userID):
        response = requests.get(
            f'{self.endpoint}/users/{userID}/equipments', headers=self.HEADERS)

        if (200 <= response.status_code < 300):
            return response.json()['data']

        raise Exception(
            f'GET Request to \'{self.endpoint}/users/{userID}/equipments\' failed. Status code: {response.status_code}')


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
            client_queue.append(msg.payload.decode())

        self.client.subscribe(topic)
        self.client.on_message = on_message

    def publish(self, topic, msg=''):
        self.client.publish(topic, msg)


def dataToDataframe(examples, equipments):
    headers = ['timestamp', 'power']
    equipment_ids = [equipment['id'] for equipment in equipments]
    headers.extend(equipment_ids)
    data = []

    row = np.zeros(len(equipments) + 2)

    mapper = np.array(equipment_ids)

    lastTimestamp = 0
    if len(examples) > 0:
        lastTimestamp = examples[0]['time']
        row[0] = examples[0]['time']
        row[1] = examples[0]['consumption']

    for example in examples:
        if lastTimestamp != example['time']:
            lastTimestamp = example['time']
            data.append(row)
            row = np.zeros(len(equipments) + 2)

            # timestamp
            row[0] = example['time']
            # total
            row[1] = example['consumption']

        # n equipments
        arrayIdx = np.where(mapper == example['equipment_id'])
        row[arrayIdx[0] + 2] = example['consumption'] if example['equipment_status'] == 'ON' else 0

    DATA_AUGMENTATION = 1

    if DATA_AUGMENTATION > 0:
        for next in range(1, len(data)):
            current = next - 1

            augmented = []
            for idx in range(len(equipments) + 2):
                arr = np.linspace(data[current][idx], data[next]
                                  [idx], num=DATA_AUGMENTATION + 2)[1:-1]
                augmented.append(np.round(arr, 2))

            for pos in range(DATA_AUGMENTATION):
                # ADD NEW ROW
                row = []
                for idx in range(len(equipments) + 2):
                    row.append(augmented[idx][pos])

                data.append(row)

    return pd.DataFrame(data, columns=headers)


# ENV
API_ENDPOINT = 'http://smartenergymonitoring.dei.estg.ipleiria.pt/api'
BROKER_ENDPOINT = 'broker.hivemq.com'
BROKER_PORT = 1883

client_queue = []

try:
    # START
    print('---- SEM Dataset Builder ----')

    api = Api(API_ENDPOINT)

    # -> AUTHENTICATION
    username = input('Username: ')
    password = pwinput.pwinput()
    api.login(username, password)
    print('-----------------------')

    # -> MQTT BROKER
    broker = Broker(BROKER_ENDPOINT, BROKER_PORT)
    broker.connect()
    broker.subscribe('/training')

    # PROCCESS
    while True:
        while len(client_queue) > 0:
            client = client_queue[0]
            client_queue = client_queue[1:]

            print(
                f'[{datetime.now().strftime("%d/%m/%Y %H:%M:%S")}] CLIENT {client} - LOADING')

            equipments = api.get_user_equipments(client)
            examples = api.get_user_training_examples(client)

            df = dataToDataframe(examples, equipments)
            df['timestamp'] = df['timestamp'].astype('int')
            df.to_csv(f'./datasets/{client}.csv', index=False)

            print(
                f'[{datetime.now().strftime("%d/%m/%Y %H:%M:%S")}] CLIENT {client} - DONE')
            print()

except Exception as e:
    print(f'[Exception] {e}')
