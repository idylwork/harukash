<template>
  <draggable tag="div" :list="projects">
    <transition-group name="stone-preview" tag="ul" class="project-batch-list mdc-list mdc-list--two-line">
      <li v-for="(project, order) in projects" :key="project.id" class="mdc-list-item mdc-ripple-upgraded" :class="{ 'project-batch-list-item-hover': hoveredCategory === project.category }" v-on:mouseover="hoverItem(order)" v-on:mouseleave="leaveItem">
        <input type="hidden" :name="'project[projects_attributes][' + order + '][id]'" :value="project.id">
        <span class="mdc-list-item__text">
          <span class="mdc-list-item__primary-text">{{ project.title }}</span>
          <span class="project-list-item-text-secondary mdc-list-item__secondary-text">{{ project.category }} - {{project.overview}}</span>
        </span>
        <span class="mdc-list-item__meta material-icons" v-if="hoveredCategory === project.category">landscape</span>
      </li>
    </transition-group>
  </draggable>
</template>

<script>
  import draggable from 'vuedraggable';

  export default {
    components: { draggable },
    props: ['params'],
    data: function() {
      return {
        projects: this.params,
        hover: null
      }
    },
    methods: {
      /** hover CSS切り替え */
      hoverItem: function(key) {
        this.hover = key;
      },
      leaveItem: function() {
        this.hover = null;
      }
    },
    computed: {
      hoveredCategory: function() {
        if (this.hover === null) return;
        return this.projects[this.hover].category;
      }
    }
  }
</script>