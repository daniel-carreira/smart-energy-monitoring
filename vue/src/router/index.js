import Vue from "vue";
import VueRouter from "vue-router";
import Dashboard from "../views/Client/Dashboard.vue";
import LogIn from "../views/auth/Login.vue";
import Register from "../views/auth/Register.vue";
import Profile from "../views/Client/Profile.vue";
import IndividualRead from "../views/Client/IndividualRead.vue";
import Settings from "../views/Client/Settings.vue";
import Affiliates from "../views/Client/Affiliates.vue";
import Equipments from "../views/Client/Equipments.vue";
import Divisions from "../views/Client/Divisions.vue";
import Alerts from "../views/Client/Alerts.vue";
import AdminDashboard from "../views/Admin/DashboardAdmin.vue";
import Users from "../views/Admin/Users.vue";
import AdminProfile from "../views/Admin/Profile.vue";
import EquipmentTypes from "../views/Admin/EquipmentTypes.vue";

Vue.use(VueRouter);

const routes = [
  {
    path: "/",
    name: "login",
    component: LogIn,
  },
  {
    path: "/register",
    name: "register",
    component: Register,
  },
  {
    path: "/dashboard",
    name: "dashboard",
    component: Dashboard,
  },
  {
    path: "/profile",
    name: "profile",
    component: Profile,
  },
  {
    path: "/read",
    name: "read",
    component: IndividualRead,
  },
  {
    path: "/settings",
    name: "settings",
    component: Settings,
  },
  {
    path: "/affiliates",
    name: "affiliates",
    component: Affiliates,
  },
  {
    path: "/settings/divisions",
    name: "divisions",
    component: Divisions,
  },
  {
    path: "/settings/equipments",
    name: "equipments",
    component: Equipments,
  },
  {
    path: "/alerts",
    name: "alerts",
    component: Alerts,
  },
  {
    path: "/admin",
    name: "adminDashboard",
    component: AdminDashboard,
  },
  {
    path: "/admin/users",
    name: "users",
    component: Users,
  },
  {
    path: "/admin/equipmentTypes",
    name: "equipmentTypes",
    component: EquipmentTypes,
  },
  {
    path: "/admin/profile",
    name: "adminProfile",
    component: AdminProfile,
  },
  {
    path: "*",
    redirect: "/dashboard",
  },
];

const router = new VueRouter({
  mode: "history",
  base: process.env.BASE_URL,
  routes,
});

import store from "../store";

router.beforeEach((to, from, next) => {
  if (to.name == "login" || to.name == "register") {
    store.commit("mutationAuthReset");
    next();
    return;
  }



  store.dispatch("fillStore").then(() => {
    var isAuthenticated = store.state.status;
    var userType = store.state.userType;
    if (!isAuthenticated) {
      next({ name: "login" });
      return;
    }


    if (to.path.split("/")[1] != "admin" && userType == "A") {
      next({ name: "adminDashboard" });
      return;
    }


    if (to.path.split("/")[1] == "admin" && userType == "C") {
      next({ name: "dashboard" });
      return;
    }
    
    
    if (to.path.split("/")[1] == "admin" && userType == "C") {
      next({ name: "dashboard" });
      return;
    }


    if (to.name == "dashboard") {
      if (userType == "A") {
        next({ name: "adminDashboard" });
        return;
      }
    }
    next();
  });
});

export default router;
