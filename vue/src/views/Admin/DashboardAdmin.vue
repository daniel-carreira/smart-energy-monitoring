<template>
  <b-container class="text-center">
    <!-- DATE PICKER -->
    <v-card class="px-4">
      <v-text-field type="date" v-model="infoDate"></v-text-field>
    </v-card>

    <!-- CARD GROUP -->
    <div class="orientation mt-4">

      <!-- OBSERVATIONS CARD -->
      <v-card elevation="6" class="flex-grow-1 card-selectable">
        <div class="text-card text-center">
          <span>Observations</span>
          <br>
          {{ infoStatistics.observations }}
        </div>
      </v-card>

      <!-- ALERTS CARD -->
      <v-card id="center-card" elevation="6" class="flex-grow-1 card-selectable">
        <div class="text-card text-center">
          <span>Alerts</span>
          <br>
          {{ infoStatistics.alerts }}
        </div>
      </v-card>

      <!-- CONSUMPTIONS CARD -->
      <v-card elevation="6" class="flex-grow-1 card-selectable">
        <div class="text-card text-center">
          <span>Consumptions</span>
          <br>
          {{ infoStatistics.consumptions }}
        </div>
      </v-card>

    </div>

    <!-- USERS GRAPH CARD -->
    <v-card elevation="6" class="mt-4 card-selectable d-flex justify-content-center p-3">
      <apexchart 
        width="380" 
        :options="userChartOptions" 
        :series="userSeries"
      />
    </v-card>

  </b-container>
</template>

<script>
import axios from "axios";
import Chart from "../../components/Chart.vue";

export default {
  components: { Chart },
  data() {
    return {
      chartOptions: {},
      userChartOptions: {},
      userStatistics: {},
      infoStatistics: {},
      userSeries: [],
      labelSeries: [],
      infoDate: Date.now(),
    };
  },
  methods: {
    getUsersStats() {
      axios
        .get(`statistics/users`)
        .then((response) => {
          this.userStatistics = response.data;

          Object.entries(response.data).forEach((item) => {
            this.labelSeries.push(
              item[0].charAt(0).toUpperCase() + item[0].slice(1)
            );
            this.userSeries.push(item[1]);
          });

          this.userChartOptions = {
            chart: {
              width: 380,
              type: "pie",
            },
            labels: this.labelSeries,
          };
        })
        .catch((error) => {
          console.log(error);
        });
    },
    getInfoFromDay() {
      let timestamp = Date.parse(this.infoDate) / 1000;

      axios.get(`statistics?timestamp=${timestamp}`)
        .then((response) => {
          this.infoStatistics = response.data;
        })
        .catch((error) => {
          console.log(error);
        });
    },
  },
  watch: {
    infoDate() {
      this.getInfoFromDay();
    },
  },
  created() {
    this.getUsersStats();

    let today = new Date();
    this.infoDate = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, "0")}-${today.getDate()}`;
  },
};
</script>

<style scoped>
.card-selectable {
  cursor: pointer;
  transition: transform 200ms;
}

.card-selectable:hover {
  transform: scale(1.02);
  z-index: 1;
}

.text-card {
  font-size: 30px;
  color: #191645;
  font-weight: bold;
}

.orientation {
  display: flex;
  flex-direction: row;
}

#center-card {
  margin: 0 15px;
}

@media (max-width: 768px) {
  .orientation {
    display: flex;
    flex-direction: column;
  }

  #center-card {
    margin: 15px 0;
  }
}
</style>