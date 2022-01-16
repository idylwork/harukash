<template>
  <section v-if="gauge.show">
    <div class="gauge-curtain" v-on:click.self="close" ></div>
    <div id="gauge_plate" class="gauge-plate" @mouseup="dragEnd" @mouseleave="dragEnd" @mousemove="dragCursor" :style="{left: gauge.x, top: gauge.y + 'px'}">
      <div class="gauge-stracture">
        <div><i class="material-icons mdc-list-item__graphic">photo_size_select_large</i></div>
        <div id="gauge_bar" class="gauge-bar" @mousedown="dragStart">
          <div @mousedown="dragStart" class="gauge-cursor" :style="{left:percent - 5 + '%'}"></div>
          <div class="gauge-bar-groove"></div>
        </div>
        <div class="gauge-console">
          {{ param }}%
        </div>
      </div>
    </div>
  </section>
</template>

<script>
  export default {
    props: ['gauge'],
    function() {
      return {
        paramMin: 40,
        paramMax: 100,
        percent: 100,
        cursorClickFlag: false,
        mouseDownFlag: false,
        cursorWidth: 14,
      }
    },
    methods: {
      //クリック
      dragStart: function(event) {
        this.changeFlag = true;
        this.dragCursor(event);
      },
      //カーソルクリック
      clickCursor: function() {
        this.changeFlag = true;
      },
      //ドラッグ時
      dragCursor: function(event) {
        if (this.changeFlag) {
          var container = document.getElementById("gauge_plate");

          var barArea = document.getElementById("gauge_bar");
          var cursorPos = event.pageX - this.gauge.x - barArea.offsetLeft - document.documentElement.scrollLeft;

          this.percent = cursorPos / barArea.offsetWidth * 100;
          if (this.percent < 0) {
            this.percent = 0;
          } else if (this.percent > 100) {
            this.percent = 100;
          }
        }
        this.$emit('change-param', this.param);
      },
      //マウスアップでフラグを解除
      dragEnd: function() {
        this.changeFlag = false;
        this.$emit('change-param', this.param);
      },

      open: function() {
        console.log(this.gauge);
        //this.gauge.show = true;
      },
      close: function() {
        this.gauge.show = false;
      }
    },
    computed: {
      param: function() {
        return Math.round(this.percent / this.ratio + this.paramMin);
      },
      ratio: function() {
        return 100 / (this.paramMax - this.paramMin);s
      }
    }
  });
</script>

<style scoped>
  .gauge-curtain {
    position: fixed;
    top: 0;
    left: 0;
    z-index: 1000;
    width: 100%;
    height: 100%;
  }
  .gauge-plate {
    position: absolute;
    top: 20px;
    left: 320px;
    z-index: 2000;
    width: 300px;
    background: #fff;
    text-align: center;
    user-select: none;
    padding: 10px 16px;
    border-radius: 30px;
    box-shadow: rgba(0, 0, 0, 0.4) 0px 5px 14px;
  }
  .gauge-label {
    display: inline-block;
    text-align: center;
    color: #cccccc;
    padding-bottom: 3px;
    width: 100%;
    margin: 14px 0;
  }
  .gauge-stracture {
    display: flex;
    user-select: none;
    padding: 6px 10px;
  }
  .gauge-bar {
    position: relative;
    width: 100%;
    height: 17px;
    padding-top: 7px;
    cursor: pointer;
  }
  .gauge-bar-groove {
    background: #555355;
    height: 2px;
  }
  .gauge-cursor {
    position: absolute;
    width: 20px;
    height: 20px;
    top: -2px;
    border-radius: 50%;
    background-color: #ffffff;
    box-shadow: rgba(0, 0, 0, 0.4) 0px 3px 4px;
    cursor: pointer;
  }
  .gauge-console {
    width: 50px;
    margin-left: 20px;
  }
</style>
