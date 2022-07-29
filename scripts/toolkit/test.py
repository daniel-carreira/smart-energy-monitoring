from lib import fhmm_model as fhmm
import pandas as pd

try:

    train = pd.read_csv(f"./data/train_data.csv")
    list_of_appliance = train.keys()[2:]

    fhmms = fhmm.FHMM()

    fhmms.train(train, list_of_appliance)

    # TEST DATA
    test = pd.read_csv(f"./data/test_data.csv")

    # APPLY MODEL
    predictions = fhmms.disaggregate(test)

    predictions.to_csv('./data/results.csv', sep=';')

except Exception as e:
    print(f'[Exception] {e}')
