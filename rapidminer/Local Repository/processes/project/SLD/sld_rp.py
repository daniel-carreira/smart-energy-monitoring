import fhmm_model as fhmm
import pandas as pd
import matplotlib.pyplot as plt
import requests

API_ENDPOINT = 'http://backend.test/api'

def rm_main(dataset,testDF,consumptionsDF,apiInfo):
    
    equipments = dataset.keys()[2:]
    
    #list_of_appliance = ['app1','app2','app3','app4']
    fhmms = fhmm.FHMM()
    fhmms.train(dataset, equipments)
    fhmms.save("fhmm_trained_model")
    prediction = fhmms.disaggregate(testDF)
    #prediction.plot()
    #plt.show()
    #print(prediction)
    url = apiInfo.url[0]
    token = apiInfo.access_token
    user_id = int(apiInfo.user_id[0])
 
    
    class Api:
        def __init__(self, endpoint, access_token):
            self.endpoint = endpoint
            self.HEADERS = {'Authorization': f'Bearer {access_token}'}


        def post_observation(self, equipmentIDs, consumptions, consumption_id,userId):
            DATA = {'consumption_id': consumption_id, 'equipments': equipmentIDs, 'consumptions': consumptions}
            response = requests.post(f'{self.endpoint}/users/{userId}/observations', json=DATA, headers=self.HEADERS)
            if (200 <= response.status_code < 300):
                return response.json()

            raise Exception(
                f'POST Request to \'{self.endpoint}/users/{userId}/observations\' failed. Status code: {response.status_code}')


    api = Api(url, token[0])

    equipmentIDs = []
    for i in range(len(equipments)):
        equipmentIDs.append(int(equipments[i].split("appliance")[1]))


    consumptions= []
    for i in range(len(prediction)):
        for idx, equipment in enumerate(prediction.columns.values):
            consumptions.append(prediction.values[i][idx])
        api.post_observation(equipmentIDs,consumptions,int(consumptionsDF.id[i]),int(consumptionsDF.user_id[i]))
        consumptions = []
        


    #print(prediction)

    

   