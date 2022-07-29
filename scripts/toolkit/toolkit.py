from threading import Thread
import pwinput
import requests
import time
from datetime import datetime
from paho.mqtt import client as mqtt_client
import random
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from lib import fhmm_model as fhmm
import pandas as pd

plt.style.use('fivethirtyeight')


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

    def get_user_equipments(self):
        response = requests.get(
            f'{self.endpoint}/users/{self.id}/equipments', headers=self.HEADERS)

        if (200 <= response.status_code < 300):
            return response.json()['data']

        raise Exception(
            f'GET Request to \'{self.endpoint}/users/{self.id}/equipments\' failed. Status code: {response.status_code}')

    def post_user_training_examples(self, equipment_id, start, end, individual=False):
        DATA = {'start': start, 'end': end, 'equipments_on': [
            equipment_id], 'individual': individual}
        response = requests.post(
            f'{self.endpoint}/users/{self.id}/training-examples', json=DATA, headers=self.HEADERS)

        if (200 <= response.status_code < 300):
            return response.json()

        raise Exception(
            f'POST Request to \'{self.endpoint}/users/{self.id}/training-examples\' failed. Status code: {response.status_code}')


class Menu:
    @staticmethod
    def draw(title, options):
        print(f'\n-------- {title} ---------')
        for key in options.keys():
            print(key, '-', options[key])


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

    def publish(self, topic, msg=''):
        self.client.publish(topic, msg)

    def subscribe(self, topic):
        def on_message(client, userdata, msg):
            x_axis.append(datetime.now())
            y_axis.append(float(msg.payload.decode()))

        self.client.subscribe(topic)
        self.client.on_message = on_message

    def unsubscribe(self, topic):
        self.client.unsubscribe(topic)


def animate(i):
    plt.clf()
    plt.plot(x_axis, y_axis)
    plt.xticks(rotation=45)
    plt.xlabel('Time')
    plt.ylabel('Watts')


def animate_prediction(i):
    if len(time_axis) != len(prediction_axis['Total']):
        return

    x = time_axis.copy()
    y = prediction_axis.copy()

    plt.clf()

    # EACH EQUIPMENT
    for equipment, predictions_equipment in y.items():
        plt.plot(x, predictions_equipment, label=equipment)

    plt.xticks(rotation=45)
    plt.xlabel('Time')
    plt.ylabel('Watts')
    plt.legend(loc='upper right')


def individual_read():
    # MENU OPTIONS
    equipments = api.get_user_equipments()
    menu_options = {}
    for i in range(len(equipments)):
        menu_options[i + 1] = equipments[i]['name']

    # MENU
    Menu.draw('EQUIPMENTS', menu_options)
    option = input('Option: ')
    if not option.isnumeric():
        return

    option = int(option)

    # TARGET EQUIPMENT
    target_equipment = equipments[option - 1]

    broker.publish(f'{api.id}/tare')
    print("\nCalibrating...")
    time.sleep(5)

    print(
        f'Turn ON the \'{target_equipment["name"]}\'. Press enter when it\'s ON...', end='')
    input()

    x_axis.clear()
    y_axis.clear()
    x_axis.append(datetime.now())
    y_axis.append(0)

    broker.subscribe(f'{api.id}/power')

    start = int(time.time())

    # SHOW LIVE GRAPH
    ani = FuncAnimation(plt.gcf(), animate, interval=1000)
    plt.show()

    print('Posting results to API... ', end='')
    broker.unsubscribe(f'{api.id}/power')
    broker.publish(f'{api.id}/reset')
    end = int(time.time())
    api.post_user_training_examples(
        target_equipment['id'], start, end, True)
    print('Done')


def animate_graph():
    ani = FuncAnimation(plt.gcf(), animate_prediction, interval=1000)
    plt.show()


def realtime():
    broker.publish(f'{api.id}/tare')
    time.sleep(5)

    broker.subscribe(f'{api.id}/power')

    train = pd.read_csv("./data/train_data.csv")
    data = {'timestamp': x_axis, 'power': y_axis}

    list_of_appliance = train.keys()[2:]
    fhmms = fhmm.FHMM()

    # TRAIN MODEL
    fhmms.train(train, list_of_appliance)

    thread = Thread(target=animate_graph, args=())
    thread_not_started = True

    try:
        # WAIT FOR TESTING DATA
        while (len(x_axis) == 0):
            pass

        # REALTIME ANALISYS
        while (thread.is_alive() or thread_not_started):
            # APPLY MODEL
            test = pd.DataFrame(data=data)
            predictions = fhmms.disaggregate(test)
            predictions.to_csv('./data/results.csv', sep=';')

            time_axis.clear()
            time_axis.extend(predictions.index.array)

            for equipment in predictions.columns.values:
                prediction_axis[equipment] = predictions[equipment].values

            prediction_axis['Total'] = y_axis.copy()

            if thread_not_started:
                thread.start()
                thread_not_started = False

            time.sleep(1)
    except KeyboardInterrupt:
        pass

    thread.join()

    broker.unsubscribe(f'{api.id}/power')
    broker.publish(f'{api.id}/reset')


# ENV
API_ENDPOINT = '<API_ENDPOINT>'
BROKER_ENDPOINT = 'broker.hivemq.com'
BROKER_PORT = 1883

# GLOBAL VARIABLES
x_axis = []
y_axis = []

time_axis = []
prediction_axis = {}

try:
    # START
    print('---- S.E.M Toolkit ----')

    api = Api(API_ENDPOINT)

    # AUTHENTICATION
    username = input('Username: ')
    password = pwinput.pwinput()
    api.login(username, password)
    print('-----------------------')

    # MQTT BROKER
    broker = Broker(BROKER_ENDPOINT, BROKER_PORT)
    broker.connect()

    # MENU OPTIONS
    menu_options = {
        1: 'Individual Read',
        2: 'Realtime',
        3: 'Exit'
    }

    while (True):
        # MENU
        Menu.draw('MENU', menu_options)
        option = input('Option: ')
        if not option.isnumeric():
            continue

        option = int(option)

        if option == 1:
            individual_read()
        elif option == 2:
            realtime()
        elif option == 3:
            exit()

except Exception as e:
    print(f'[Exception] {e}')
