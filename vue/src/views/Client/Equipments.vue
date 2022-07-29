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
      <div class="mb-3"><b style="color: #191645">Equipments</b></div>

      <!-- CREATE EQUIPMENT -->
      <b-button variant="success" @click="showModal('modalAdd', {})">
        + Create Equipment
      </b-button>

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
        :items="equipments"
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

      <!-- MODAL REMOVE EQUIPMENT -->
      <b-modal
        id="modalRemove"
        ref="modalRemove"
        :title="'Do you want to delete ' + equipment.name + '?'"
        centered
        @ok="deleteEquipment"
      >
      </b-modal>

      <!-- MODAL EDIT EQUIPMENT -->
      <b-modal
        id="modalEdit"
        ref="modalEdit"
        title="Edit Equipment"
        centered
        @ok="editEquipment"
      >
        <template #modal-footer class="d-flex">
          <b-button
            variant="primary"
            :disabled="validateCreate('edit')"
            @click="editEquipment()"
          >
            Save
          </b-button>
        </template>
        <div data-app />

        <!-- INPUT NAME -->
        <span>Name</span>
        <v-text-field v-model="equipment.name" :rules="fieldRequired" solo />

        <!-- INPUT TYPE -->
        <span>Type</span>
        <v-select
          :rules="fieldRequired"
          v-model="equipment.type"
          :items="equipmentTypes"
          item-text="name"
          item-value="id"
          solo
        />

        <!-- INPUT DIVISION -->
        <span>Division</span>
        <v-select
          :rules="fieldRequired"
          v-model="equipment.division"
          :items="divisions"
          item-text="name"
          item-value="id"
          solo
        />

        <!-- INPUT CONSUMPTION -->
        <span>Consumption</span>
        <v-text-field
          v-model="equipment.consumption"
          :rules="fieldRequired"
          type="number"
          solo
        />

        <!-- INPUT ACTIVITY -->
        <span>Activity</span>
        <v-select
          v-model="equipment.activity"
          :rules="fieldRequired"
          :items="['Yes', 'No']"
          solo
        />
      </b-modal>

      <!-- MODAL CREATE EQUIPMENT -->
      <b-modal id="modalAdd" ref="modalAdd" title="Create Equipment" centered>
        <template #modal-footer class="d-flex">
          <b-button
            variant="primary"
            :disabled="validateCreate('create')"
            @click="addEquipment()"
          >
            Create
          </b-button>
        </template>
        <div data-app />

        <!-- INPUT NAME -->
        <span>Name</span>
        <v-text-field
          label="Ex: Toaster"
          :rules="fieldRequired"
          v-model="newEquipment.name"
          solo
        />

        <!-- INPUT TYPE -->
        <span class="p-3">Type</span>
        <v-select
          :rules="fieldRequired"
          label="Select a type"
          v-model="newEquipment.type"
          :items="equipmentTypes"
          item-text="name"
          item-value="id"
          solo
        />

        <!-- INPUT DIVISION -->
        <span>Division</span>
        <v-select
          :rules="fieldRequired"
          label="Select a division"
          v-model="newEquipment.division"
          :items="divisions"
          item-text="name"
          item-value="id"
          solo
        />

        <!-- INPUT CONSUMPTION -->
        <span>Consumption</span>
        <v-text-field
          :rules="fieldRequired"
          label="Equipment consumption (watts)"
          v-model="newEquipment.consumption"
          type="number"
          solo
        />

        <!-- INPUT ACTIVITY -->
        <span>Activity</span>
        <v-select
          :rules="fieldRequired"
          label="Equipment needs human intervention?"
          v-model="newEquipment.activity"
          :items="['Yes', 'No']"
          solo
        />
      </b-modal>
    </v-card>
  </v-container>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      headers: [
        {
          text: "Name",
          value: "name",
        },
        {
          text: "Division",
          value: "division_name",
        },
        {
          text: "Consumption",
          value: "consumption",
        },
        {
          text: "Time ON",
          value: "status",
        },
        {
          text: "",
          value: "actions",
          sortable: false,
        },
      ],
      search: "",

      equipments: [],
      divisions: [],
      equipmentTypes: [],
      newEquipment: {},
      equipment: {
        name: "",
        id: null,
      },
      toast: {
        state: false,
        message: "",
        color: "",
      },
      fieldRequired: [(v) => !!v || "Field required"],
    };
  },
  computed: {
    userId() {
      return this.$store.getters.user_id;
    },
    equipmentUpdate() {
      return this.$store.getters.equipmentUpdate;
    },
  },
  watch: {
    equipmentUpdate() {
      this.getEquipments();
    },
  },
  created() {
    this.getEquipments();
    this.getDivisions();
    this.getEquipmentTypes();
  },
  methods: {
    showModal(modal, item) {
      this.newEquipment = {
        name: "",
        consumption: "",
        activity: "",
        division_id: "",
        equipment_type_id: "",
        type: "",
        division: "",
      };

      this.equipment = { ...item };

      this.$refs[modal].show();
    },
    formatDate(dateStr, withFullDate) {
      if (dateStr == null || dateStr == "") return "";

      let date = new Date(
        dateStr.toString().length == 10 ? dateStr * 1000 : dateStr
      );
      let formatedDate = "";

      formatedDate = date.toLocaleDateString("pt", {
        timeZone: "Europe/Lisbon",
      });

      if (!withFullDate) return formatedDate;

      return (
        formatedDate +
        " " +
        date.toLocaleTimeString("pt-PT", { timeZone: "Europe/Lisbon" })
      );
    },
    timeDiff(timeStr) {
      let time = new Date(timeStr).getTime();
      let now = new Date().getTime() - 3600000;

      let diffSecs = parseInt((now - time) / 1000);
      if (diffSecs < 60) return `${diffSecs}s`;

      let diffMin = parseInt(diffSecs / 60);
      if (diffMin < 60) return `${diffMin}m${diffSecs % 60}s`;

      let diffHours = parseInt(diffMin / 60);
      return `${diffHours}h${diffMin % 60}m${diffSecs % 60}s`;
    },
    getEquipments() {
      return axios
        .get(`/users/${this.userId}/equipments`)
        .then((response) => {
          this.equipments = response.data.data;
          this.equipments = this.equipments.map((item) => {
            if (item.init_status_on == null) return item;

            let currStatus = this.timeDiff(item.init_status_on);
            return {
              ...item,
              status: currStatus,
            };
          });
        })
        .catch((error) => {
          return Promise.reject(error);
        });
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
    getEquipmentTypes() {
      return axios
        .get(`/equipment-types`)
        .then((response) => {
          this.equipmentTypes = response.data.data;
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    editEquipment() {
      this.hideModal("modalEdit");

      if (this.equipment.name.trim() == "") {
        this.showToastMessage(
          "To add a division please provide the required fields",
          "#333333"
        );
        return;
      }
      axios
        .put(`/users/${this.userId}/equipments/${this.equipment.id}`, {
          name: this.equipment.name,
          consumption: this.equipment.consumption,
          activity: this.equipment.activity,
          division_id: this.equipment.division,
          equipment_type_id: this.equipment.type,
        })
        .then(() => {
          this.$socket.emit("equipmentUpdate", this.userId);
          this.showToastMessage("Equipment was edited successfully", "#0d6efd");
        })
        .catch((error) => {
          this.showToastMessage(
            "There was an error editing the device",
            "#333333"
          );
          console.log(error);
        });
    },
    deleteEquipment() {
      axios
        .delete(`/users/${this.userId}/equipments/${this.equipment.id}`)
        .then(() => {
          this.$socket.emit("equipmentUpdate", this.userId);
          this.showToastMessage(
            `${this.equipment.name} was deleted successfully`,
            "#dd2929"
          );
        })
        .catch((error) => {
          this.showToastMessage(
            "There was an error removing the device",
            "#333333"
          );
        });
    },
    addEquipment() {
      this.hideModal("modalAdd");

      axios
        .post(`/users/${this.userId}/equipments`, {
          name: this.newEquipment.name,
          consumption: this.newEquipment.consumption,
          activity: this.newEquipment.activity,
          division_id: this.newEquipment.division,
          equipment_type_id: this.newEquipment.type,
        })
        .then(() => {
          this.$socket.emit("equipmentUpdate", this.userId);
          this.showToastMessage("Equipment was added successfully", "#4caf50");
        })
        .catch((error) => {
          this.showToastMessage(
            "There was an error adding the device",
            "#333333"
          );
        });
    },
    showToastMessage(message, color) {
      this.toast.color = color;
      this.toast.message = message;
      this.toast.state = true;
    },
    validateCreate(type) {
      let item = type == "create" ? this.newEquipment : this.equipment;
      if (
        item.name == "" ||
        item.consumption == "" ||
        item.activity == "" ||
        item.division == "" ||
        item.type == ""
      ) {
        return true;
      }
      return false;
    },
    hideModal(modal) {
      this.$refs[modal].hide();
    },
  },
};
</script>

<style>
</style>
