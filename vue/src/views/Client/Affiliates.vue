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
      <!-- TITLE -->
      <span class="mb-3"><b style="color: #191645">Affiliates</b></span>

      <!-- CARD BODY -->
      <div>
        <!-- ADD AFFILIATE BODY -->
        <div class="mt-3 d-flex">
          <v-text-field
            class="flex-grow-1"
            solo
            v-model="email"
            label="E-mail"
            :rules="fieldRequired"
          />
          <b-button
            class="action-button"
            variant="success"
            :disabled="!email"
            @click="buttonAddClicked"
          >
            <b-spinner
              v-if="isLoading.btnAdd"
              label="Spinning"
              style="width: 1rem; height: 1rem"
            />
            <font-awesome-icon v-else icon="fa-solid fa-plus" size="lg" />
          </b-button>
        </div>

        <!-- AFFILIATE LIST -->
        <v-simple-table v-if="affiliates.length > 0" fixed-header>
          <template v-slot:default>
            <thead>
              <tr>
                <th>Name</th>
                <th>E-mail</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(affiliate, idx) in affiliates" :key="idx">
                <td>{{ affiliate.name }}</td>
                <td>{{ affiliate.email }}</td>
                <td align="right">
                  <b-button
                    variant="danger"
                    @click="buttonRemoveClicked(affiliate.id)"
                  >
                    <b-spinner
                      v-if="isLoading[`${affiliate.id}`]"
                      label="Spinning"
                      style="width: 1rem; height: 1rem"
                    />
                    <font-awesome-icon
                      v-else
                      icon="fa-solid fa-trash"
                      size="lg"
                    />
                  </b-button>
                </td>
              </tr>
            </tbody>
          </template>
        </v-simple-table>
      </div>
    </v-card>
  </b-container>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      email: "",
      affiliates: [],
      toast: {
        state: false,
        message: "",
        color: "",
      },
      isLoading: {
        btnAdd: false,
      },
      fieldRequired: [(v) => !!v || "Field required"],
    };
  },
  computed: {
    userId() {
      return this.$store.getters.user_id;
    },
    affiliateUpdate() {
      return this.$store.getters.affiliateUpdate;
    },
  },
  watch: {
    affiliateUpdate() {
      this.getAffiliates();
    },
  },
  created() {
    this.getAffiliates();
  },
  methods: {
    getAffiliates() {
      return axios
        .get(`/users/${this.userId}/affiliates/my`)
        .then((response) => {
          this.affiliates = response.data;
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    postAffiliate() {
      return axios
        .post(`/users/${this.userId}/affiliates`, { email: this.email })
        .then(() => {
          this.$socket.emit("affiliateUpdate", this.userId);
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    removeAffiliate(id) {
      return axios
        .delete(`/users/${this.userId}/affiliates/${id}`)
        .then(() => {
          this.$socket.emit("affiliateUpdate", this.userId);
        })
        .catch((error) => {
          return Promise.reject(error);
        });
    },
    buttonAddClicked() {
      this.isLoading.btnAdd = true;
      this.isLoading = { ...this.isLoading };
      this.postAffiliate()
        .then(() => {
          this.isLoading.btnAdd = false;
          this.isLoading = { ...this.isLoading };
          this.email = "";
          this.showToastMessage("Affiliate added with success", "#4caf50");
        })
        .catch((error) => {
          this.isLoading.btnAdd = false;
          this.isLoading = { ...this.isLoading };
          this.showToastMessage(error.response.data.errors.email[0], "#333333");
        });
    },
    buttonRemoveClicked(id) {
      this.isLoading[`${id}`] = true;
      this.isLoading = { ...this.isLoading };
      this.removeAffiliate(id)
        .then(() => {
          this.isLoading[`${id}`] = false;
          this.isLoading = { ...this.isLoading };
          this.showToastMessage("Affiliate removed with success", "#dd2929");
        })
        .catch((error) => {
          this.isLoading[`${id}`] = false;
          this.isLoading = { ...this.isLoading };
          this.showToastMessage(error, "#333333");
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