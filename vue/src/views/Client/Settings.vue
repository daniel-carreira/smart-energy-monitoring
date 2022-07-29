<template>
  <v-container class="text-center mt-2" style="color: black; user-select: none">
    <v-card
      @click="$router.push({ name: 'divisions' })"
      elevation="6"
      :class="{ card: stats.divisions == 0 }"
      class="flex-grow-1 card-selectable"
      style="border-radius: 10px"
    >
      <b-container class="icons">
        <b-row no-gutters>
          <b-col cols="2">
            <font-awesome-icon
              class=""
              icon="fa-solid fa-house-chimney-window"
            />
          </b-col>
          <b-col>
            <span class="p-5">Divisions</span>
          </b-col>
          <b-col cols="2">
            <font-awesome-icon
              title="Divisions must be inserted"
              style="color: red"
              icon="fa-solid fa-triangle-exclamation"
              v-if="stats.divisions == 0"
            />
          </b-col>
        </b-row>
      </b-container>
    </v-card>

    <v-card
      :disabled="stats.divisions == 0"
      @click="$router.push({ name: 'equipments' })"
      elevation="6"
      :class="{ card: stats.equipments == 0 && stats.divisions > 0 }"
      class="flex-grow-1 mt-4 card-selectable"
      style="border-radius: 10px"
    >
      <b-container class="icons">
        <b-row no-gutters>
          <b-col cols="2">
            <font-awesome-icon icon="fa-solid fa-plug" />
          </b-col>
          <b-col> <span class="p-5">Equipments</span></b-col>
          <b-col cols="2">
            <v-tooltip bottom>
              <template v-slot:activator="{ on, attrs }">
                <font-awesome-icon
                  style="color: red"
                  icon="fa-solid fa-triangle-exclamation"
                  v-show="stats.equipments == 0 && stats.divisions > 0"
                />
              </template> </v-tooltip
          ></b-col>
        </b-row>
      </b-container>
    </v-card>
    <v-card
      @click="$router.push({ name: 'affiliates' })"
      elevation="6"
      class="flex-grow-1 mt-4 card-selectable"
      style="border-radius: 10px"
    >
      <b-container class="icons">
        <b-row no-gutters>
          <b-col cols="2">
            <font-awesome-icon icon="fa-solid fa-user-group"
          /></b-col>
          <b-col><span class="p-5">Affiliates</span></b-col>
          <b-col cols="2"></b-col>
        </b-row>
      </b-container>
    </v-card>
    <b-modal ref="getStartedModal" title="Get Started" ok-only centered>
      <span v-if="get_started == 0" class="getStartedModal"
        >This is the Settings Page, here you can make the system
        configuration.<br />
        Press on the
        <router-link :to="{ name: 'divisions' }">Divisions tab</router-link> to
        get started
      </span>

      <span v-if="get_started == 1" class="getStartedModal">
        If all the divisions in the housing had been added, let's add the
        equipments. Please access the
        <router-link :to="{ name: 'equipments' }">Equipments tab</router-link>
        to continue
      </span>
    </b-modal>
  </v-container>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      stats: {},
    };
  },
  computed: {
    userId() {
      return this.$store.getters.user_id;
    },
    get_started() {
      return this.$store.getters.get_started;
    },
  },
  async created() {
    await this.getStats();

    if (this.get_started < 3) await this.$store.dispatch("getAuthUser");
    if (this.get_started < 2) this.showModal("getStartedModal");
  },
  methods: {
    getStats() {
      axios
        .get(`/users/${this.userId}/stats`)
        .then((response) => {
          this.stats = response.data;
        })
        .catch((error) => {
          console.log(error);
        });
    },
    showModal(modal) {
      this.$refs[modal].show();
    },
  },
};
</script>
  
<style scoped>
.icons {
  color: #191645;
  font-size: 5.5vw;
}
.card-selectable {
  cursor: pointer;
  transition: transform 200ms;
}

.card-selectable:hover {
  transform: scale(1.02);
  z-index: 1;
}

.card {
  animation: shake 4.7s ease;
  animation-iteration-count: infinite;
}

.getStartedModal {
  font-size: 20px;
}

@keyframes shake {
  0% {
    transform: translate(0, 0);
  }
  1.78571% {
    transform: translate(5px, 0);
  }
  3.57143% {
    transform: translate(0, 0);
  }
  5.35714% {
    transform: translate(5px, 0);
  }
  7.14286% {
    transform: translate(0, 0);
  }
  8.92857% {
    transform: translate(5px, 0);
  }
  10.71429% {
    transform: translate(0, 0);
  }
  100% {
    transform: translate(0, 0);
  }
}
</style>