<template>
<section class="globe" :class="{ 'globe-fixed': this.fixed }" v-if="palette.style">
    <div class="curtain" v-on:click.self="close"></div>
    <div id="palette_plate" class="plate" @mouseup="selectEnd" @mouseleave="selectEnd" @mousemove="dragPlate" :style="{ left: x, top: y }">
      <p class="label">Color Pick</p>
      <div class="platte-stracture">
        <div id="huepicker" class="hue" @mousedown="hueSelectStart">
          <div @mousedown="hueCursorClick" class="hue-cursor" :style="{top:hueCursorPos + 'px'}"></div>
        </div>
        <div id="palette_map" class="map" @mousedown="colorSelect" :style="{ backgroundColor: 'hsl(' + this.hsv.h + ',100%,50%)' }">
          <div :style="{left:colorCursor.left + 'px',top:colorCursor.top + 'px'}" class="map-cursor" :class="colorCursorState" v-if="rgb2hex !== 'transparent'"></div>
        </div>
        <div class="console-area">
          <div class="preview" :class="{ 'preview-transparent': rgb2hex === 'transparent' }" :style="{backgroundColor:rgb2hex}"></div>
          <div class="console-rgb">
            <div class="console-box">
              <span class="console-label">R</span><input type="text" class="console-input" :value="rgb.r" @keydown="colorNumInput('r', arguments[0])" @blur="colorNumInput('r', arguments[0])">
            </div>
            <div class="console-box">
              <span class="console-label">G</span><input type="text" class="console-input" :value="rgb.g" @keydown="colorNumInput('g', arguments[0])" @blur="colorNumInput('g', arguments[0])">
            </div>
            <div class="console-box">
              <span class="console-label">B</span><input type="text" class="console-input" :value="rgb.b" @keydown="colorNumInput('b', arguments[0])" @blur="colorNumInput('b', arguments[0])">
            </div>
          </div>
          <div>
            <span class="console-label">RGB</span>
            <input type="text" class="console-input" :value="rgb2hex" @blur="hexInput" @keyup.13="hexInput" @focus="focusAndSelect">
          </div>
          <div class="clear" @mousedown="clearColor">
            Clear
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
  import Vue from 'vue/dist/vue.esm'

  export default {
    props: ['palette'],
    data: function() {
      return {
        x: null,
        y: null,
        fixed: true,
        hsv: {
          h: 360, s: 100, v: 100
        },
        rgb: {
          r: 255, g: 0, b: 0
        },
        mapSize: 180,
        isChangingHue: false,
        isChangingChromaValue: false,
        onClickHueCursor: false,
        hueCursorSize: 14,
        colorCursorSize: 16,
        container: {
          left: 40,
          top: 40
        },
        queue: null
      };
    },
    methods: {
      /** 色相カーソルクリック */
      hueCursorClick: function() {
        this.onClickHueCursor = true;
      },
      /** 色相バークリック */
      hueSelectStart: function(event) {
        this.isChangingHue = true;
        var ajustY = 0;
        if (this.onClickHueCursor) {
          ajustY = this.hueCursorPos + this.hueCursorSize/2;
        }

        this.hsv.h = Math.round(
          Math.abs((event.offsetY + ajustY) * this.hueUnit - 360)
        );
        this.rgb = this.hsv2rgb;
      },
      /** カラーピッカークリック */
      colorSelect: function(event) {
        this.isChangingChromaValue = true;
        this.hsv.s = Math.round((event.offsetX) * this.colorUnit);
        this.hsv.v = Math.round(
          Math.abs((event.offsetY) * this.colorUnit - 100)
        );

        this.rgb = this.hsv2rgb;
      },
      /** パレット内ドラッグ */
      dragPlate: function(event) {
        var cx = event.pageX;
        var cy = event.pageY;
        if (!(this.palette.display_id instanceof Object)) cy -= document.documentElement.scrollTop;

        var container = document.getElementById("palette_plate");
        var colorArea = document.getElementById("palette_map");
        var conT = container.offsetTop;
        var conL = container.offsetLeft;
        if (this.fixed) {
          conT += window.pageYOffset;
          conL += window.pageXOffset;
        }

        //色相ドラッグ
        if (this.isChangingHue) {
          var hueArea = document.getElementById("huepicker");
          var ht = hueArea.offsetTop + conT;
          var hh = hueArea.clientHeight;

          var hueCursorPos = cy - ht;

          if (hueCursorPos < 0) {
            hueCursorPos = 0;
          } else if (hueCursorPos > hh) {
            hueCursorPos = hh;
          }

          this.hsv.h = Math.round(Math.abs(this.hueUnit * hueCursorPos - 360));
          this.rgb = this.hsv2rgb;
        }

        //カラーピッカードラッグ
        if (this.isChangingChromaValue) {
          var ct = colorArea.offsetTop + conT;
          var cl = colorArea.offsetLeft + conL;
          var ch = colorArea.clientHeight;
          var cw = colorArea.clientWidth;

          var colorCursorPosY = cy - ct;
          if (colorCursorPosY < 0) {
            colorCursorPosY = 0;
          } else if (colorCursorPosY > ch) {
            colorCursorPosY = ch;
          }
          var colorCursorPosX = cx - cl;
          if (colorCursorPosX < 0) {
            colorCursorPosX = 0;
          } else if (colorCursorPosX > cw) {
            colorCursorPosX = cw;
          }
          this.hsv.s = Math.round(colorCursorPosX * this.colorUnit);
          this.hsv.v = Math.round(
            Math.abs(colorCursorPosY * this.colorUnit - 100)
          );
          this.rgb = this.hsv2rgb;
        }
      },
      //マウスアップで全フラグを解除
      selectEnd: function() {
        this.isChangingHue = false;
        this.isChangingChromaValue = false;
        this.onClickHueCursor = false;
      },
      //16進数コード入力
      hexInput: function(event) {
        var hex = event.target.value;
        hex = hex.replace('#', "");
        if (!/[A-Fa-f0-9]+/.test(hex)) {
          return false;
        } else {
          if (hex.length != 6 && hex.length != 3) {
            return false;
          } else {
            if (hex.length == 3) {
              hex = hex.charAt(0) + hex.charAt(0) + hex.charAt(1) + hex.charAt(1) + hex.charAt(2) + hex.charAt(2);
            }
          }
        }
        this.setHex(hex);
      },
      //RGB入力時
      colorNumInput: function(color, event) {
        if (event.type != "keydown" && event.type != "blur") {
          return false;
        } else {
          var val = event.target.value;
          if (!val.match(/\d+/)) {
            return false;
          }
          val = Number(val);

          if (event.type == "keydown") {
            if (event.key != "Enter" && event.key != "ArrowUp" && event.key != "ArrowDown" && !event.shiftKey) {
              return false;
            } else {
              var changeNum = 1;
              if (event.shiftKey) {
                changeNum = 10;
              }

              if (event.key == "ArrowUp") {
                val += changeNum;
              } else if (event.key == "ArrowDown") {
                val -= changeNum;
              }
            }
          }

          if (color == "r" || color == "b" || color == "g") {
            if (val > 255) {
              val = 255;
            } else if (val < 0) {
              val = 0;
            }
            if (color == "r") {
              this.rgb.r = val;
            } else if (color == "g") {
              this.rgb.g = val;
            } else if (color == "b") {
              this.rgb.b = val;
            }
            this.hsv = this.rgb2hsv;
          }
        }
      },

      //テキストボックスフォーカス
      focusAndSelect: function(event) {
        event.target.select();
      },

      clearColor: function() {
        this.rgb = {r: null, g: null, b: null};
      },

      //16進数→RGB値
      setHex: function(hex) {
        if (hex === 'transparent') {
          this.rgb = { r: null, g: null, b:null }
        } else {
          this.rgb = {
            r: parseInt(hex.slice(0, 2), 16),
            g: parseInt(hex.slice(2, 4), 16),
            b: parseInt(hex.slice(4), 16)
          };
        }
        this.hsv = this.rgb2hsv;
      },
      setPos: function() {
        let pos = this.palette.el.getBoundingClientRect();
        this.x = pos.left + this.palette.x + window.pageXOffset + 'px';
        this.y = pos.top + window.pageYOffset + 'px';
      },
      refreshPos: function() {
        clearTimeout(this.queue);
        this.queue = setTimeout(this.setPos, 300);
      },
      open: function(hex) {
        if (this.palette.el) {
          this.fixed = false;
          this.setPos();
          window.addEventListener('resize', this.refreshPos, false);
        } else {
          this.fixed = true;
          this.x = null, this.y = null;
        }
        this.setHex(hex);
      },
      close: function() {
        this.palette.style = '';
        if (this.palette.el) {
          window.removeEventListener('resize', this.refreshPos, false);
        }
      }
    },
    computed: {
      hueUnit: function() {
        return 360 / this.mapSize;
      },
      hueCursorPos: function() {
        return Math.round(
          Math.abs(this.hsv.h - 360) / this.hueUnit - this.hueCursorSize / 2
        );
      },
      colorUnit: function() {
        return 100 / this.mapSize;
      },
      colorCursor: function() {
        return {
          left: this.hsv.s / this.colorUnit - this.colorCursorSize / 2,
          top:
          Math.abs(this.hsv.v / this.colorUnit - this.mapSize) -
          this.colorCursorSize / 2
        };
      },
      //カラーピッカーのカーソルの位置によって色を変える
      colorCursorState: function() {
        var color = "white";
        if (this.hsv.h <= 201 && this.hsv.h >= 22) {
          if (this.hsv.v >= 50) {
            color = "black";
          } else {
            color = "white";
          }
        } else {
          if (this.hsv.v >= 50 && this.hsv.s <= 71) {
            color = "black";
          } else {
            color = "white";
          }
        }
        return color;
      },
      //RGB→16進数 change-colorイベントを発生
      rgb2hex: function() {
        let result = 'transparent';
        if (this.rgb.r !== null) {
          this.rgb.r = Math.round(this.rgb.r);
          this.rgb.g = Math.round(this.rgb.g);
          this.rgb.b = Math.round(this.rgb.b);
          result = '#' + ("00" + this.rgb.r.toString(16)).slice(-2) + ("00" + this.rgb.g.toString(16)).slice(-2) + ("00" + this.rgb.b.toString(16)).slice(-2);
        }
        this.$emit('change-color', result);
        return result;
      },
      //RGB→HSV
      rgb2hsv: function() {
        var rr, gg, bb,
            r = this.rgb.r / 255,
            g = this.rgb.g / 255,
            b = this.rgb.b / 255,
            h, s, v = Math.max(r, g, b),
            diff = v - Math.min(r, g, b),
            diffc = function(c) {
              return (v - c) / 6 / diff + 1 / 2;
            };
        if (diff === 0) {
          h = s = 0;
        } else {
          s = diff / v;
          rr = diffc(r);
          gg = diffc(g);
          bb = diffc(b);

          if (r === v) {
            h = bb - gg;
          } else if (g === v) {
            h = 1 / 3 + rr - bb;
          } else if (b === v) {
            h = 2 / 3 + gg - rr;
          }
          if (h < 0) {
            h += 1;
          } else if (h > 1) {
            h -= 1;
          }
        }

        if (this.hsv.h == 360 && h == 0) {
          h = 1;
        }
        return {
          h: Math.round(h * 360),
          s: Math.round(s * 100),
          v: Math.round(v * 100)
        };
      },
      //HSV→RGB
      hsv2rgb: function() {
        var h = this.hsv.h;
        var s = this.hsv.s;
        var v = this.hsv.v;

        var max = v;
        var min = max - s / 255 * max;
        var rgb = { r: 0, g: 0, b: 0 };

        if (h == 360) {
          h = 0;
        }

        s = s / 100;
        v = v / 100;

        if (s == 0) {
          rgb.r = v * 255;
          rgb.g = v * 255;
          rgb.b = v * 255;
          return rgb;
        }

        var dh = Math.floor(h / 60);
        var p = v * (1 - s);
        var q = v * (1 - s * (h / 60 - dh));
        var t = v * (1 - s * (1 - (h / 60 - dh)));

        switch (dh) {
          case 0: rgb.r = v; rgb.g = t; rgb.b = p; break;
          case 1: rgb.r = q; rgb.g = v; rgb.b = p; break;
          case 2: rgb.r = p; rgb.g = v; rgb.b = t; break;
          case 3: rgb.r = p; rgb.g = q; rgb.b = v; break;
          case 4: rgb.r = t; rgb.g = p; rgb.b = v; break;
          case 5: rgb.r = v; rgb.g = p; rgb.b = q; break;
        }

        rgb.r = Math.round(rgb.r * 255);
        rgb.g = Math.round(rgb.g * 255);
        rgb.b = Math.round(rgb.b * 255);

        return rgb;
      }
    }
  };

</script>

<style scoped>
  .globe {
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    align-items: center;
    justify-content: center;
  }
  @media screen and (max-width: 680px)  {
    .globe {
      position: fixed;
      display: flex;
      z-index: 1000;
    }
    .plate {
      top: unset !important;
      left: unset !important;
    }
  }
  .globe.globe-fixed {
    position: fixed;
    display: flex;
    z-index: 1000;
  }
  .curtain {
    position: fixed;
    top: 0;
    left: 0;
    z-index: 1010;
    background: rgba(0, 0, 0, 0.2);
    width: 100%;
    height: 100%;
  }
  .plate {
    position: absolute;
    z-index: 2000;
    max-width: 410px;
    height: 250px;
    text-align: center;
    background: #ffffff;
    border-radius: 12px;
    box-shadow: rgba(0, 0, 0, 0.4) 0px 5px 14px;
    user-select: none;
    padding: 0px 22px 26px 20px;
    box-sizing: border-box;
  }
  .platte-stracture {
    display: flex;
    justify-content: space-between;
  }

  /* ラベル */
  .label {
    display: inline-block;
    text-align: center;
    color: #cccccc;
    padding-bottom: 3px;
    width: 100%;
    margin: 14px 0;
  }

  /* 色 */
  .map {
    position: relative;
    overflow: hidden;
    width: 180px;
    height: 180px;
    background-color: rgb(255, 0, 0);
    background-image: linear-gradient(rgba(0, 0, 0, 0), rgb(0, 0, 0)), linear-gradient(to right, rgb(255, 255, 255), rgba(255, 255, 255, 0));
    cursor: pointer;
  }
  .map-cursor {
    pointer-events: none;
    position: absolute;
    width: 17px;
    height: 17px;
    left: 180px;
    top: -9px;
    box-sizing: border-box;
    background: linear-gradient(transparent 46%, white 46%, white 53%, transparent 53%), linear-gradient(90deg, transparent 47%, white 47%, white 53%, transparent 53%);
    border: 1px solid white;
    border-radius: 50%;
  }
  .map-cursor.black {
    border-color: #000000;
    background: linear-gradient(transparent 46%, black 46%, black 53%, transparent 53%), linear-gradient(90deg, transparent 47%, black 47%, black 53%, transparent 53%);
  }

  /* 色相 */
  .hue {
    position: relative;
    width: 3px;
    height: 180px;
    margin-right: 20px;
    background-image: linear-gradient(
      hsl(360,100%,50%), hsl(300,100%,50%),
      hsl(240,100%,50%), hsl(180,100%,50%),
      hsl(120,100%,50%), hsl(60,100%,50%),
      hsl(0,100%,50%)
    );
    cursor: pointer;
  }
  .hue-cursor {
    position: absolute;
    width: 20px;
    height: 20px;
    background: red;
    border-radius: 50%;
    left: -8px;
    background-color: #ffffff;
    box-shadow: rgba(0, 0, 0, 0.4) 0px 3px 4px;
  }

  /* コンソール */
  .console-area {
    flex-basis: 150px;
    margin-left: 20px;
  }
  .preview {
    height: 65px;
    background: rgb(255, 255, 255);
  }
  .preview.preview-transparent {
    background: url(../images/bg_transparent.gif);
  }
  .console-label {
    display: inline-block;
    position: relative;
    top: 6px;
    font-size: 12px;
    background: #fff;
    padding: 0 6px;
  }
  .console-input {
    width: 100%;
    font-size: 12px;
    text-align: center;
    padding: 5px 7px;
    border: 1px solid #ccc;
    border-radius: 2px;
    box-sizing: border-box;
  }
  .console-rgb {
    display: flex;
    justify-content: space-between;
    margin: 0 -4px;
  }
  .console-box {
    margin: 0 4px;
  }
  .clear {
    margin-top: 6px;
  }
</style>
