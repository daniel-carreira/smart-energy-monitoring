<template>
  <v-container>
    <v-snackbar
      style="margin-top: 5%"
      :color="toast.color"
      top
      v-model="toast.state"
      >{{ toast.message }}</v-snackbar
    >

    <!-- MAIN CARD -->
    <v-card elevation="6" class="text-card p-4" style="border-radius: 10px">
      <!-- TITLE -->
      <div class="mb-3"><b style="color: #191645">Users</b></div>

      <!-- CREATE -->
      <div class="mt-3 d-flex">
        <v-select
          v-model="type"
          :items="types"
          item-text="text"
          item-value="value"
          solo
        ></v-select>
        <b-button
          class="action-button"
          variant="success"
          @click="showModal('modalAdd', {})"
        >
          <font-awesome-icon icon="fa-solid fa-plus" size="lg" />
        </b-button>
      </div>
      <div data-app />
      <!-- SEARCH -->
      <v-text-field
        v-model="search"
        append-icon="mdi-magnify"
        label="Search"
        single-line
        hide-details
      />

      <!-- DATA TABLE -->
      <v-data-table
        :headers="headers"
        :items="users"
        :items-per-page="10"
        :search="search"
      >
        <template v-slot:item.actions="{ item }">
          <b-button
            v-if="item.id != userId"
            style="margin: 2px"
            :variant="!item.locked ? 'success' : 'dark'"
            @click="changeLock(item)"
          >
            <font-awesome-icon v-if="!item.locked" icon="fa-unlock" />
            <font-awesome-icon v-else icon="fa-lock" />
          </b-button>
          <b-button
            v-if="item.id != userId"
            variant="primary"
            style="margin: 2px"
            @click="showModal('modalEdit', item)"
          >
            <font-awesome-icon icon="fa-solid fa-pen" />
          </b-button>

          <b-button
            v-if="item.id != userId"
            variant="danger"
            style="margin: 2px"
            @click="showModal('modalRemove', item)"
          >
            <font-awesome-icon icon="fa-solid fa-trash" size="lg" />
          </b-button>
        </template>
      </v-data-table>
    </v-card>

    <b-modal id="modalAdd" ref="modalAdd" title="Create User" centered>
      <template #modal-footer class="d-flex">
        <b-button
          variant="primary"
          :disabled="validateCreate()"
          @click="createUser"
        >
          Create
        </b-button>
      </template>
      <div data-app />
      <span>Type</span>

      <v-select
        v-model="typeCreate"
        :items="typesCreate"
        item-text="text"
        item-value="value"
        :rules="fieldRequired"
        solo
      ></v-select>

      <!-- INPUT NAME -->
      <span>Name</span>
      <v-text-field
        label="Name"
        :rules="fieldRequired"
        v-model="user.name"
        solo
      />

      <!-- INPUT EMAIL -->
      <span class="p-3">Email</span>
      <v-text-field
        :rules="emailRules"
        label="Email"
        v-model="user.email"
        solo
      />

      <!-- INPUT BIRTHDATE -->
      <span>Birthdate</span>
      <v-text-field
        :rules="fieldRequired"
        label="Birthdate"
        v-model="user.birthdate"
        type="date"
        solo
      />

      <!-- INPUT PASSWORD -->
      <span>Password</span>
      <v-text-field
        :rules="fieldRequired"
        label="Password"
        v-model="user.password"
        type="password"
        solo
      />
    </b-modal>

    <b-modal
      id="modalEdit"
      ref="modalEdit"
      :title="user.name"
      ok-only
      centered
      hide-footer
    >
      <div class="d-flex justify-content-between">
        <h6>Password reset</h6>
        <b-button variant="primary" @click="passwReset">
          <font-awesome-icon icon="fa-solid fa-arrows-rotate" size="lg" />
        </b-button>
      </div>
    </b-modal>
    <b-modal
      id="modalRemove"
      ref="modalRemove"
      :title="'Are you sure you want to delete ' + user.name + '?'"
      centered
      @ok="deleteUser"
    >
    </b-modal>
  </v-container>
</template>

<script>
import axios from "axios";
export default {
  data() {
    return {
      types: [
        { text: "All", value: "All" },
        { text: "Administrators", value: "A" },
        { text: "Clients", value: "C" },
        { text: "Producers", value: "P" },
      ],
      typesCreate: [
        { text: "Administrators", value: "A" },
        { text: "Clients", value: "C" },
        { text: "Producers", value: "P" },
      ],
      headers: [
        {
          text: "Name",
          value: "name",
        },
        {
          text: "Email",
          value: "email",
        },
        {
          text: "Email",
          value: "email",
        },
        {
          text: "Birthdate",
          value: "birthdate",
        },
        {
          text: "",
          value: "actions",
          sortable: false,
        },
      ],
      user: {
        id: "",
        name: "",
        email: "",
        password: "",
        birthdate: "",
      },
      toast: {
        state: false,
        message: "",
        color: "",
      },
      fieldRequired: [(v) => !!v || "Field required"],
      emailRules: [
        (v) => !!v || "E-mail is required",
        (v) => /.+@.+/.test(v) || "E-mail must be valid",
      ],
      type: "All",
      typeCreate: "C",
      users: [],
      search: "",
      allUsers: [],
    };
  },
  computed: {
    userId() {
      return this.$store.getters.user_id;
    },
    usersUpdate() {
      return this.$store.getters.usersUpdate;
    },
  },
  watch: {
    type() {
      if (this.type == "All") {
        this.users = this.allUsers;
        return;
      }
      this.users = this.allUsers.filter((item) => {
        return item.type == this.type;
      });
    },
    usersUpdate() {
      this.getUsers();
    },
  },
  methods: {
    getUsers() {
      return axios
        .get(`/users`)
        .then((response) => {
          this.allUsers = response.data.data;
          this.users = response.data.data;
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    validateCreate(type) {
      let item = this.user;
      if (
        item.name == "" ||
        item.email == "" ||
        item.birthdate == "" ||
        item.password == ""
      ) {
        return true;
      }
      return false;
    },
    showModal(modal, item) {
      this.user = {
        name: "",
        email: "",
        password: "",
        birthdate: "",
      };

      if (modal != "modalAdd") this.user = { ...item };
      this.$refs[modal].show();
    },
    hideModal(modal) {
      this.$refs[modal].hide();
    },
    createUser() {
      this.hideModal("modalAdd");
      axios
        .post(`/users`, {
          name: this.user.name,
          email: this.user.email,
          password: this.user.password,
          birthdate: this.user.birthdate.split("-").reverse().join("/"),
          type: this.typeCreate,
        })
        .then(() => {
          this.$socket.emit("usersUpdate", this.userId);
          this.showToastMessage(
            "Administrator was created successfully",
            "#4caf50"
          );
        })
        .catch((error) => {
          console.log(error);
          this.showToastMessage(error, "#333333");
        });
    },
    deleteUser() {
      this.hideModal("modalRemove");
      axios
        .delete(`/users/${this.user.id}`)
        .then(() => {
          this.$socket.emit("usersUpdate", this.userId);
          this.$socket.emit("userDeleted", this.user.id);

          this.showToastMessage(
            `${this.user.name} was deleted successfully`,
            "#dd2929"
          );
        })
        .catch((error) => {
          this.showToastMessage(
            "There was an error removing the user",
            "#333333"
          );
        });
    },
    passwReset() {
      this.hideModal("modalEdit");
      axios
        .patch(`/users/${this.user.id}/password/reset`)
        .then(() => {
          this.showToastMessage(
            `${this.user.name} was notified with password reset`,
            "#4caf50"
          );
        })
        .catch(() => {
          this.showToastMessage(
            "There was an error trying to reset password",
            "#333333"
          );
        });
    },
    showToastMessage(message, color) {
      this.toast.color = color;
      this.toast.message = message;
      this.toast.state = true;
    },
    changeLock(item) {
      axios
        .patch(`/users/${item.id}/locked`)
        .then(() => {
          this.$socket.emit("usersUpdate", this.userId);
          this.$socket.emit("userBlock", item.id, !item.locked);
          this.showToastMessage(`${item.name} lock was changed`, "#4caf50");
        })
        .catch(() => {
          this.showToastMessage(
            "There was an error trying to change user lock",
            "#333333"
          );
        });
    },
  },
  created() {
    this.getUsers();
  },
};
</script>

<style>
</style>