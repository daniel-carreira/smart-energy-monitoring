<template>
  <div>
    <v-bottom-navigation height="" :background-color="'#191645'">
      <router-link :to="{ name: 'dashboard' }" class="m-4 notification">
        <font-awesome-icon
          class="notSelected"
          :class="{ selected: $route.name == 'dashboard' }"
          icon="fa-solid fa-house"
          size="2x"
        />
      </router-link>

      <router-link
        :to="{ name: 'read' }"
        class="m-4 notification"
        :title="
          'There is ' +
          equipsNoTrain.length +
          ' equipments that has not been analysed'
        "
      >
        <font-awesome-icon
          class="notSelected"
          :class="{ selected: $route.name == 'read' }"
          icon="fa-solid fa-magnifying-glass-chart"
          size="2x"
        />
        <div class="badge" v-if="equipsNoTrain.length">
          {{ equipsNoTrain.length }}
        </div>
      </router-link>

      <router-link
        :to="{ name: 'settings' }"
        class="m-4 notification"
        v-if="this.get_started >= 0"
      >
        <font-awesome-icon
          @click="$router.push({ name: 'settings' })"
          class="notSelected"
          :class="{ selected: $route.path.startsWith('/settings') }"
          icon="fa-solid fa-gear"
          size="2x"
        />
        <div class="badge" v-if="stats.divisions == 0 || stats.equipments == 0">
          !
        </div>
      </router-link>
      <div class="m-3">
        <b-dropdown variant="link" right no-caret>
          <template #button-content>
            <font-awesome-icon
              icon="fa-solid fa-circle-chevron-down"
              size="2x"
              style="color: white !important"
            />
          </template>

          <b-dropdown-item :to="{ name: 'alerts' }">Alerts</b-dropdown-item>
          <b-dropdown-item :to="{ name: 'profile' }">Profile</b-dropdown-item>
          <b-dropdown-divider></b-dropdown-divider>

          <b-dropdown-item @click="logout()">Log Out</b-dropdown-item>
        </b-dropdown>
      </div>
    </v-bottom-navigation>
  </div>
</template>

<script>
import axios from "axios";

export default {
  created() {
    this.getStats();
  },
  computed: {
    userId() {
      return this.$store.getters.user_id;
    },
    get_started() {
      return this.$store.getters.get_started;
    },
    navbarUpdate() {
      return this.$store.getters.navbarUpdate;
    },
  },
  watch: {
    navbarUpdate() {
      this.getStats();
    },
  },
  data() {
    return {
      modalState: false,
      analyze: null,
      edit: false,
      equipments: null,
      stats: {},
      equipsNoTrain: [],
    };
  },
  methods: {
    logout() {
      axios
        .post(`logout`)
        .then(() => {
          this.$store.dispatch("authLogout");
        })
        .catch((error) => {
          console.log(error);
        });
    },
    getStats() {
      axios
        .get(`/users/${this.userId}/stats`)
        .then((response) => {
          this.stats = response.data;
          this.equipsNoTrain = this.stats.training_examples.filter(function (item) {
            return item.count == 0;
          });
        })
        .catch((error) => {
          console.log(error);
        });
    },
  },
};
</script>

<style scoped>
.center {
  margin-left: auto;
  margin-right: auto;
}

.modalText {
  font-size: 20px;
}

.navbar {
  width: 100%;
  background-color: #191645;
  height: 5%;
}

.selected {
  color: #44c6ac !important;
}

.notSelected {
  color: white;
}

.notification {
  color: white;
  text-decoration: none;
  position: relative;
  display: inline-block;
  border-radius: 2px;
}

.notification .badge {
  position: absolute;
  top: -11px;
  left: 35px;
  border-radius: 50%;
  background: red;
  color: white;
}
</style>
