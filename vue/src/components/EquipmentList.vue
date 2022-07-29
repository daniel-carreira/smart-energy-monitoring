<template>
  <div class="d-flex flex-column">
    <EquipmentGroup
      v-for="(division, index) in divisions"
      :key="index"
      :title="division"
      :data="getEquipmentsByDivision(division)"
      :editFunction="editFunction"
      :deleteFunction="deleteFunction"
    />
  </div>
</template>

<script>
import EquipmentGroup from "../components/EquipmentGroup.vue";

export default {
  components: {
    EquipmentGroup,
  },
  props: {
    data: Array,
    editFunction: Function,
    deleteFunction: Function,
  },
  data() {
    return {
      editable: this.editFunction != null,
      deletable: this.deleteFunction != null,
    };
  },
  computed: {
    divisions() {
      return [...new Set(this.data.map((item) => item.division))];
    },
  },
  methods: {
    getEquipmentsByDivision(division) {
      return this.data.filter((item) => {
        return item.division == division;
      });
    },
  },
};
</script>

<style>
</style>