<template>
  <b-container class="mt-2">
    <v-snackbar
      style="margin-top: 5%"
      :color="toast.color"
      top
      v-model="toast.state"
      >{{ toast.message }}</v-snackbar
    >
    <v-card elevation="6" class="text-card p-4" style="border-radius: 10px">
      <div class="mb-3 d-flex justify-content-between mb-4">
        <b style="color: #191645">Alerts</b>
        <div class="d-flex flex-row">
          <v-chip
            style="margin-right: 10px"
            dark
            large
            :color="userNotifications == 'OFF' ? '#f44336' : '#4caf50'"
            @click="changeUserNotification"
          >
            <font-awesome-icon v-if="userNotifications == 'ON'" icon="fa-solid fa-bell" size="xl" />
            <font-awesome-icon v-else icon="fa-solid fa-bell-slash" size="xl" />
          </v-chip>
          <v-chip
            dark
            large
            color="grey"
            @click="openSettingsModal"
          >
            <font-awesome-icon icon="fa-solid fa-gear" size="xl" />
          </v-chip>
        </div>
      </div>
      <v-data-table :headers="alertsHeaders" :items="alerts" :items-per-page="10" :options="{ sortBy: ['timestamp'], sortDesc: [true] }">
        <template v-slot:item.timestamp="{ item }">
          {{ formatDate(item.timestamp, true) }}
        </template>
      </v-data-table>
    </v-card>

    <!-- MODAL -->
    <b-modal ref="alerts-modal" hide-footer centered size="xl" title="Settings">
      <v-data-table :headers="headers" :items="equipments" :items-per-page="10">
        <template class="d-flex" v-slot:item.state="{ item }">
          {{
            item.notify_when_passed != null
              ? item.notify_when_passed + " minutes"
              : ""
          }}
        </template>
        <template class="d-flex" v-slot:item.actions="{ item }">
          <b-button
            @click="showModal('modalAlert', item)"
            variant="primary"
            style="margin: 2px"
          >
            <font-awesome-icon icon="fa-solid fa-pen" />
          </b-button> </template
      ></v-data-table>
    </b-modal>

    <b-modal ref="modalAlert" centered title="Notifications preferences">
      <div class="d-flex justify-content-between">
        <h5>{{ equipment.name }}</h5>
        <v-chip
          dark
          :color="equipment.notify_when_passed > 0 ? '#4caf50' : '#f44336'"
          @click="changeState(equipment.notify_when_passed)"
        >
          <font-awesome-icon v-if="equipment.notify_when_passed > 0" icon="fa-solid fa-bell" size="xl" />
          <font-awesome-icon v-else icon="fa-solid fa-bell-slash" size="xl" />
        </v-chip>
      </div>

      <div v-if="equipment.notify_when_passed" class="mt-3">
        <span>Notify after the equipment has been ON for</span>
        <v-text-field
          type="number"
          min="0"
          v-model="notificationTime"
          suffix="Minutes"
          solo
        />
      </div>
      <template #modal-footer class="d-flex">
        <b-button
          @click="changeEquipmentNotifications()"
          :disabled="equipment.notify_when_passed && !notificationTime"
        >
          Save
        </b-button>
      </template>
    </b-modal>
  </b-container>
</template>

<script>
import axios from "axios";
export default {
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
    this.getAlerts();
    this.getEquipments();
    this.getNotifications();
  },
  data() {
    return {
      toast: {
        state: false,
        message: "",
        color: "",
      },
      userNotifications: "",
      equipment: "",
      notificationTime: "",
      equipments: [],
      headers: [
        { text: "Name", value: "name" },
        { text: "Notify after", value: "state" },
        { text: "Alerts", value: "actions", sortable: false },
      ],

      alerts: [],
      alertsHeaders: [
        { text: "Alert", value: "alert" },
        { text: "Time", value: "timestamp" },
      ]
    };
  },
  methods: {
    getAlerts() {
      axios
        .get(`/users/${this.userId}/alerts`)
        .then((response) => {
          this.alerts = response.data.data;
        })
        .catch((error) => {
          console.log(error);
        });
    },
    getNotifications() {
      axios
        .get(`/users/${this.userId}/notifications`)
        .then((response) => {
          this.userNotifications = response.data;
        })
        .catch((error) => {
          console.log(error);
        });
    },
    changeUserNotification() {
      axios
        .patch(`/users/${this.userId}/notifications`)
        .then((response) => {
          this.userNotifications = response.data;

          this.showToastMessage(
            "Notifications " + this.userNotifications,
            this.userNotifications == "ON" ? "#4caf50" : "#dd2929"
          );
        })
        .catch((error) => {
          this.showToastMessage(response.data.msg, "#333333");
        });
    },
    getEquipments() {
      return axios
        .get(`/users/${this.userId}/equipments`)
        .then((response) => {
          this.equipments = response.data.data;
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    changeEquipmentNotifications() {
      this.hideModal("modalAlert");
      let state = this.equipment.notify_when_passed
        ? this.notificationTime
        : null;
      axios
        .patch(`/users/${this.userId}/equipments/${this.equipment.id}`, {
          notify_when_passed: state,
        })
        .then((response) => {
          this.$socket.emit("equipmentUpdate", this.userId);
          this.showToastMessage(
            response.data.msg,
            state == null ? "#dd2929" : "#4caf50"
          );
        })
        .catch((error) => {
          this.showToastMessage(error, "#333333");
          return Promise.reject(error);
        });
    },
    showModal(modal, item) {
      this.equipment = { ...item };
      this.notificationTime = this.equipment.notify_when_passed
        ? this.equipment.notify_when_passed
        : "";
      this.$refs[modal].show();
    },
    hideModal(modal) {
      this.$refs[modal].hide();
    },
    changeState(state) {
      this.equipment.notify_when_passed = this.equipment.notify_when_passed
        ? false
        : true;
    },
    showToastMessage(message, color) {
      this.toast.color = color;
      this.toast.message = message;
      this.toast.state = true;
    },
    openSettingsModal() {
      this.$refs['alerts-modal'].show();
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
  },
};
</script>

<style scoped>
</style>