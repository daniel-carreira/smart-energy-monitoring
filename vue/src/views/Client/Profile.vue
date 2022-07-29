<template>
  <b-container class="mt-2">
    <v-snackbar
      style="margin-top: 5%"
      :color="toast.color"
      top
      v-model="toast.state"
      >{{ toast.message }}</v-snackbar
    >
    <!-- MAIN CARD -->
    <v-card elevation="6" class="p-4" style="border-radius: 10px">
      <!-- TITLE -->
      <div class="text-card mb-3"><b style="color: #191645">Profile</b></div>

      <label for="name">Name</label>
      <v-text-field
        :rules="fieldRequired"
        id="name"
        v-model="user.name"
        :disabled="!isEditing"
        solo
      />

      <label for="email">Email</label>
      <v-text-field id="email" v-model="user.email" :disabled="true" solo />

      <label for="birthdate">Birthdate</label>
      <v-text-field
        :rules="fieldRequired"
        id="birthdate"
        v-model="user.birthdate"
        :disabled="!isEditing"
        type="date"
        solo
      />

      <label for="price">Energy Price per kWh</label>
      <v-text-field
        :rules="fieldRequired"
        id="price"
        v-model.number="user.energy_price"
        :disabled="!isEditing"
        type="number"
        suffix="€"
        solo
      />

      <label for="wakeup">Wake up time</label>
      <b-form-timepicker
        v-model="user.no_activity_start"
        :disabled="!isEditing"
        id="wakeup"
        size="sm"
        locale="pt"
        class="mb-3"
      ></b-form-timepicker>

      <label for="bedtime">Bedtime</label>
      <b-form-timepicker
        v-model="user.no_activity_end"
        :disabled="!isEditing"
        id="bedtime"
        size="sm"
        locale="pt"
        class="mb-5"
      ></b-form-timepicker>

      <div class="d-flex justify-content-between">
        <b-button variant="danger" @click="showModal('modalChangePSW')">
          Change Password
        </b-button>

        <div>
          <b-button v-if="!isEditing" variant="primary" @click="startEdit">
            <font-awesome-icon icon="fa-solid fa-pen" />
          </b-button>
          <div v-else>
            <b-button
              variant="primary"
              style="margin-right: 10px"
              @click="editUser"
              :disabled="validateEdit()"
            >
              <font-awesome-icon icon="fa-solid fa-floppy-disk" />
            </b-button>
            <b-button variant="danger" @click="cancelEdit">
              <font-awesome-icon icon="fa-solid fa-ban" />
            </b-button>
          </div>
        </div>
      </div>
    </v-card>

    <!-- MODAL CHANGE PASSWORD -->
    <b-modal
      id="modalChangePSW"
      ref="modalChangePSW"
      title="Change Password"
      centered
    >
      <template #modal-footer class="d-flex">
        <b-button @click="editPassword()" :disabled="!oldPSW || !newPSW">
          Change
        </b-button>
      </template>
      <label for="oldPSW">Current Password</label>
      <v-text-field
        :rules="fieldRequired"
        v-model="oldPSW"
        id="oldPSW"
        type="password"
        hide-details="auto"
        solo
      />
      <br />
      <label for="newPSW">New Password</label>
      <v-text-field
        :rules="fieldRequired"
        v-model="newPSW"
        id="newPSW"
        type="password"
        hide-details="auto"
        solo
      />
    </b-modal>
  </b-container>
</template>

<script>
import axios from "axios";
import EquipmentList from "../../components/EquipmentList.vue";

export default {
  computed: {
    userId() {
      return this.$store.getters.user_id;
    },
    profileUpdate() {
      return this.$store.getters.profileUpdate;
    },
  },
  watch: {
    profileUpdate() {
      this.getProfile();
    },
  },
  components: {
    EquipmentList,
  },
  data() {
    return {
      oldPSW: "",
      newPSW: "",
      user: {},
      userClone: {},
      toast: {
        state: false,
        message: "",
        color: "",
      },
      isEditing: false,
      fieldRequired: [(v) => !!v || "Field required"],
    };
  },
  created() {
    this.getProfile();
  },
  methods: {
    getProfile() {
      axios
        .get(`/user`)
        .then((response) => {
          this.user = response.data;
          this.user.birthdate = this.user.birthdate.split(" ")[0];
          this.user.no_activity_start =
            this.user.no_activity_start.split(" ")[1];
          this.user.no_activity_end = this.user.no_activity_end.split(" ")[1];
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    editPassword() {
      this.hideModal("modalChangePSW");
      return axios
        .patch(`/users/${this.userId}/password`, {
          oldPassword: this.oldPSW,
          newPassword: this.newPSW,
        })
        .then(() => {
          this.showToastMessage("Password has been changed", "#4caf50");
        })
        .catch(() => {
          this.showToastMessage(
            "There has been an error changing the password",
            "#333333"
          );
        });
    },
    editUser() {
      let date = new Date(this.user.birthdate);
      let formatedData = date.toLocaleDateString("pt", {
        timeZone: "Europe/Lisbon",
      });


      let startHour =  Date.parse(formatedData.replaceAll('/','-') + " " + this.user.no_activity_start) / 1000;
      let endHour =  Date.parse(formatedData.replaceAll('/','-') + " " + this.user.no_activity_end) / 1000;


      return axios
        .put(`/users/${this.userId}`, {
          ...this.user,
          birthdate: formatedData,
          no_activity_start: startHour,
          no_activity_end: endHour,
        })
        .then(() => {
          this.showToastMessage("User edited with success", "#0d6efd");
          this.$socket.emit("profileUpdate", this.userId);
          this.isEditing = false;
        })
        .catch(() => {
          this.showToastMessage(
            "There has been an error editing the user",
            "#333333"
          );
          this.user = this.userClone;
          this.isEditing = false;
        });
    },
    cancelEdit() {
      this.user = this.userClone;
      this.isEditing = false;
    },
    startEdit() {
      this.isEditing = true;
      this.userClone = { ...this.user };
    },
    showModal(modal) {
      this.oldPSW = "";
      this.newPSW = "";
      this.$refs[modal].show();
    },
    showToastMessage(message, color) {
      this.toast.color = color;
      this.toast.message = message;
      this.toast.state = true;
    },
    validateEdit() {
      if (
        this.user.name == "" ||
        this.user.birthdate == "" ||
        this.user.energy_price == ""
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

<style scoped>
.text-card {
  color: #191645;
  font-size: 2.5rem;
}
</style>