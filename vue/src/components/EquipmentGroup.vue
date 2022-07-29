<template>
  <div class="d-flex flex-column">
    <div class="group group-list">
        <span class="group-title">{{ title }}</span>
        <div v-for="(item, index) in data" :key="index" class="d-flex flex-column group group-item">
            <div class="d-flex">
                <div class="d-flex flex-wrap flex-grow-1">
                    <div class="col-4 align-self-center">
                        <h5 class="mb-0">{{ item.name }}</h5>
                    </div>
                    <div class="col-4 align-self-center">
                        <h5 class="mb-0">{{ item.category }}</h5>
                    </div>
                    <div class="col-4 align-self-center">
                        <h5 class="text-right mb-0">{{ item.consumption + ' W' }}</h5>
                    </div>
                </div>
                <div class="buttons">
                    <button v-if="editable" type="button" class="btn btn-primary" @click="editFunction(item.id)"><i class="bi bi-pencil-square"></i></button>
                    <button v-if="deletable" type="button" class="btn btn-danger" @click="deleteFunction(item.id)"><i class="bi bi-x-square"></i></button>
                </div>
            </div>
        </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: {
      title: String,
      data: Array,
      editFunction: Function,
      deleteFunction: Function
    },
    data() {
        return {
            editable: this.editFunction != null,
            deletable: this.deleteFunction != null
        }
    }
  }
</script>

<style>
    .group {
        padding: 1rem;
        margin: 0.7rem 0;
        border-radius: 5px;
    }
    .group-list {
        background: rgba(93,84,240,0.5);
        border: 1px solid grey;
    }
    .group-item {
        background: white;
        margin: 10px 0;
        color: black;
    }
    .group-title {
        font-size:1.6rem;
        font-weight:500;
        color:white;
    }
    .buttons {
        margin-left: 10px
    }
    .buttons button {
        margin: 0 5px
    }
</style>