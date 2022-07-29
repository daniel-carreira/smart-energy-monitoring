<template>
  <div>
    <Navbar
      v-if="currentRouteName != 'login' && currentRouteName != 'register' && this.$route.path.toString().split('/')[1] != 'admin'"
    />
    <NavbarAdmin
       v-else-if="currentRouteName != 'login' && currentRouteName != 'register'"
    />

    <div
      class="w-100"
      :class="{
        'col-md-9 ms-sm-auto col-lg-10 px-md-4':
          currentRouteName != 'login' && currentRouteName != 'register',
      }"
    ></div>
    <router-view />
  </div>
</template>

<script>
import Navbar from "./components/Navbar.vue";
import NavbarAdmin from "./components/NavbarAdmin.vue"


export default {
  components: {
    Navbar,
    NavbarAdmin
  },
  computed: {
    currentRouteName() {
      return this.$route.name;

    },
    userId() {
      return this.$store.getters.user_id;
    },
  },
  async created() {
    this.$store.dispatch("fillStore");
  },
};
</script>
