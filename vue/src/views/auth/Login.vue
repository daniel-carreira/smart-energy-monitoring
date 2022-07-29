<template>
  <b-container class="top">
    <v-snackbar style="margin-top: 5%" top v-model="toast.state">{{
      toast.message
    }}</v-snackbar>
    <v-card class="center card">
      <div class="text-center center w-75 mt-5">
        <img src="../../assets/logo3.png" class="mb-5 img" />
        <v-text-field v-model="email" label="Email" solo> </v-text-field>
        <v-text-field
          solo
          v-model="password"
          :append-icon="showPassw ? 'mdi-eye' : 'mdi-eye-off'"
          :type="showPassw ? 'text' : 'password'"
          label="Password"
          @click:append="showPassw = !showPassw"
        >
        </v-text-field>

        <v-btn color="#44c6ac" class="w-100" large @click.prevent="signin">
          Log In
        </v-btn>

        <br />

        <v-card-subtitle class="mt-1">
          Don't have an account? Click to

          <router-link :to="{ name: 'register' }">Register</router-link>
        </v-card-subtitle>
      </div>
    </v-card>
  </b-container>
</template>

<script>
import axios from "axios";

export default {
  auth: false,
  data() {
    return {
      email: "",
      password: "",
      errors: { username: "", password: "" },
      showPassw: false,
      password: "",
      toast: {
        state: false,
        message: "",
        color: "",
      },
    };
  },
  methods: {
    signin() {
      this.$store
        .dispatch("authRequest", {
          username: this.email,
          password: this.password,
        })
        .then(() => {
          let userType = this.$store.getters.userType;
          if (userType == "C") {
            this.$router.push({
              name: "dashboard",
            });
          } else if (userType == "A") {
            this.$router.push({
              name: "adminDashboard",
            });
          }
        })
        .catch((error) => {
          if ("username" in error.response.data) {
            this.showToastMessage(error.response.data.username, "#333333");
          } else if ("password" in error.response.data) {
            this.showToastMessage(error.response.data.password, "#333333");
          } else if ("block" in error.response.data.block) {
            this.showToastMessage(error.response.data.block, "#333333");
          } else {
            this.showToastMessage(error.response.data.error, "#333333");
          }
          this.$store.dispatch("authLogout");
          return Promise.reject(error);
        });
    },
    showToastMessage(message, color) {
      this.toast.color = color;
      this.toast.message = message;
      this.toast.state = true;
    },
    onReset() {
      this.email = null;
      this.password = null;
    },
  },
};
</script>


<style scoped>
img {
  min-width: 22vmax;
  width: 20vw;
}

.center {
  margin-left: auto;
  margin-right: auto;
}

.card {
  width: 40vw;
  min-width: 40vmax;
  border-radius: 10px;
  background-color: #191645;
  color: white;
  font-weight: bold;
}

.top {
  margin-top: 20vh;
}
</style>
