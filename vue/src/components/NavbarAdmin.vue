<template>
  <div>
    <v-bottom-navigation height="" :background-color="'#191645'">
      <router-link :to="{ name: 'adminDashboard' }" class="m-4 notification">
        <font-awesome-icon
          class="notSelected"
          :class="{ selected: $route.name == 'adminDashboard' }"
          icon="fa-solid fa-house"
          size="2x"
        />
      </router-link>

      <router-link :to="{ name: 'users' }" class="m-4 notification">
        <font-awesome-icon
          class="notSelected"
          :class="{ selected: $route.name == 'users' }"
          icon="fa-solid fa-users"
          size="2x"
        />
      </router-link>

      <router-link :to="{ name: 'equipmentTypes' }" class="m-4 notification">
        <font-awesome-icon
          class="notSelected"
          :class="{ selected: $route.name == 'equipmentTypes' }"
          icon="fa-solid fa-bolt"
          size="2x"
        />
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

          <b-dropdown-item :to="{ name: 'adminProfile' }">Profile</b-dropdown-item>
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
  },
  computed: {
    userId() {
      return this.$store.getters.user_id;
    },
  },
  data() {
    return {
     
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
