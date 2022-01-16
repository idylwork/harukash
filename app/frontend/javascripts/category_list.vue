<template>
  <div>
    <draggable tag="ul" :list="categories" class="dew-sortable" :options="{handle:'.dew-sortable-handle'}">
      <li v-for="(category, display_id) in categories" v-show="!category._destroy" :key="display_id">
        <span class="dew-sortable-handle"><i class="material-icons">drag_handle</i></span>

        <input type="hidden" :name="'category[categories_attributes][' + display_id + '][id]'" v-model="category.id">
        <input type="hidden" :name="'category[categories_attributes][' + display_id + '][display_id]'" :value="display_id">
        <input type="text" :name="'category[categories_attributes][' + display_id + '][name]'" class="dew-text" v-model="category.name">
        <input type="hidden" :name="'category[categories_attributes][' + display_id + '][_destroy]'" value="true'" v-if="category._destroy">

        <button type="button" class="dew-sortable-button mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="remove(display_id)" v-if="categories.length > 1">clear<p class="button-label">削除</p></button>
      </li>
    </draggable>
    <div class="dew-sortable-append" v-on:click="append"><i class="material-icons">expand_more</i></div>
  </div>
</template>

<script>
  import Vue from 'vue/dist/vue.esm'
  import draggable from 'vuedraggable';

  export default {
    components: { draggable },
    props: ['params'],
    data: function() {
      return {
        categories: this.params,
      }
    },
    methods: {
      append: function() {
        this.categories.push({ id: null, name: '' });
      },
      remove: function(display_id) {
        if (typeof this.categories[display_id].id === 'number') {
          Vue.set(this.categories[display_id], '_destroy', true);
        } else {
          this.categories.splice(display_id, 1);
        }
      },
    }
  }
</script>