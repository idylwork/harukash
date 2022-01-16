<template>
  <section class="headline-list-plate" :class="{'scrollable-right': scrollableRight, 'scrollable-left': scrollableLeft}">
    <div id="scroll_list" v-scroll="holizontalStatus" class="headline-item-list">
      <draggable tag="div" class="headline-item-list-group" :list="headlines">
        <div v-for="(headline, display_id) in headlines" class="headline-item" :key="headline.id">
          <a :href="'/sidedoor/headlines/' + headline.id + '/edit'">
            <div class="headline-item-image" :class="{ 'headline-item-image-hover': hover === headline.id }" v-on:mouseover="hoverItem(headline.id)" v-on:mouseleave="leaveItem">
              <div class="headline-item-position">
                <span class="headline-item-point" :style="{ top: headline.position_y + '%', left: headline.position_x + '%' }"></span>
                <span class="headline-item-id">{{ display_id + 1 }}</span>
                <img :src="headline.file.url">
              </div>
            </div>
          </a>
          <input type="hidden" :name="'headlines[' + display_id + ']'" :value="headline.id">
        </div>
      </draggable>
      <div class="headline-item-list-group">
        <div class="headline-item headline-item-new">
          <a href="/sidedoor/headlines/new">
            <div class="headline-item-position">
              <i class="material-icons">add</i>
            </div>
          </a>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
  import Vue from 'vue/dist/vue.esm'
  import draggable from 'vuedraggable';

  Vue.directive('scroll', {
    inserted: function(el, binding) {
      let f = function(e) {
        if (binding.value(e, el)) {
          el.removeEventListener('scroll', f)
        }
      }
      el.addEventListener('scroll', f)
    }
  })

  export default {
    components: {
      draggable
    },
    props: ['params'],
    data: function() {
      return {
        headlines: this.params.headlines,
        files: this.params.files,
        scrollableLeft: false,
        scrollableRight: false,
        hover: null
      }
    },
    mounted: function() {
      this.holizontalStatus(null, document.getElementById('scroll_list'))
    },
    methods: {
      /** 横スクロールの状況に応じてクラスを追加する */
      holizontalStatus: function(e, el) {
        this.scrollableLeft = (el.scrollLeft > 0);
        this.scrollableRight = (el.scrollLeft + el.clientWidth < el.scrollWidth);
      },
      /** hover CSS切り替え */
      hoverItem: function(key) {
        this.hover = key;
      },
      leaveItem: function() {
        this.hover = null;
      }
    }
  }
</script>
