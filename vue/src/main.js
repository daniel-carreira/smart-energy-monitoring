import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'

import VueSocketIO from 'vue-socket.io'

import axios from 'axios'
axios.defaults.baseURL = 'http://smartenergymonitoring.dei.estg.ipleiria.pt/api'

import { BootstrapVue, IconsPlugin } from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import VueApexCharts from 'vue-apexcharts'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faHouse } from '@fortawesome/free-solid-svg-icons'
import { faMagnifyingGlassChart } from '@fortawesome/free-solid-svg-icons'
import { faUserGroup } from '@fortawesome/free-solid-svg-icons'
import { faGear } from '@fortawesome/free-solid-svg-icons'
import { faBolt } from '@fortawesome/free-solid-svg-icons'
import { faWindowMinimize } from '@fortawesome/free-solid-svg-icons'
import { faCircleChevronDown } from '@fortawesome/free-solid-svg-icons'
import { faPlugCircleBolt } from '@fortawesome/free-solid-svg-icons'
import { faLocationDot } from '@fortawesome/free-solid-svg-icons'
import { faCalendar } from '@fortawesome/free-solid-svg-icons'
import { faPlug } from '@fortawesome/free-solid-svg-icons'
import { faHouseChimneyWindow } from '@fortawesome/free-solid-svg-icons'
import { faCirclePlus } from '@fortawesome/free-solid-svg-icons'
import { faPlay } from '@fortawesome/free-solid-svg-icons'
import { faStop } from '@fortawesome/free-solid-svg-icons'
import { faPlus } from '@fortawesome/free-solid-svg-icons'
import { faTrash } from '@fortawesome/free-solid-svg-icons'
import { faPen } from '@fortawesome/free-solid-svg-icons'
import { faFloppyDisk } from '@fortawesome/free-solid-svg-icons'
import { faBan } from '@fortawesome/free-solid-svg-icons'
import { faTriangleExclamation } from '@fortawesome/free-solid-svg-icons'
import { faUserGear } from '@fortawesome/free-solid-svg-icons'
import { faUser } from '@fortawesome/free-solid-svg-icons'
import { faUsers } from '@fortawesome/free-solid-svg-icons'
import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons'
import { faLock } from '@fortawesome/free-solid-svg-icons'
import { faUnlock } from '@fortawesome/free-solid-svg-icons'
import { faBell } from '@fortawesome/free-solid-svg-icons'
import { faBellSlash } from '@fortawesome/free-solid-svg-icons'
import { faArrowsRotate } from '@fortawesome/free-solid-svg-icons'

const socketIO = new VueSocketIO({
  debug: true,
  connection: "http://smartenergymonitoring.dei.estg.ipleiria.pt:80",
  vuex: {
    store,
    actionPrefix: 'SOCKET_',
    mutationPrefix: 'SOCKET_'
  }
})

import vuetify from './plugins/vuetify'

library.add(faArrowsRotate, faBellSlash, faBell, faBan, faFloppyDisk, faPen, faTrash, faPlus, faStop, faPlay, faHouse, faMagnifyingGlassChart, faUserGroup, faGear, faBolt, faWindowMinimize, faCircleChevronDown, faPlugCircleBolt, faLocationDot, faCalendar, faPlug, faHouseChimneyWindow, faCirclePlus, faTriangleExclamation, faUserGear, faUsers, faUser, faMagnifyingGlass, faLock, faUnlock)
Vue.component('font-awesome-icon', FontAwesomeIcon)
Vue.use(socketIO)
Vue.use(BootstrapVue)
Vue.use(VueApexCharts)

store.$socket = socketIO.io


Vue.component('apexchart', VueApexCharts)
new Vue({
  router,
  store,
  vuetify,
  render: function (h) { return h(App) }
}).$mount('#app')


