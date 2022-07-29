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
      <div class="mb-3"><b style="color: #191645">Equipment Types</b></div>
      <!-- CREATE equipment type BODY -->

      <b-button variant="success" @click="showModal('modalAdd', {})">
        + Create Equipment
      </b-button>

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
        :items="types"
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

    <!-- MODAL REMOVE EQUIPMENT TYPE -->
    <b-modal
      id="modalRemove"
      ref="modalRemove"
      :title="'Do you want to delete ' + type.name + '?'"
      centered
      @ok="deleteType"
    >
    </b-modal>

    <!-- MODAL EDIT EQUIPMENT TYPE -->
    <b-modal
      id="modalEdit"
      ref="modalEdit"
      title="Edit equipment type"
      centered
    >
      <template #modal-footer class="d-flex">
        <b-button
          variant="primary"
          :disabled="validate()"
          @click="editType(type)"
        >
          Edit
        </b-button>
      </template>
      <!-- INPUT NAME -->
      <span>Name</span>
      <v-text-field
        label="Name"
        v-model="type.name"
        :rules="fieldRequired"
        solo
      />

      <span>Activity</span>
      <div data-app />

      <v-select
        label="Equipment needs human intervention?"
        v-model="type.activity"
        :items="activityType"
        item-text="text"
        item-value="value"
        :rules="fieldRequired"
        solo
      ></v-select>
    </b-modal>

    <b-modal
      id="modalAdd"
      ref="modalAdd"
      title="Create Equipment Type"
      centered
    >
      <template #modal-footer class="d-flex">
        <b-button variant="primary" :disabled="validate()" @click="addType()">
          Create
        </b-button>
      </template>
      <div data-app />

      <!-- INPUT NAME -->
      <span>Name</span>
      <v-text-field
        label="Name"
        v-model="type.name"
        :rules="fieldRequired"
        solo
      />

      <span>Activity</span>
      <v-select
        label="Equipment needs human intervention?"
        v-model="type.activity"
        :items="activityType"
        item-text="text"
        item-value="value"
        :rules="fieldRequired"
        solo
      ></v-select>
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
    equipmentTypeUpdate() {
      return this.$store.getters.equipmentTypeUpdate;
    },
  },
  watch: {
    equipmentTypeUpdate() {
      console.log("dsa")
      this.getEquipmentTypes();
    },
  },
  data() {
    return {
      activityType: [
        { text: "Yes", value: "Yes" },
        { text: "No", value: "No" },
      ],
      nameRules: [
        (v) => !!v || "Name is required",
        (v) => (v && v.length <= 255) || "Name must be less than 10 characters",
      ],
      headers: [
        { text: "Name", value: "name" },
        { text: "Activity", value: "activity" },
        { text: "", value: "actions", sortable: false },
      ],
      search: "",
      types: [],
      newTypeName: "",
      type: { name: "", id: null, activity: "" },
      toast: {
        state: false,
        message: "",
        color: "",
      },
      valid: true,
      fieldRequired: [(v) => !!v || "Field required"],
    };
  },
  created() {
    this.getEquipmentTypes();
  },
  methods: {
    showModal(modal, item) {
      this.newTypeName = "";
      this.type = { ...item };
      this.$refs[modal].show();
    },
    hideModal(modal) {
      this.$refs[modal].hide();
    },
    getEquipmentTypes() {
      return axios
        .get(`/equipment-types`)
        .then((response) => {
          this.types = response.data.data;
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    editType() {
      return axios
        .put(`/equipment-types/${this.type.id}`, {
          name: this.type.name,
          activity: this.type.activity,
        })
        .then(() => {
          this.$socket.emit("equipmentTypeUpdate", this.userId);
          this.showToastMessage(
            "equipment type was renamed successfully",
            "#0d6efd"
          );
          this.hideModal("modalEdit");
        })
        .catch((error) => {
          this.showToastMessage(
            "Error trying to edit this equipment type",
            "#333333"
          );
          this.hideModal("modalEdit");

          return Promise.reject(error);
        });
    },
    deleteType() {
      return axios
        .delete(`/equipment-types/${this.type.id}`)
        .then((response) => {
          this.$socket.emit("equipmentTypeUpdate");
          this.showToastMessage(
            `${this.type.name} was deleted successfully`,
            "#dd2929"
          );
        })
        .catch((e) => {
          this.showToastMessage(e.response.data.error, "#333333");
          return Promise.reject(e);
        });
    },
    addType() {
      return axios
        .post(`/equipment-types`, {
          name: this.type.name,
          activity: this.type.activity,
        })
        .then(() => {
          this.$socket.emit("equipmentTypeUpdate");
          this.showToastMessage(
            `${this.type.name} was added successfully`,
            "#4caf50"
          );
          this.type.name = "";
        })
        .catch((error) => {
          this.showToastMessage(
            "Error trying to add this equipment type",
            "#333333"
          );
          return Promise.reject(error);
        });
    },
    validate() {
      if (this.type.name != "" && this.type.activity != "") {
        return false;
      }
      return true;
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