<template>
  <div>
    <input type="hidden" :name="'sticky[color_txt]'" :value="color_txt">
    <input type="hidden" :name="'sticky[color_bg_start]'" :value="color_bg_start">
    <input type="hidden" :name="'sticky[color_bg_end]'" :value="color_bg_end">
    <textarea class="dew-file-input" :name="'sticky[html_en]'" :value="htmlEn"></textarea>
    <textarea class="dew-file-input" :name="'sticky[html_jp]'" :value="htmlJp"></textarea>
    <input type="file" name="sticky[file]" class="sticky-edit-dew-file-input" id="sticky_file" v-on:change="onFileChange($event)">

    <h2 class="island-header island-header-control">
      <div class="mdc-form-field">
        <label>Sticky</label>
      </div>
      <div class="island-header-buttons">
        <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette('color_txt', $event)">format_color_text<p class="button-label">文字色</p></button>
        <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette('color_bg_start', $event)">fast_rewind<p class="button-label">開始色</p></button>
        <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette('color_bg_end', $event)">fast_forward<p class="button-label">終了色</p></button>
      </div>
    </h2>
    <palette ref="palette" v-on:change-color="setColor" :palette="palette"></palette>

    <p class="tip tip-right tip-closer">
      <i class="material-icons">format_color_text</i> 文字色を変更します。<br>
      <i class="material-icons">fast_forward</i><i class="material-icons">fast_rewind</i> 背景色を変更します。
    </p>

    <p class="tip">トップページに表示される告知エリアを編集します。</p>

    <div class="sticky-edit-control">
      <div class="mdc-form-field">
        <div class="mdc-radio mdc-ripple-upgraded mdc-ripple-upgraded--unbounded">
          <input class="mdc-radio__native-control" type="radio" id="sticky-locale-en" checked="" name="radio" value="en" v-model="locale" v-on:mousedown="closeEditor(false)">
          <div class="mdc-radio__background">
            <div class="mdc-radio__outer-circle"></div>
            <div class="mdc-radio__inner-circle"></div>
          </div>
        </div>
        <label for="sticky-locale-en">English</label>
      </div>
      <div class="mdc-form-field">
        <div class="mdc-radio mdc-ripple-upgraded mdc-ripple-upgraded--unbounded">
          <input class="mdc-radio__native-control" type="radio" id="sticky-locale-jp" name="radio" value="jp" v-model="locale">
          <div class="mdc-radio__background">
            <div class="mdc-radio__outer-circle"></div>
            <div class="mdc-radio__inner-circle"></div>
          </div>
        </div>
        <label for="sticky-locale-en">Japanese</label>
      </div>
    </div>
    <p class="tip tip-center tip-closer">編集する言語を選択します。何も入力されていない言語は表示されません。</p>

    <div v-if="selected !== null" class="sticky-edit-editor-curtain" v-on:click.self="closeEditor(false)"></div>
    <section class="sticky-plate" :style="{ 'color': color_txt, 'background': 'linear-gradient(120deg, ' + color_bg_start + ', ' + color_bg_end + ')' }">
      <div v-for="(node, line) in nodes[locale]" ref="node_area" class="sticky-edit-island">
        <div v-if="selected === null" class="sticky-edit-new" :class="{'sticky-edit-new-active': isAppendMode }">
          <div class="sticky-edit-new-menu" :class="'sticky-edit-margin-' + node.margin">
            <div class="sticky-edit-new-menu-surface">
              <button type="button" v-on:click="appendAndOpen(line, 'p')" class="mdc-icon-button mdc-icon-button--colored material-icons mdc-supp-icon-button-mini">format_align_left<p class="button-label">文章</p></button>
              <button type="button" v-on:click="appendAndOpen(line, 'h2')" class="mdc-icon-button mdc-icon-button--colored material-icons mdc-supp-icon-button-mini">title<p class="button-label">見出し</p></button>
              <button type="button" v-on:click="appendAndOpen(line, 'a')" class="mdc-icon-button mdc-icon-button--colored material-icons mdc-supp-icon-button-mini">link<p class="button-label">リンク</p></button>
              <button type="button" v-on:click="appendAndOpen(line, 'img')" v-if="!imgNodeExists" class="mdc-icon-button mdc-icon-button--colored material-icons mdc-supp-icon-button-mini">image<p class="button-label">画像</p></button>  
            </div>
          </div>
        </div>
        <div v-if="selected !== line" v-on:click="openEditor(line, $event)" v-html="nodeHtmls[locale][line]"></div>
        <div class="sticky-edit-editor" v-if="selected === line">
          <textarea ref="editor" class="sticky-edit-dew" :class="'sticky-margin-' + node.margin" :style="{ 'color': color_txt }" v-model="innerText" v-if="node.tag !== 'img'" v-on:input="editorExpand" v-on:keypress.enter="closeEditor()" v-on:keydown.delete="closeIfFirst()"></textarea>
          <label class="sticky-edit-dew-file" for="sticky_file" :class="'sticky-margin-' + node.margin" v-if="node.tag === 'img'">
            <img class="sticky-edit-dew-file-image" :src="image.preview">
          </label>
          <div class="sticky-edit-menu">
            <button type="button" v-on:click="changeMargin(-1)" v-if="line > 0" class="mdc-icon-button mdc-icon-button--colored material-icons">arrow_drop_up<p class="button-label">上げる</p></button>
            <button type="button" v-on:click="changeMargin(1)" v-if="line > 0" class="mdc-icon-button mdc-icon-button--colored material-icons">arrow_drop_down<p class="button-label">下げる</p></button>
            <button type="button" v-on:click="closeAndRemove()" class="mdc-icon-button mdc-icon-button--colored material-icons">content_cut<p class="button-label">削除</p></button>
            <button type="button" v-on:click="closeEditor()" class="mdc-icon-button mdc-icon-button--colored material-icons">check<p class="button-label">OK</p></button>
            <input class="sticky-edit-dew" v-if="node.attr === 'href'" v-model="node.value">
            <p class="tip tip-closer"><i class="material-icons">content_cut</i> 段落を削除します。<i class="material-icons">check</i> 段落の編集を確定します。</p>
            <p class="tip tip-closer" v-if="line > 0"><i class="material-icons">arrow_drop_up</i> <i class="material-icons">arrow_drop_down</i> 前の段落との間隔を調整します。</p>
          </div>
        </div>
      </div>

      <div v-if="selected === null" class="sticky-edit-new" :class="{ 'sticky-edit-new-active': isAppendMode || nodes[locale].length <= 0 }">
        <div class="sticky-edit-new-menu">
          <div class="sticky-edit-new-menu-surface">
            <button type="button" v-on:click="appendAndOpen(nodes[locale].length, 'p')" class="mdc-icon-button mdc-icon-button--colored material-icons mdc-supp-icon-button-mini">format_align_left<p class="button-label">文章</p></button>
            <button type="button" v-on:click="appendAndOpen(nodes[locale].length, 'h2')" class="mdc-icon-button mdc-icon-button--colored material-icons mdc-supp-icon-button-mini">title<p class="button-label">見出し</p></button>
            <button type="button" v-on:click="appendAndOpen(nodes[locale].length, 'a')" class="mdc-icon-button mdc-icon-button--colored material-icons mdc-supp-icon-button-mini">link<p class="button-label">リンク</p></button>
            <button type="button" v-on:click="appendAndOpen(nodes[locale].length, 'img')" v-if="!imgNodeExists" class="mdc-icon-button mdc-icon-button--colored material-icons mdc-supp-icon-button-mini">add_a_photo<p class="button-label">画像</p></button>  
          </div>
        </div>
      </div>
    </section>

    <div class="sticky-edit-control">
      <div class="mdc-form-field">
        <div class="mdc-checkbox">
          <input type="checkbox" id="sticky_append_mode" class="mdc-checkbox__native-control" value="true" v-model="isAppendMode">
          <div class="mdc-checkbox__background">
            <svg class="mdc-checkbox__checkmark" viewBox="0 0 24 24">
              <path class="mdc-checkbox__checkmark-path" fill="none" stroke="white" d="M1.73,12.91 8.1,19.28 22.79,4.59"></path>
            </svg>
            <div class="mdc-checkbox__mixedmark"></div>
          </div>
        </div>
        <label for="sticky_append_mode">Append Mode</label>
      </div>
    </div>
    <p class="tip tip-center">
      段落を追加します。チェックを入れたのち<br>
      段落を追加したい位置の段落種別をクリックしてください。<br>
      <i class="material-icons">format_align_left</i> 文章 <i class="material-icons">title</i> 見出し <i class="material-icons">link</i> リンク <i class="material-icons">add_a_photo</i> 画像
    </p>
  </div>
</template>

<script>
  import Vue from 'vue/dist/vue.esm'
  import palette from 'palette.vue'
  import Uploadable from 'uploadable.js'

  /** 付箋の編集 */
  export default {
    components: { palette },
    props: ['params'],
    mixins: [Uploadable],
    data: function() {
      return {
        nodes: {
          en: this.params.nodes.en,
          jp: this.params.nodes.jp
        },
        nodeHtmls: {
          en: [],
          jp: []
        },
        attrs: {
          h2: null,
          p: null,
          a: 'href',
          img: 'src',
        },
        classes: {
          h2: 'sticky-heading',
          p: 'sticky-text',
          a: 'sticky-link',
          img: 'sticky-image',
          margin: [
            'sticky-margin-0',
            'sticky-margin-1',
            'sticky-margin-2',
            'sticky-margin-3',
          ]
        },
        nodesJp: [],
        locale: this.params.locale,
        selected: null,
        selectedNode: null,
        innerText: '',
        image: {
          preview: this.params.image_url,
          file: { url: this.params.image_url },
        },
        isAppendMode: false,
        color_txt: this.params.color_txt,
        color_bg_start: this.params.color_bg_start,
        color_bg_end: this.params.color_bg_end,
        editorTop: 0,
        palette: { style: '', x: -360, el: null}
      }
    },
    mounted: function() {
      this.updateHtml('jp');
      this.updateHtml('en');
    },
    methods: {
      /** ノードを選択する */
      selectNode: function(line = null) {
        this.selected = line;
        if (line === null) {
          this.selectedNode = null;
          this.innerText = '';
        } else {
          this.selectedNode = this.nodes[this.locale][line];
          this.innerText = this.selectedNode.text;
        }
      },
      /** ノードを作成する */
      createNode: function(tag = 'p') {
        return {
          text: '',
          tag: tag,
          attr: this.attrs[tag],
          value: tag === 'img' ? '' : 'https://',
          margin: 0
        }
      },
      /** ノード情報を基準にHTMLソースを更新する */
      updateHtml: function(locale = null) {
        locale = locale || this.locale;
        let html = '';
        this.nodeHtmls[locale] = [];
        this.nodes[locale].forEach((node, line) => {
          if (node.tag === 'img') {
            if (this.image.preview) {
              html += '<img src="' + this.escapeHtml(node.value) + '"';
              html += ' src="' + this.image.preview + '"';
              html += ' class="' + this.classes[node.tag] + ' ' + this.classes.margin[node.margin] + '">';
            }
          } else if (node.text && this.classes[node.tag]) {
            if (node.tag === 'a') {
              html = '<p class="' + this.classes[node.tag] + ' ' + this.classes.margin[node.margin] + '">';
              html += '<a href="' + this.escapeHtml(node.value) + '" target="_blank">';
              html += node.text + '</a></p>\n';              
            } else {
              html = '<' + node.tag;
              html += ' class="' + this.classes[node.tag] + ' ' + this.classes.margin[node.margin] + '">';
              html += node.text + '</' + node.tag + '>\n';
            }
            this.$set(this.nodeHtmls[locale], line, html);
          }
        });
      },
      updateHtmlNode: function() {

      },
      escapeHtml: function(str) {
        return str.replace(/&/g, "&amp;")
          .replace(/</g, "&lt;")
          .replace(/>/g, "&gt;")
          .replace(/"/g, "&quot;")
          .replace(/'/g, "&#39;")
          .replace(/`/g, '&#x60;')
          .replace(/\r\n|\n/g, "");
      },
      /** 編集を開始する */
      openEditor: function(line, e = null) {
        if (e) e.preventDefault();
        if (this.selected) return this.closeEditor();
        this.selectNode(line);
        this.isAppendMode = false;

        this.$nextTick(() => {
          this.editorExpand();
          const editor = (this.$refs.editor || [])[0];
          if (editor) {
            editor.focus();
            editor.setSelectionRange(editor.value.length, editor.value.length); 
          }
        });
      },
      /** ノードを追加して編集 */
      appendAndOpen: function(line, tag) {
        let node = this.createNode(tag);
        this.nodes[this.locale].splice(line, 0, node);        
        this.updateHtml();
        this.openEditor(line);
      },
      /** 編集エリアを閉じる */
      closeEditor: function(withUpdate = true) {
        if (this.selected === null) return;
        this.innerText = this.innerText.trim();
        if (!this.selectedNode || (this.selectedNode.tag !== 'img' && this.innerText === '')) {
          // 入力がなければ削除
          this.nodes[this.locale].splice(this.selected, 1);
        } else if (withUpdate) {
          // ノード更新
          if (this.selectedNode.tag === 'img') {
            if (this.image.preview) {
              this.$set(this.selectedNode, 'value', this.image.preview);
            } else {
              this.nodes[this.locale].splice(this.selected, 1);
            }
          } else {
            this.$set(this.selectedNode, 'text', this.innerText);
          }
        }
        this.selectNode();
        this.updateHtml();
      },
      /** ノードを削除して閉じる */
      closeAndRemove: function() {
        this.selectedNode = null;
        this.closeEditor();
      },
      /** Enterで改行されていれば閉じる */
      closeIfReturn: function() {
        let editor = (this.$refs.editor || [])[0];
        if (editor && this.$refs.editor.value) {
          this.closeEditor();
        }
      },
      /** 最初の文字でBackSpaceなら閉じる */
      closeIfFirst: function() {
        let editor = (this.$refs.editor || [])[0];
        if (editor && this.selected > 0 && editor.selectionEnd <= 0) {
          this.closeEditor();
        }
      },
      /** マージンを変更する */
      changeMargin: function(value) {
        let margin = this.selectedNode.margin + value;
        if (margin >= 0 && margin < this.marginClassCount) {
          this.$set(this.selectedNode, 'margin', margin);
          this.updateHtml();
        }
      },
      /** テキストエリアを自動拡張 */
      editorExpand: function(e) {
        const editor = (this.$refs.editor || [])[0]; 
        if (editor && editor.scrollHeight > editor.offsetHeight && editor.offsetHeight < 400) {
          editor.style.height = editor.scrollHeight + 'px';
        }
      },
      /** パレットを開く */
      openPalette: function(style, event) {
        this.palette.el = event.currentTarget;
        this.palette.style = style;

        let hex = this[style].replace('#', '');
        this.$refs.palette.open(hex);
      },
      setColor: function (rgb) {
        this[this.palette.style] = rgb;
      },
      /* ファイルアップロード時にプレビューに反映 */
      onFileChange: function(e) {
        this.setUploadedImage(e, (image, imagePreview, info) => {
          this.$set(this.image.file, 'url', image);
          this.$set(this.image, 'preview', imagePreview);
          this.$set(this.selectedNode, 'value', this.image.preview);
        });
      },
    },
    computed: {
      /** 表示中のノードリスト */
      htmlJp: function() {
        return this.nodeHtmls['jp'].join('');
      },
      htmlEn: function() {
        return this.nodeHtmls['en'].join('');
      },
      /** マージンクラスの数 */
      marginClassCount: function() {
        return this.classes.margin.length;
      },
      imgNodeExists: function() {
        let exists = false;
        this.nodes[this.locale].forEach((node) => {
          if (node.tag === 'img') return exists = true;
        });
        return exists;
      }
    }
  }
</script>
