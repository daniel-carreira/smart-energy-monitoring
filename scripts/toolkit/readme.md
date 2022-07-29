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
Here you can either use the SEM Toolkit, or the testing script.

### SEM Toolkit
Allows you to make individual reads and watch the realtime evaluation.

```bash
py toolkit.py
```

| File   | Type       | Description                           |
| :---------- | :--------------- | :---------------------------------- |
| `data/train_data.csv`| `csv` | **Dataset** used in the model training |

### Testing script
Allows you to specify your training and testing datasets.

```bash
py test.py
```
| File   | Type       | Description                           |
| :---------- | :--------------- | :---------------------------------- |
| `data/train_data.csv`| `csv` | **Dataset** used in the model training |
| `data/test_data.csv`| `csv` | **Dataset** used in the model testing |

## Referência

 - [SLD Python Library](https://github.com/amzkit/load-disaggregation)
 


## License
[MIT](https://choosealicense.com/licenses/mit/)