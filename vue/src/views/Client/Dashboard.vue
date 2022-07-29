<template>
  <div class="container mt-2 text-center" style="user-select: none">
    <v-card
      elevation="20"
      class="flex-grow-1 card-selectable"
      style="border-radius: 10px"
      @click="showDashboardModal"
    >
      <span style="font-size:2rem;font-weight: 400;color:#191645'">{{
        "Dashboard of " + user.name
      }}</span>
    </v-card>
    <div class="d-flex flex-wrap mt-4">
      <v-card
        elevation="6"
        class="flex-grow-1 card-selectable"
        style="border-radius: 10px"
        @click="showModal(0)"
      >
        <div class="text-card">
          <span>{{ consumptionValue }}</span>
          <span style="font-size: 3vw">W</span>
        </div>
        <div class="text-footer">{{ consumptionTime }}</div>
      </v-card>
      <v-card
        elevation="6"
        class="flex-grow-1 card-selectable"
        style="border-radius: 10px; margin-left: 20px; padding-right: 2vw"
        @click="showModal(3)"
      >
        <div class="text-card">
          <span>{{ kWh.value }}</span>
          <span style="font-size: 3vw">kWh</span>
        </div>
        <div class="d-flex justify-content-between">
          <div class="text-footer">{{ kWh.timestamp }}</div>
          <div style="margin-left: 2vw">
            {{ (user.energy_price * kWh.value).toFixed(2) }}€
          </div>
        </div>
      </v-card>
    </div>
    <v-card
      class="mt-4 card-selectable"
      elevation="6"
      style="border-radius: 10px"
      @click="showModal(1)"
    >
      <div class="text-card">
        <font-awesome-icon
          icon="fa-solid fa-location-dot"
          style="margin-right: 2vw"
        />
        <span>{{ divisionValue }}</span>
      </div>
      <div class="text-footer">{{ divisionTime }}</div>
    </v-card>
    <v-card
      class="mt-4 card-selectable"
      elevation="3"
      style="border-radius: 10px"
      @click="showModal(2)"
    >
      <div class="text-card">
        <font-awesome-icon
          icon="fa-solid fa-plug-circle-bolt"
          style="margin-right: 2vw"
        />
        <span>{{ equipmentValue }}</span>
      </div>
      <div class="text-footer">{{ equipmentTime }}</div>
    </v-card>

    <!-- MODAL -->
    <b-modal ref="graph-modal" hide-footer centered size="xl">
      <template #modal-title>
        {{ modalTitle }}
      </template>

      <div data-app></div>
      <v-select
        v-if="cardClicked == 2"
        data-app
        v-model="divisionSelected"
        :items="divisionsFilter"
        label="Filter by Division"
        filled
        solo
      />

      <div v-if="cardClicked == 0" class="d-flex">
        <v-select
          class="flex-grow-1"
          v-model="typeSelected"
          :items="typeFilter"
          item-text="name"
          return-object
          data-app
          filled
          solo
        />

        <!-- BUTTON START -->
        <b-button
          v-b-modal.modal-calibration
          class="action-button"
          variant="primary"
        >
          <font-awesome-icon icon="fa-solid fa-bolt" size="lg" />
        </b-button>
      </div>

      <!-- CHART -->
      <apexchart
        v-if="cardClicked != null"
        width="100%"
        height="auto"
        :options="chartOptions"
        :series="chartSeries"
      />
    </b-modal>

    <!-- MODAL -->
    <b-modal ref="modal-calibration" id="modal-calibration" hide-footer centered title="Calibration">
      <div class="d-flex">
        <v-text-field class="flex-grow-1" v-model="calibration" type="number" solo />
        <b-button
            class="action-button-modal"
            variant="success"
            @click="calibrationSave"
          >
            <font-awesome-icon icon="fa-solid fa-save" size="lg" />
        </b-button>
        <b-button
            class="action-button-modal"
            variant="danger"
            @click="calibrationRestore"
          >
            <font-awesome-icon icon="fa-solid fa-refresh" size="lg" />
        </b-button>
      </div>
    </b-modal>

    <!-- MODAL -->
    <b-modal ref="division-modal" hide-footer centered size="xl">
      <template #modal-title>
        {{ modalTitle }}
      </template>

      <v-card
        v-for="(item, idx) in division.value"
        :key="idx"
        class="mt-2"
        elevation="6"
        style="border-radius: 10px"
        @click=""
      >
        <div class="text-card-modal text-center p-2">
          <span>{{ item.name }}</span>
        </div>
      </v-card>
    </b-modal>

    <!-- MODAL -->
    <b-modal ref="user-modal" hide-footer centered size="xl">
      <template #modal-title> Dashboard </template>

      <v-card
        v-for="(item, idx) in users"
        :key="idx"
        class="mt-2"
        elevation="6"
        style="border-radius: 10px"
        v-if="item.id != user.id"
        @click="changeUser(item)"
      >
        <div class="text-card-modal text-center p-2">
          <span>{{ (item.id == userId ? "(Me) " : "") + item.name }}</span>
        </div>
      </v-card>
    </b-modal>

    <b-modal ref="getStartedModal" title="Get Started" centered>
      <span class="getStartedModal"
        >Hi! <br />This is the dashboard page where it is possible
        to see the most varied information! <br />To start using the system
        correctly, configuration is needed. To do that, please access
        the
        <b v-if="get_started == 0 || get_started == 1"
          ><router-link :to="{ name: 'settings' }">Settings</router-link>
        </b>
        <b v-if="get_started == 2"
          ><router-link :to="{ name: 'read' }">Equipment reads</router-link>
        </b>
        page marked with a red mark.
      </span>
    </b-modal>
  </div>
</template>

<script>
import axios from "axios";
import mqtt from "../../MyMqtt";

export default {
  data() {
    return {
      //FULL DATA
      consumptions: [],
      divisions: [],
      equipments: [],
      kWhs: [],

      //LAST DATA
      consumption: {
        value: 0,
        timestamp: "",
      },
      division: {
        value: [],
        timestamp: "",
      },
      equipment: {
        value: [],
        timestamp: "",
      },
      kWh: {
        value: 0,
        timestamp: "",
      },

      chartOptions: {},
      chartSeries: [],

      cardClicked: null, //0 = Consumption, 1 = Expected Division, 2 = Equipments ON

      divisionsFilter: [],
      divisionSelected: "All Divisions",

      user: {},

      users: [],
      userSelected: {},

      typeSelected: { name: 'Live', interval: null },
      typeFilter: [
        { name: 'Live', interval: null },
        { name: 'Last minutes', interval: 'minute' },
        { name: 'Last hours', interval: 'hour' },
        { name: 'Last days', interval: 'day' },
      ],

      calibration: null,
    };
  },
  computed: {
    isLive() {
      return this.typeSelected.interval == null;
    },
    get_started() {
      return this.$store.getters.get_started;
    },
    userId() {
      return this.$store.getters.user_id;
    },
    consumptionValue() {
      return this.consumption.value;
    },
    consumptionTime() {
      if (!this.consumption.timestamp) return "";

      return this.formatDate(this.consumption.timestamp, true);
    },
    divisionValue() {
      return this.division.timestamp == "" ? "" : this.division.value.length;
    },
    divisionTime() {
      if (!this.division.timestamp) return "";

      return this.formatDate(this.division.timestamp, true);
    },
    equipmentValue() {
      return this.equipment.timestamp == "" ? "" : this.equipment.value.length;
    },
    equipmentTime() {
      if (!this.equipment.timestamp) return "";

      return this.formatDate(this.equipment.timestamp, true);
    },
    modalTitle() {
      if (this.cardClicked == null) return "";
      if (this.cardClicked === 0) return "Consumption";
      if (this.cardClicked === 1) return "Divisions With Activity";
      if (this.cardClicked === 2) return "Equipments Activity";
      if (this.cardClicked === 3) return "Monthly kWh";
    },
  },
  async created() {
    await this.$store.dispatch("fillStore");
    if (this.get_started < 3) {
      this.$store.dispatch("getAuthUser");
      this.showModal(4);
    }
    //MQTT
    //-> Connect to the MQTT Broker
    mqtt.connect(this.onMessage);
    //-> Subscribe to topics
    mqtt.subscribe([this.userId + "/power", this.userId + "/observation"]);

    await this.getAuthUser();
    this.getAffiliates();

    this.getKWhs();
    this.getLastNObservations(60);
  },
  methods: {
    initEnv() {
      //FULL DATA
      this.consumptions = [];
      this.divisions = [];
      this.equipments = [];
      this.kWhs = [];

      //LAST DATA
      this.consumption = {
        value: 0,
        timestamp: "",
      };
      this.division = {
        value: [],
        timestamp: "",
      };
      this.equipment = {
        value: [],
        timestamp: "",
      };
      this.kWh = {
        value: 0,
        timestamp: "",
      };
    },
    async onMessage(topic, message) {
      switch (topic) {
        //TOPIC: #/POWER
        case this.user.id + "/power":
          this.consumption = {
            value: message,
            timestamp: new Date(),
          };

          if (this.isLive) {
            this.addToArray(this.consumptions, this.consumption);

            if (this.cardClicked == 0) {
              this.loadChart(this.consumptions);
            }
          }

          break;

        //TOPIC: #/OBSERVATION
        case this.user.id + "/observation":
          await this.getLastNObservations(1);

          if (this.cardClicked == 2) {
            this.loadChart(this.getFilteredEquipments());
          }
          break;
      }
    },
    initChart() {
      this.chartOptions = {
        chart: {
          id: "chart",
          type: this.cardClicked == 3 ? "bar" : "area",
          stacked: true,
        },
        dataLabels: {
          enabled: false,
        },
        xaxis: {
          categories: [], // TIMESTAMP VALUES
          labels: {
            show: this.cardClicked == 3,
          },
        },
      };
      this.chartSeries = [];
    },
    loadChart(collection) {
      this.initChart();

      //LOAD TIMESTAMPS
      this.chartOptions.xaxis.categories = collection.map((item) => {
        return this.cardClicked == 3
          ? item.timestamp
          : this.formatDate(item.timestamp, true);
      });

      //LOAD SERIES
      //-> 1 Serie
      let array = collection.map((item) => {
        return item.value;
      });

      if (!Array.isArray(collection[0].value)) {
        this.chartSeries.push({
          name: "",
          data: array,
        });

        return;
      }

      //-> N Series
      const mapIdToName = this.getEquipmentsHashMap(collection);
      const mapIdToSerie = new Map();
      mapIdToName.forEach((value, key) => {
        const serie = {
          name: value,
          data: new Array(collection.length).fill(0),
        };
        this.chartSeries.push(serie);
        mapIdToSerie.set(key, serie);
      });

      collection.forEach((item, index) => {
        item.value.forEach((equipment) => {
          const serie = mapIdToSerie.get(equipment.id);
          serie.data[index] = equipment.value;
        });
      });
    },
    formatDate(dateStr, withFullDate) {
      if (dateStr == null || dateStr == "") return "";

      let date = new Date(
        dateStr.toString().length == 10 ? dateStr * 1000 : dateStr
      );
      let formatedDate = "";

      formatedDate = date.toLocaleDateString("pt", {
        timeZone: "Europe/Lisbon",
      });

      if (!withFullDate) return formatedDate;

      return (
        formatedDate +
        " " +
        date.toLocaleTimeString("pt-PT", { timeZone: "Europe/Lisbon" })
      );
    },
    addToArray(array, obj) {
      const MAX_ITEMS_ON_ARRAY = 100;

      if (array.length >= MAX_ITEMS_ON_ARRAY) {
        array.shift();
      }
      array.push(obj);
    },
    getLastNConsumptions(limit, interval) {
      return axios
        .get(`/users/${this.user.id}/consumptions?limit=${limit}&interval=${interval}`)
        .then((response) => {
          let data = response.data;

          for (let i = data.length - 1; i >= 0; i--) {
            this.consumption = {
              value: data[i].value,
              timestamp: data[i].timestamp,
            };
            this.addToArray(this.consumptions, this.consumption);
          }
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    getLastNObservations(limit) {
      return axios
        .get(`/users/${this.user.id}/observations?limit=${limit}`)
        .then((response) => {
          let dataArray = response.data;

          for (let i = dataArray.length - 1; i >= 0; i--) {
            let data = dataArray[i];

            let observation = data.observation;
            let consumption = data.consumption;

            //DIVISIONS
            this.division = {
              value: observation.expected_divisions,
              timestamp: consumption.timestamp,
            };
            this.addToArray(this.divisions, this.division);

            //EQUIPMENTS
            this.equipment = {
              value: [],
              timestamp: consumption.timestamp,
            };

            observation.equipments.forEach((item) => {
              if (item.consumption == 0) return;

              this.equipment.value.push({
                id: item.id,
                name: item.name,
                value: item.consumption,
                division: item.division,
              });
            });

            this.addToArray(this.equipments, this.equipment);
            this.refreshDivisionsFilterContent();
          }
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    getAuthUser() {
      return axios
        .get(`/user`)
        .then((response) => {
          this.user = response.data;
          this.users = [this.user];
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    getAffiliates() {
      return axios
        .get(`/users/${this.userId}/affiliates`)
        .then((response) => {
          this.users = [...this.users, ...response.data];
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    getKWhs() {
      return axios
        .get(`/users/${this.user.id}/statistics/kwh?months=6`)
        .then((response) => {
          this.kWhs = response.data.reverse();

          this.kWh = this.kWhs[this.kWhs.length - 1];
          this.kWh.value =
            Math.round(parseFloat(this.kWh.value.replaceAll(",", "")) * 100) /
            100;
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    showModal(cardNumber) {
      this.cardClicked = cardNumber;

      switch (cardNumber) {
        case 0:
          if (this.consumptions.length == 0) return;

          this.loadChart(this.consumptions);
          this.$refs["graph-modal"].show();
          break;

        case 1:
          if (this.division.value.length == 0) return;

          this.$refs["division-modal"].show();
          break;

        case 2:
          if (this.equipments.length == 0) return;

          this.loadChart(this.equipments);
          this.$refs["graph-modal"].show();
          break;

        case 3:
          if (this.kWhs.length == 0) return;

          this.loadChart(this.kWhs);
          this.$refs["graph-modal"].show();
          break;
        case 4:
          this.$refs["getStartedModal"].show();
          break;
      }
    },
    getEquipmentsHashMap(collection) {
      const map = new Map();

      collection.forEach((list) => {
        list.value.forEach((item) => {
          map.set(item.id, item.name);
        });
      });

      return map;
    },
    refreshDivisionsFilterContent() {
      const array = ["All Divisions"];

      this.equipments.forEach((list) => {
        list.value.forEach((item) => {
          array.push(item.division);
        });
      });

      this.divisionsFilter = [...new Set(array)];
    },
    getFilteredEquipments() {
      const equipmentsClone = JSON.parse(JSON.stringify(this.equipments));

      if (this.divisionSelected == "All Divisions") {
        return equipmentsClone;
      }

      //EACH OBSERVATION
      equipmentsClone.forEach((observation) => {
        //EACH OBSERVATION EQUIPMENT
        observation.value = observation.value.filter((obsEquipment) => {
          return obsEquipment.division == this.divisionSelected;
        });
      });

      return equipmentsClone;
    },
    changeUser(selected) {
      mqtt.unsubscribe([
        this.user.id + "/power",
        this.user.id + "/observation",
      ]);
      this.initEnv();
      this.$refs["user-modal"].hide();

      this.user = selected;
      mqtt.subscribe([this.user.id + "/power", this.user.id + "/observation"]);
      this.getKWhs();
      this.getLastNObservations(60);
    },
    showDashboardModal() {
      if (this.users.length > 1) this.$refs["user-modal"].show();
    },
    calibrationSave() {
      mqtt.publish(`${this.userId}/calibration`, this.calibration);
      this.$refs["modal-calibration"].hide();
      this.calibration = null;
    },
    calibrationRestore() {
      mqtt.publish(`${this.userId}/calibration`, "default");
      this.$refs["modal-calibration"].hide();
      this.calibration = null;
    }
  },
  watch: {
    divisionSelected(newVal, oldVal) {
      this.loadChart(this.getFilteredEquipments());
    },
    typeSelected(newVal, oldVal) {
      this.consumptions = [];
      
      if (newVal.interval != null) {
        this.getLastNConsumptions(60, newVal.interval)
          .then(() => {
            this.loadChart(this.consumptions);
          })
      }
    },
  },
};
</script>

<style scoped>
.text-card {
  font-size: 5.5vw;
  color: #191645;
}

.text-card-modal {
  font-size: 30px;
  color: #191645;
}

.text-footer {
  color: grey;
  text-align: left;
  margin-left: 2vw;
  padding-bottom: 1vh;
  font-size: 16px;
}

h3 {
  font-size: 1.3rem;
}

.card-text {
  font-size: 1.3rem;
  font-family: "Trebuchet MS", Helvetica, sans-serif;
  font-weight: 500;
}

.card-timestamp {
  font-size: 2.5rem;
  font-weight: 500;
  font-family: Tahoma, Geneva, sans-serif;
  font-size: 23px;
  letter-spacing: 0px;
  word-spacing: 0px;
  color: black;
  font-weight: 400;
  font-family: "Trebuchet MS", Helvetica, sans-serif;
}

.card-selectable {
  cursor: pointer;
  transition: transform 200ms;
}

.card-selectable:hover {
  transform: scale(1.02);
  z-index: 1;
}

.getStartedModal {
  font-size: 20px;
}

.action-button {
  width: 57px;
  height: 57px;
  margin-left: 10px;
}

.action-button-modal {
  width: 50px;
  height: 50px;
  margin-left: 10px;
}
</style>