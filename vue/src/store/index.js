import Vue from "vue";
import Vuex from "vuex";
import axios from "axios";
import router from "./../router";

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    username: null,
    userType: null,
    user_id: null,
    status: false,
    access_token: null,
    get_started: null,
    divisionUpdate: false,
    equipmentUpdate: false,
    affiliateUpdate: false,
    profileUpdate: false,
    navbarUpdate: false,
    trainingExamples: false,
    usersUpdate: false,
    equipmentTypeUpdate: false,
  },
  getters: {
    username: (state) => state.username,
    user_id: (state) => state.user_id,
    userType: (state) => state.userType,
    get_started: (state) => state.get_started,
    divisionUpdate: (state) => state.divisionUpdate,
    equipmentUpdate: (state) => state.equipmentUpdate,
    affiliateUpdate: (state) => state.affiliateUpdate,
    profileUpdate: (state) => state.profileUpdate,
    navbarUpdate: (state) => state.navbarUpdate,
    usersUpdate: (state) => state.usersUpdate,
    trainingExamples: (state) => state.trainingExamples,
    equipmentTypeUpdate: (state) => state.equipmentTypeUpdate,
  },
  mutations: {
    mutationAuthOk(state) {
      state.status = localStorage.getItem("status");
      state.username = localStorage.getItem("username");
      state.user_id = localStorage.getItem("user_id");
      state.access_token = localStorage.getItem("access_token");
      state.userType = localStorage.getItem("userType");
      state.get_started = localStorage.getItem("get_started");
      this.$socket.emit("logged_in", state.user_id, state.userType);
    },
    mutationAuthReset(state) {
      (state.status = false),
        (state.username = null),
        (state.userType = null),
        (state.user_id = null),
        (state.access_token = null),
        localStorage.removeItem("username");
      localStorage.removeItem("user_id");
      localStorage.removeItem("access_token");
      localStorage.removeItem("userType");
      localStorage.removeItem("get_started");
      localStorage.removeItem("status");
    },
    async SOCKET_divisionUpdate(state) {
      state.divisionUpdate = !state.divisionUpdate;
    },
    async SOCKET_equipmentUpdate(state) {
      state.equipmentUpdate = !state.equipmentUpdate;
    },
    async SOCKET_affiliateUpdate(state) {
      state.affiliateUpdate = !state.affiliateUpdate;
    },
    async SOCKET_profileUpdate(state) {
      state.profileUpdate = !state.profileUpdate;
    },
    async SOCKET_trainingExamples(state) {
      state.trainingExamples = !state.trainingExamples;
    },
    async SOCKET_navbarUpdate(state) {
      state.navbarUpdate = !state.navbarUpdate;
    },
    async SOCKET_usersUpdate(state) {
      state.usersUpdate = !state.usersUpdate;
    },
    async SOCKET_equipmentTypeUpdate(state) {
      console.log("aqui");
      state.equipmentTypeUpdate = !state.equipmentTypeUpdate;
    },
    async SOCKET_userBlock() {
      this.dispatch("authLogout");
    },
    async SOCKET_userDeleted() {
      this.dispatch("authLogout");
    },
  },

  actions: {
    fillStore(context) {
      context.commit("mutationAuthOk");
      axios.defaults.headers.common.Authorization =
        "Bearer " + this.state.access_token;
    },
    async authRequest(context, credentials) {
      await axios
        .post("/login", {
          username: credentials.username,
          password: credentials.password,
        })
        .then(async (response) => {
          axios.defaults.headers.common.Authorization =
            "Bearer " + response.data.access_token;
          localStorage.setItem("access_token", response.data.access_token);
          localStorage.setItem("status", true);
          await context.dispatch("getAuthUser");
        })
        .catch(() => {
          context.commit("mutationAuthReset");
        });
    },
    async getAuthUser(context) {
      await axios
        .get("/user")
        .then((response) => {
          localStorage.setItem("username", response.data.email);
          localStorage.setItem("user_id", response.data.id);
          localStorage.setItem("get_started", response.data.get_started);
          localStorage.setItem("userType", response.data.type);
          context.commit("mutationAuthOk");
        })
        .catch((error) => {
          context.commit("mutationAuthReset");
          console.log(error);
        });
    },

    authLogout(context, state) {
      axios
        .post("/logout", state)
        .then(() => {
          context.commit("mutationAuthReset");
          this.$socket.emit("logged_out", state);
          router.push({
            name: "login",
          });
        })
        .catch(() => {
          context.commit("mutationAuthReset");
          this.$socket.emit("logged_out", state);
          router.push({
            name: "login",
          });
        });
    },
  },
});
