<template>
  <div>
    <div class="edit-color-button" :style="{ background: hex }" v-on:click="openPalette('hex', $event)"></div>
    <input type="hidden" :name="name" v-model="hex">
    <palette ref="palette" v-on:change-color="setColor" :palette="palette"></palette>
  </div>
</template>

<script>
  import palette from 'palette.vue'

  export default {
    components: { palette },
    props: ['name', 'value'],
    data: function() {
      return {
        palette: { style: '', x: 0, display_id: null, el: null },
        hex: this.value
      }
    },
    methods: {
      openPalette: function(prop, event) {
        this.palette.style = prop;

        let hex = this[prop].replace('#', '');

        // 子コンポーネント setHex()
        this.$refs.palette.open(hex);
      },
      setColor: function (rgb) {
        this[this.palette['style']] = rgb;
      },
    }
  }
</script>

<style scoped>
</style>
