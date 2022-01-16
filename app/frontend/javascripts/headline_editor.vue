<template>
  <div v-cloak>
    <section class="island">
      <button type="button" class="dialog-open mdc-button mdc-button--icon mdc-button--secondary mdc-ripple-upgraded"><i class="material-icons mdc-button__icon">photo_library</i>プロジェクトから読み込む
      </button>
      <input id="file_upload" class="dew-file-input" v-on:change="onFileChange($event)" type="file" name="headline[file]">
      <label for="file_upload" class="mdc-button mdc-button--icon mdc-button--secondary mdc-ripple-upgraded">
        <i class="material-icons mdc-button__icon">file_upload</i>新しくアップロード
      </label>
      <input type="hidden" name="headline[source]" :value="headline.source">
      <input type="hidden" name="headline[published_project_id]" :value="headline.published_project_id" v-if="headline.source === 'project'">
      <input type="hidden" name="headline[published_block_id]" :value="headline.published_block_id" v-if="headline.source === 'block'">
      <input type="hidden" name="headline[position_x]" :value="headline.position_x">
      <input type="hidden" name="headline[position_y]" :value="headline.position_y">
    </section>

    <section class="headline-edit-preview-plate">
      <div class="island island-filled">
        <div id="preview_area" class="headline-edit-preview-surface" @mousedown="selectStart" @mouseup="selectEnd" @mouseleave="selectEnd" @mousemove="setPosition" v-if="headline.source">
          <span class="headline-edit-preview-point" :style="{top: headline.position_y + '%', left: headline.position_x + '%'}"></span>
          <img :src="headline.preview">
        </div>
        <div class="headline-edit-preview-error" v-if="!headline.source">
          画像が登録されていません
        </div>
      </div>
    </section>

    <div class="mdc-dialog">
      <div class="mdc-dialog__container">
        <div class="mdc-dialog__surface">
          <h2 class="island-header mdc-dialog__title">Issued Images ({{ page }}/{{ last_page }})</h2>
          <section class="mdc-dialog__content">
            <ul class="headline-image-list">
              <li v-for="(image, idx) in images" :key="types[idx] + image.id" class="headline-image-item" :class="{ 'headline-image-item-selected': idx === selected}" @mousedown="selectImage(idx)">
                <div class="headline-image-surface">
                  <img class="headline-image" :src="image.file.thumb.url" v-if="image.file.thumb">
                </div>
              </li>
            </ul>
          </section>
          <footer class="headline-dialog-footer mdc-dialog__actions">
            <div class="headline-dialog-footer-button">
              <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-if="page > 1" @mousedown="pageMove(-1)">navigate_before</button>
            </div>
            <div>
              <button type="button" class="dialog-close mdc-button mdc-button--secondary mdc-ripple-upgraded">OK</button>
            </div>
            <div class="headline-dialog-footer-button">
              <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-if="page < last_page" @mousedown="pageMove(1)">navigate_next</button>
            </div>
          </footer>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import Vue from 'vue/dist/vue.esm'
  import axios from 'axios';
  import Uploadable from 'uploadable.js'

  export default {
    mixins: [Uploadable],
    props: ['params'],
    data: function() {
      return {
        headline: this.params.headline,
        images: this.params.images,
        types: this.params.types,
        last_page: this.params.last_page,
        page: 1,
        selected: null,
        onCursor: false
      }
    },
    methods: {
      selectStart: function(e) {
        this.onCursor = true;
        this.setPosition(e);
        e.preventDefault();
      },
      selectEnd: function() {
        this.onCursor = false;
      },
      setPosition: function(e) {
        if (this.onCursor) {
          this.$set(this.headline, 'position_x', Math.round(e.offsetX / e.target.width * 100));
          this.$set(this.headline, 'position_y', Math.round(e.offsetY / e.target.height * 100));
        }
      },
      selectImage: function(idx) {
        this.selected = idx;
        this.$set(this.headline, 'source', this.types[idx]);
        this.$set(this.headline.file, 'url', null);
        this.$set(this.headline, 'preview', this.images[idx].file.url);
        this.$set(this.headline, 'view', null);
        this.$set(this.headline, 'published_' + this.headline.source + '_id', this.images[idx].id);
      },
      pageMove: function(differ) {
        if (this.page <= 0 || this.page > this.last_page) { return; }
        let page = this.page + differ;
        axios.get('/sidedoor/headlines/api/' + page).then(res => {
          this.images = res.data.images;
          this.types = res.data.types;
          this.selected = null;
          this.page = page;
        });
      },
      /** ファイルアップロード時 */
      onFileChange: function(e) {
        this.setUploadedImage(e, (image, imagePreview, info) => {
          this.$set(this.headline, 'source', 'file');
          this.$set(this.headline, 'id', null);
          this.$set(this.headline.file, 'url', image);
          this.$set(this.headline, 'preview', imagePreview);
        });
      },
    }
  }
</script>
