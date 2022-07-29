# AI Producer from project Smart Energy Monitoring

The main purpose is to determine the various equipment consumptions from the aggregate consumption.

## Installation

Use the package manager [pip](https://pip.pypa.io/en/stable/).

```bash
pip install pwinput
pip install requests
pip install paho-mqtt
pip install numpy
pip install hmmlearn
pip install matplotlib
```

## Usage

### Dataset Builder

Used to get all training examples and create an updated copy locally on **datasets** directory.
```bash
py dataset.py
```

### Energy Disaggregation

Used to get predictions from the training dataset + testing data and storing in the database.

```bash
py predictions.py
```

## Referência

 - [SLD Python Library](https://github.com/amzkit/load-disaggregation)

## License
[MIT](https://choosealicense.com/licenses/mit/)