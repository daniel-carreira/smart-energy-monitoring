<template>
  <v-container class="mt-2">
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
      <div class="mb-3"><b style="color: #191645">Divisions</b></div>
      <!-- CREATE DIVISION BODY -->
      <div class="mt-3 d-flex">
        <v-text-field
          class="flex-grow-1"
          solo
          v-model="newDivisionName"
          label="Ex: Office"
          :rules="nameRules"
        />
        <b-button class="action-button" variant="success" @click="addDivision">
          <font-awesome-icon icon="fa-solid fa-plus" size="lg" />
        </b-button>
      </div>

      <!-- SEARCH BAR -->
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
        :items="divisions"
        :items-per-page="10"
        :search="search"
      >
        <template class="d-flex" v-slot:item.actions="{ item }">
          <b-button
            variant="primary"
            style="margin: 2px"
            @click="showModal('modalEdit', item)"
          >
            <font-awesome-icon icon="fa-solid fa-pen" />
          </b-button>

          <b-button
            variant="danger"
            style="margin: 2px"
            @click="showModal('modalRemove', item)"
          >
            <font-awesome-icon icon="fa-solid fa-trash" size="lg" />
          </b-button>
        </template>
      </v-data-table>
    </v-card>

    <!-- MODAL REMOVE DIVISION -->
    <b-modal
      id="modalRemove"
      ref="modalRemove"
      :title="'Do you want to delete ' + division.name + '?'"
      centered
      @ok="deleteDivision"
    >
    </b-modal>

    <!-- MODAL EDIT DIVISION -->
    <b-modal
      id="modalEdit"
      ref="modalEdit"
      title="Edit Division"
      centered
      @ok="editDivision(editDivisionName)"
    >
      <v-text-field
        :rules="nameRules"
        v-model="newDivisionName"
        label="New division Name"
        solo
      ></v-text-field>
    </b-modal>
  </v-container>
</template>

<script>
import axios from "axios";

export default {
  computed: {
    userId() {
      return this.$store.getters.user_id;
    },
    divisionUpdate() {
      return this.$store.getters.divisionUpdate;
    },
  },
  watch: {
    divisionUpdate() {
      this.getDivisions();
    },
  },
  data() {
    return {
      nameRules: [
        (v) => !!v || "Name is required",
        (v) => (v && v.length <= 255) || "Name must be less than 10 characters",
      ],
      headers: [
        { text: "Name", value: "name" },
        { text: "", value: "actions", sortable: false },
      ],
      search: "",
      divisions: [],
      newDivisionName: "",
      editDivisionName: "",
      division: { name: "", id: null },
      toast: {
        state: false,
        message: "",
        color: "",
      },
      valid: true,
    };
  },
  created() {
    this.getDivisions();
  },
  methods: {
    showModal(modal, item) {
      this.newDivisionName = item.name;
      this.division = item;
      this.$refs[modal].show();
    },
    getDivisions() {
      return axios
        .get(`/users/${this.userId}/divisions`)
        .then((response) => {
          this.divisions = response.data.data;
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    editDivision() {
      return axios
        .put(`/users/${this.userId}/divisions/${this.division.id}`, {
          name: this.newDivisionName,
        })
        .then(() => {
          this.$socket.emit("divisionUpdate", this.userId);
          this.showToastMessage("Division was renamed successfully", "#0d6efd");
        })
        .catch((error) => {
          this.showToastMessage(
            "Error trying to edit this division",
            "#333333"
          );
          return Promise.reject(error);
        });
    },
    deleteDivision() {
      return axios
        .delete(`/users/${this.userId}/divisions/${this.division.id}`)
        .then((response) => {
          this.$socket.emit("divisionUpdate", this.userId);
          this.showToastMessage(
            `${this.division.name} was deleted successfully`,
            "#dd2929"
          );
        })
        .catch((e) => {
          this.showToastMessage(e.response.data.error, "#333333");
          return Promise.reject(e);
        });
    },
    addDivision() {
      if (this.newDivisionName.trim() == "") {
        this.showToastMessage(
          "To add a division please provide a name to it",
          "#333333"
        );
        return;
      }
      return axios
        .post(`/users/${this.userId}/divisions`, { name: this.newDivisionName })
        .then(() => {
          this.$socket.emit("divisionUpdate", this.userId);
          this.showToastMessage(
            `${this.newDivisionName} was added successfully`,
            "#4caf50"
          );
          this.newDivisionName = "";
        })
        .catch((error) => {
          this.showToastMessage("Error trying to add this division", "#333333");
          return Promise.reject(error);
        });
    },
    showToastMessage(message, color) {
      this.toast.color = color;
      this.toast.message = message;
      this.toast.state = true;
    },
  },
};
</script>
<style>
.text-card {
  color: #191645;
  font-size: 2.5rem;
}
.action-button {
  width: 50px;
  height: 50px;
  margin-left: 10px;
}
</style>