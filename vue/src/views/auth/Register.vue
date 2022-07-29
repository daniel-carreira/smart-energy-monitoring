<template>
  <b-container class="top">
    <v-snackbar :color="toast.color" top v-model="toast.state">{{
      toast.message
    }}</v-snackbar>
    <v-card class="center card">
      <div class="text-center center w-75 mt-5">
        <img src="../../assets/logo3.png" class="mb-5 img" />
        <v-text-field v-model="name" label="Name" required solo> </v-text-field>
        <v-text-field v-model="email" label="Email" required solo>
        </v-text-field>

        <v-text-field
          solo
          v-model="password"
          :append-icon="showPassw ? 'mdi-eye' : 'mdi-eye-off'"
          :type="showPassw ? 'text' : 'password'"
          label="Password"
          @click:append="showPassw = !showPassw"
        ></v-text-field>

        <v-text-field type="date" v-model="birthdate" solo></v-text-field>

        <v-btn
          color="#44c6ac"
          class="w-100 mb-2 button"
          large
          @click.prevent="signup"
        >
          Sign up
        </v-btn>
        <router-link style="text-decoration: none; color: white" to="/">
          <v-btn color="#DD2929" class="w-100 mb-5 button" large>
            Back to Sign in
          </v-btn></router-link
        >
        <br />
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
      name: "",
      email: "",
      birthdate: "",
      password: "",
      errors: null,
      showPassw: false,
      toast: {
        state: false,
        message: "",
        color: "",
      },
    };
  },
  methods: {
    async signup() {
      axios
        .post("users", {
          name: this.name,
          email: this.email,
          birthdate: this.formatDate(this.birthdate),
          password: this.password,
        })
        .then(async () => {
          await this.$store.dispatch("authRequest", {
            username: this.email,
            password: this.password,
          });
          this.$router.push({
            name: "dashboard",
          });
        })
        .catch((error) => {
          if ("name" in error.response.data.errors) {
            this.showToastMessage(
              error.response.data.errors.name[0],
              "#333333"
            );
          } else if ("email" in error.response.data.errors) {
            this.showToastMessage(
              error.response.data.errors.email[0],
              "#333333"
            );
          } else if ("password" in error.response.data.errors) {
            this.showToastMessage(
              error.response.data.errors.password[0],
              "#333333"
            );
          } else if ("birthdate" in error.response.data.errors) {
            this.showToastMessage(
              error.response.data.errors.birthdate[0],
              "#333333"
            );
          } else {
            this.showToastMessage(
              "There has been a problem signing up",
              "#333333"
            );
          }
        });
    },
    formatDate(date) {
      return date.split("-").reverse().join("/");
    },
    onReset() {
      this.email = null;
      this.password = null;
    },
    showToastMessage(message, color) {
      this.toast.color = color;
      this.toast.message = message;
      this.toast.state = true;
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
  font-weight: bold;
  width: 40vw;
  min-width: 44vmax;
  border-radius: 10px;
  font-size: 2rem;
  color: black;
  background-color: #191645;
}

.top {
  margin-top: 12vh;
}

.button {
  color: white;
}
</style>
