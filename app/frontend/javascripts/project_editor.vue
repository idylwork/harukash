<template>
  <div>
    <div class="island island-filled" :class="{ 'island-disabled': !essentials.facade.is_visible }"  v-on:click="previewFocus('facade')">
      <h2 class="island-header island-header-control">
        <div class="mdc-form-field">
          <div class="mdc-checkbox">
            <input type="checkbox" class="mdc-checkbox__native-control" value="facade" v-model="selected">
            <div class="mdc-checkbox__background">
              <svg class="mdc-checkbox__checkmark" viewBox="0 0 24 24">
                <path class="mdc-checkbox__checkmark-path" fill="none" stroke="white" d="M1.73,12.91 8.1,19.28 22.79,4.59"></path>
              </svg>
              <div class="mdc-checkbox__mixedmark"></div>
            </div>
          </div>
          <label>Main Visual</label>
        </div>

        <div class="island-header-buttons">
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="essentials.facade.is_visible=!essentials.facade.is_visible">visibility{{ essentials.facade.is_visible ? '' : '_off'}}<p class="button-label">非表示</p></button>
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette('facade', 'color_bg', $event)">format_color_fill<p class="button-label">背景色</p></button>
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette('facade', 'color_txt', $event)">format_color_text<p class="button-label">文字色</p></button>
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette('facade', 'color_edge', $event)">texture<p class="button-label">注釈色</p></button>
        </div>
      </h2>

      <div>
        <label for="field_title" class="dew-text-label">Project Title</label>
        <input id="field_title" type="text" value="Seeds Project" name="project[title]" class="dew-text" v-model="project.title">
        <p class="tip">プロジェクトのタイトルを設定します。</p>
      </div>

      <div class="mdc-form-field" v-for="(category_name, id) in category_names" :key="category_name">
        <div class="mdc-radio mdc-ripple-upgraded mdc-ripple-upgraded--unbounded">
          <input type="radio" :value="id" name="project[category_id]" :id="'project_category_id_' + id" class="mdc-radio__native-control" v-model="project.category_id">
          <div class="mdc-radio__background">
            <div class="mdc-radio__outer-circle"></div>
            <div class="mdc-radio__inner-circle"></div>
          </div>
        </div>
        <label :for="'project_category_id_' + id">{{category_name}}</label>
      </div>

      <p class="tip">プロジェクトのカテゴリを設定します。</p>

      <div>
        <label for="field_date" class="dew-text-label">Project Date</label>
        <div class="edit-datepicker">
          <v-date-picker mode="single" :formats="{input: 'YYYY/M/D', data: 'YYYY-MM-DD', dayPopover: 'MMM D YYYY'}" v-model="project.date" is-inline v-cloak></v-date-picker>
        </div>
        <input type="hidden" id="field_date" :name="'project[date]'" v-model="project.date">

        <p class="tip">プロジェクトの日付を設定します。サイトには年と月が公開されます。</p>
      </div>

      <label for="project_file" class="dew-text-label">Project Image</label>
      <div class="edit-form-file">
        <label class="dew-file">
          <div class="dew-file-icon" :style="{ backgroundImage: 'url(' + (essentials.facade.preview || essentials.facade.file.url) + ')' }"></div>
          <div class="dew-file-text">Upload New Image</div>
          <input type="file" class="dew-file-input" name="project[file]" id="project_file" v-on:change="onFileChange('facade', $event)">
        </label>
      </div>
      <p class="dew-file-notice" v-if="essentials.facade.is_oversize"><i class="material-icons">photo_size_select_large</i> 画像サイズが大きいためアップロード後に縮小されます。</p>
      <p class="tip">メインになる画像です。横幅いっぱいに表示されます。アップロードした画像は長辺1200ピクセルに縮小されます。</p>

      <input type="hidden" :name="'project[color_txt]'" v-model="essentials.facade.color_txt">
      <input type="hidden" :name="'project[color_bg]'" v-model="essentials.facade.color_bg">
      <input type="hidden" :name="'project[color_edge]'" v-model="essentials.facade.color_edge">
      <input type="hidden" :name="'project[is_visible]'" v-model="essentials.facade.is_visible">

      <label class="dew-text-label">Project Roles</label>
      <draggable tag="ul" :list="roles" class="dew-sortable" handle=".dew-sortable-handle">
        <li v-for="(role, display_id) in roles" v-show="!role._destroy" :key="role.id">
          <span class="dew-sortable-handle"><i class="material-icons">drag_handle</i></span>
          <input type="text" :name="'project[roles_attributes][' + display_id + '][name]'" class="dew-text dew-sortable-left" v-model="role.name">
          <input type="text" :name="'project[roles_attributes][' + display_id + '][person]'" class="dew-text dew-sortable-right" v-model="role.person">
          <input type="hidden" :name="'project[roles_attributes][' + display_id + '][id]'" :value="role.id" v-if="typeof role.id !== 'undefined'">
          <input type="hidden" :name="'project[roles_attributes][' + display_id + '][display_id]'" :value="display_id">
          <input type="hidden" :name="'project[roles_attributes][' + display_id + '][_destroy]'" value="true" v-if="role._destroy">
          <button type="button" class="dew-sortable-button mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="removeRole(display_id)" v-if="roles.length > 1">clear<p class="button-label">削除</p></button>
        </li>
      </draggable>
      <div class="dew-sortable-append" v-on:click="appendRole"><i class="material-icons">expand_more</i></div>

      <p class="tip">担当パートや製作補助にあたったメンバーを設定します。<i class="material-icons">expand_more</i>で新しく役割を追加し、<i class="material-icons">remove</i>で削除します。</p>
    </div>

    <p class="tip">ここから下でテキストや画像を構成するブロックを追加・編集します。</p>

    <div class="island-divider">
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(0, 'heading')">book<p class="button-label">見出し</p></button>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(0)">add_circle<p class="button-label">文章</p></button>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(0, 'picture')">add_a_photo<p class="button-label">画像</p></button>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(0, 'link')">link<p class="button-label">リンク</p></button>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(0, 'html')" v-if="params['enableHtml']">code<p class="button-label">HTML</p></button>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(0, 'trash')" v-if="trash.length && trash[trash.length-1].type">restore_page<p class="button-label">復活</p></button>
    </div>

    <section v-for="block in removedBlocks" :key="block.id">
      <input type="hidden" :name="'project[blocks_attributes][' + block.id + '][id]'" v-model="block.id">
      <input type="hidden" :name="'project[blocks_attributes][' + block.id + '][_destroy]'" value="true">
    </section>

    <transition-group name="block" tag="div">
      <section v-for="(block, display_id) in blocks" :key="block.id">
        <div class="island island-flex" :class="{ 'island-disabled': !block.is_visible }" v-on:click="previewFocus(block.id)">
          <h2 class="island-header island-header-control">
            <div class="mdc-form-field">
              <div class="mdc-checkbox">
                <input type="checkbox" class="mdc-checkbox__native-control" v-model="selected" :value="display_id">
                <div class="mdc-checkbox__background">
                  <svg class="mdc-checkbox__checkmark" viewBox="0 0 24 24">
                    <path class="mdc-checkbox__checkmark-path" fill="none" stroke="white" d="M1.73,12.91 8.1,19.28 22.79,4.59"></path>
                  </svg>
                  <div class="mdc-checkbox__mixedmark"></div>
                </div>
              </div>
              <label for="basic-checkbox">{{ display_id + 1 }}</label>
            </div>
            <div class="island-header-buttons">
              <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="block.is_visible=!block.is_visible">visibility{{ block.is_visible ? '' : '_off'}}<p class="button-label">非表示</p></button>
              <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette(display_id, 'color_bg', $event)">format_color_fill<p class="button-label">背景色</p></button>
              <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette(display_id, 'color_txt', $event)">format_color_text<p class="button-label">文字色</p></button>
              <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="remove(display_id)">delete<p class="button-label">削除</p></button>
            </div>
          </h2>

          <div v-if="block.type === 'heading'">
            <label :for="'form_text_en_' + display_id" class="dew-text-label">Heading</label>
            <input type="text" :name="'project[blocks_attributes][' + display_id + '][text_en]'" :id="'text_en_' + block.display_id" class="dew-text" v-model="block.text_en">
          </div>

          <div v-if="block.type === 'text'">
            <label :for="'text_en_' + display_id" class="dew-text-label">English</label>
            <textarea :name="'project[blocks_attributes][' + display_id + '][text_en]'" :id="'text_en_' + display_id" class="dew-text dew-text-textarea" v-model="block.text_en"></textarea>
            <label :for="'text_jp_' + display_id" class="dew-text-label">Japanese</label>
            <textarea :name="'project[blocks_attributes][' + display_id + '][text_jp]'" :id="'text_jp_' + display_id" class="dew-text dew-text-textarea" v-model="block.text_jp"></textarea>
          </div>

          <div v-if="block.type === 'link'">
            <label :for="'form_text_en_' + display_id" class="dew-text-label">English</label>
            <input type="text" :name="'project[blocks_attributes][' + display_id + '][text_en]'" :id="'text_en_' + block.display_id" class="dew-text" v-model="block.text_en">
            <label :for="'form_text_jp_' + display_id" class="dew-text-label">Japanese</label>
            <input type="text" :name="'project[blocks_attributes][' + display_id + '][text_jp]'" :id="'text_jp_' + block.display_id" class="dew-text" v-model="block.text_jp">
            <label :for="'form_option_' + display_id" class="dew-text-label">URL</label>
            <input type="text" :name="'project[blocks_attributes][' + display_id + '][option]'" :id="'option_' + block.display_id" class="dew-text" v-model="block.option">
          </div>

          <div v-if="block.type === 'picture'">
            <div class="edit-form-file" v-if="block.type === 'picture'">
              <label class="dew-file">
                <div class="dew-file-icon" :style="{ backgroundImage: 'url(' + (block.preview || block.file.url) + ')' }"></div>
                <div class="dew-file-text">Upload New Image</div>
                <input type="file" class="dew-file-input" :name="'project[blocks_attributes][' + display_id + '][file]'" :id="'file_' + display_id" v-on:change="onFileChange(display_id, $event)">
              </label>
              <p class="dew-file-notice" v-if="block.is_oversize"><i class="material-icons">photo_size_select_large</i> 画像サイズが大きいためアップロード後に縮小されます。</p>
            </div>

            <label :for="'form_text_en_' + display_id" class="dew-text-label">English</label>
            <input type="text" :name="'project[blocks_attributes][' + display_id + '][text_en]'" :id="'text_en_' + block.display_id" class="dew-text" v-model="block.text_en">
            <label :for="'form_text_jp_' + display_id" class="dew-text-label">Japanese</label>
            <input type="text" :name="'project[blocks_attributes][' + display_id + '][text_jp]'" :id="'text_jp_' + block.display_id" class="dew-text" v-model="block.text_jp">
            <div v-if="block.text_en || block.text_jp">
              <label :for="'form_option_' + display_id" class="dew-text-label">URL</label>
              <input type="text" :name="'project[blocks_attributes][' + display_id + '][option]'" :id="'option_' + block.display_id" class="dew-text" v-model="block.option">
            </div>
          </div>

          <div v-if="block.type === 'html'">
            <label :for="'text_en_' + display_id" class="dew-text-label">Html</label>
            <textarea :name="'project[blocks_attributes][' + display_id + '][text_en]'" :id="'text_en_' + display_id" class="dew-text dew-text-textarea" v-model="block.text_en"></textarea>
          </div>

          <input type="hidden" :name="'project[blocks_attributes][' + display_id + '][id]'" :value="block.id" v-if="typeof block.id === 'number'">
          <input type="hidden" :name="'project[blocks_attributes][' + display_id + '][display_id]'" :value="display_id">
          <input type="hidden" :name="'project[blocks_attributes][' + display_id + '][color_txt]'" :value="block.color_txt">
          <input type="hidden" :name="'project[blocks_attributes][' + display_id + '][color_bg]'" :value="block.color_bg">
          <input type="hidden" :name="'project[blocks_attributes][' + display_id + '][option]'" :value="block.option">
          <input type="hidden" :name="'project[blocks_attributes][' + display_id + '][type]'" :value="block.type">
          <input type="hidden" :name="'project[blocks_attributes][' + display_id + '][is_visible]'" :value="block.is_visible">
        </div>

        <div class="island-divider">
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(display_id+1, 'heading')">book<p class="button-label">見出し</p></button>
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(display_id+1, 'text')">add_circle<p class="button-label">文章</p></button>
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(display_id+1, 'picture')">add_a_photo<p class="button-label">画像</p></button>
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(display_id+1, 'link')">link<p class="button-label">リンク</p></button>
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(display_id+1, 'html')" v-if="params['enableHtml']">code<p class="button-label">HTML</p></button>
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="append(display_id+1, 'trash')" v-if="trash.length">restore_page<p class="button-label">復活</p></button>
          <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-if="blocks[display_id+1]" v-on:click="move(display_id, display_id+1)">swap_vert<p class="button-label">入れ替え</p></button>
        </div>
      </section>
    </transition-group>

    <section id="project_preview_plate" class="project-preview-plate" :class="{'locale-ja': preview_locale === 'jp'}">
      <div class="preview-plate-settings">
        <div class="mdc-form-field">
          <div class="mdc-radio mdc-ripple-upgraded mdc-ripple-upgraded--unbounded">
            <input class="mdc-radio__native-control" type="radio" id="preview_locale" checked="" name="radio" value="en" v-model="preview_locale">
            <div class="mdc-radio__background">
              <div class="mdc-radio__outer-circle"></div>
              <div class="mdc-radio__inner-circle"></div>
            </div>
          </div>
          <label for="preview_locale">English</label>
        </div>
        <div class="mdc-form-field">
          <div class="mdc-radio mdc-ripple-upgraded mdc-ripple-upgraded--unbounded">
            <input class="mdc-radio__native-control" type="radio" id="preview_locale_jp" name="radio" value="jp" v-model="preview_locale">
            <div class="mdc-radio__background">
              <div class="mdc-radio__outer-circle"></div>
              <div class="mdc-radio__inner-circle"></div>
            </div>
          </div>
          <label for="preview_locale_jp">Japanese</label>
        </div>
      </div>

      <div class="facade-preview" id="preview_block_facade" :style="{ color: essentials.facade.color_txt, background: essentials.facade.color_bg }">
        <h1>{{ project.title }}</h1>

        <ul class="facade-roles-list">
          <li class="facade-roles-item" v-for="role in extantRoles" :key="role.id">{{ role.name }}: {{ role.person }}</li>
          <li class="facade-roles-item">{{ date_preview }}</li>
        </ul>

        <div class="stone-picture" v-if="essentials.facade.is_visible" >
          <p v-if="!essentials.facade.file">No Image</p>
          <img class="stone-image-facade" :class="{ 'stone-image-facade-portrait': essentials.facade.is_portrait }" :src="essentials.facade.preview || essentials.facade.file.url">
        </div>
      </div>

      <draggable tag="div">
        <transition-group name="stone-preview" tag="div" class="stone-list-preview">
          <div v-for="block in visibleBlocks" :key="block.id" class="stone" :id="'preview_block_' + block.id" :class="stoneClass(block.type, block.color_bg)" :style="{ color: block.color_txt, backgroundColor: block.color_bg }">
            <h2 v-if="block.type === 'heading'"><div>{{ block.text_en }}</div></h2>
            <p v-else-if="block.type === 'text'">{{ previewText(block) }}</p>
            <div v-else-if="block.type === 'link'">
              <div class="fountain-link">
                <a href="javascript: return false;">{{ previewText(block) }}
                  <div class="fountain-link-line" :style="{ '--line-color': block.color_txt }"></div>
                </a>
              </div>
            </div>
            <div v-else-if="block.type === 'html'" v-html="block.text_en"></div>
            <div v-else-if="block.type === 'picture'">
              <p v-if="!block.file">No Image</p>
              <div class="stone-image-portrait" v-if="block.is_portrait">
                <div class="stone-image-surface" :style="{ backgroundImage: 'url(' + (block.preview || block.file.url) + ')' }"></div>
              </div>
              <div class="stone-image-horizontal" v-else>
                <img class="stone-image" :src="block.preview || block.file.url">
              </div>
              <div class="stone-image-caption" v-if="block.text_en || block.text_jp">
                <div class="fountain-link" v-if="block.option">
                  <a href="javascript: return false;">{{ previewText(block) }}
                    <div class="fountain-link-line" :style="{ '--line-color': block.color_txt }"></div>
                  </a>
                </div>
                <span class="stone-image-caption-text" v-else>{{ previewText(block) }}</span>
              </div>
            </div>
          </div>
        </transition-group>
      </draggable>
    </section>

    <section class="info-plate" v-if="selected.length">
      <p>{{ selected.length }}件選択中</p>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="toggleVisible">visibility_off<div class="button-label">非表示</div></button>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette(selected, 'color_bg', $event)">format_color_fill<div class="button-label">背景色</div></button>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="openPalette(selected, 'color_txt', $event)">format_color_text<div class="button-label">文字色</div></button>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="removeSelected()">delete<div class="button-label">削除</div></button>
      <button type="button" class="mdc-icon-button mdc-icon-button--colored material-icons" v-on:click="selected = []">clear<div class="button-label">キャンセル</div></button>
    </section>

    <palette ref="palette" v-on:change-color="setColor" :palette="palette"></palette>
  </div>
</template>

<script>
  import Vue from 'vue/dist/vue.esm'
  import draggable from 'vuedraggable';
  import VCalendar from 'v-calendar';
  import 'v-calendar/lib/v-calendar.min.css';
  import moment from 'moment';
  import palette from 'palette.vue'
  import Uploadable from 'uploadable.js'

  Vue.use(VCalendar, {
    locale: 'en-GB',
    firstDayOfWeek: 1,
    datePickerShowDayPopover: false,
    themeStyles: {
      wrapper: {
        background: null,
        color: null
      },
      dayCellNotInMonth: {
        color: '#dddcdd'
      },
      dayPopoverContent: {
        color: '#333333',
        fontSize: '0.8rem',
        whiteSpace: 'nowrap'
      }
    }
  });

  /** プロジェクトの編集 */
  export default {
    components: { draggable, palette },
    mixins: [Uploadable],
    props: ['params'],
    data: function() {
      return {
        prefix: 'new_',
        preview_locale: 'en',
        project: {
          title: this.params.title,
          category_id: this.params.category_id,
          date: new Date(this.params.date),
        },
        roles: this.params.roles,
        blocks: this.params.blocks,
        essentials: {
          facade: {
            color_txt: this.params.color_txt,
            color_bg: this.params.color_bg,
            color_edge: this.params.color_edge,
            is_visible: this.params.is_visible,
            file: this.params.file,
            is_portrait: false,
            is_oversize: false
          }
        },
        trash: this.params.trash,
        selected: [],
        id: this.params.block_new_id,
        palette: { display_id: 0, style: '', x: 0, el: null},
        category_names: this.params.categoryNames,
        focus: {
          duration: 500,
          headerHeight: 40,
          plate: null,
          lastBlockId: null
        }
      }
    },
    mounted: function() {
      this.focus.plate = document.getElementById('project_preview_plate');
    },
    methods: {
      previewText: function(block) {
        if (this.preview_locale === 'en' || !block.text_jp) {
          return block.text_en;
        } else {
          return block.text_jp || block.text_en;
        }
      },
      getBlockDefault: function(id = 0, type = 'text') {
        return {
          type: type,
          text_jp: '',
          text_en: '',
          color_txt: '#000000',
          color_bg: 'transparent',
          is_visible: true,
          id: 'new_' + id,
          file: { url: null },
          is_portrait: false,
          is_oversize: false
        }
      },
      append: function(display_id, type) {
        if (type === 'trash') {
          this.blocks.splice(display_id, 0, this.trash.splice(this.trash.length-1, 1)[0]);

        } else {
          this.blocks.splice(display_id, 0, this.getBlockDefault(this.id++, type));
        }
        this.selected.forEach((selectedId, key) => {
          if (selectedId >= display_id) this.selected[key]++;
        });
      },
      remove: function(display_id) {
        var deleted = this.blocks.splice(display_id, 1);
        this.trash.push(deleted[0]);
        this.selected.forEach((selectedId, key) => {
          if (selectedId === display_id) this.selected.splice(key, 1);
          if (selectedId > display_id) this.selected[key]--;
        });
      },
      removeSelected: function() {
        while (this.selected.length) {
          this.selected.shift();
          this.remove(this.selected[0]);
        }
      },
      move: function(display_id1, display_id2) {
        let scroll = document.documentElement.scrollTop || document.body.scrollTop;
        let block1 = this.blocks[display_id1];
        this.blocks.splice(display_id1, 1, this.blocks[display_id2]);
        this.blocks.splice(display_id2, 1, block1);
        let key1 = this.selected.indexOf(display_id1);
        let key2 = this.selected.indexOf(display_id2);

        let changeKey = { display_id1: null, display_id2: null };
        for (let i = 0; i < this.selected.length; i++) {
          if (this.selected[i] === display_id1) {
            changeKey.display_id1 = i;
          } else if (this.selected[i] === display_id2) {
            changeKey.display_id2 = i;
          }
        }

        if (changeKey.display_id1 !== null && changeKey.display_id2 === null) {
          this.selected[changeKey.display_id1]++;
        } else if (changeKey.display_id1 === null && changeKey.display_id2 !== null) {
          this.selected[changeKey.display_id2]--;
        }

        // 入れ替えの強制追従スクロール対策 (Chrome)
        this.$nextTick(() => {
          scrollTo(0, scroll);
        });
      },
      toggleVisible: function() {
        let isChange = false;

        for (let i = 0; i < this.selected.length; i++) {
          if (typeof this.selected[i] === 'number') {
            if (this.blocks[this.selected[i]].is_visible) {
              isChange = true;
              this.blocks[this.selected[i]].is_visible =   false;
            }
          } else if (this.essentials[this.selected[i]].is_visible) {
            isChange = true;
            this.essentials[this.selected[i]].is_visible = false;
          }
        }

        if (!isChange) {
          for (let i = 0; i < this.selected.length; i++) {
            if (typeof this.selected[i] === 'number') {
              this.blocks[this.selected[i]].is_visible = true;
            } else {
              this.essentials[this.selected[i]].is_visible = true;
            }
          }
        }
      },
      appendRole: function() {
        this.roles.push({ name: '', person: '' });
      },
      removeRole: function(display_id) {
        if (typeof this.roles[display_id].id === 'number') {
          Vue.set(this.roles[display_id], '_destroy', true);
        } else {
          this.roles.splice(display_id, 1);
        }
      },
      /** プレビューブロックのクラス名 */
      stoneClass: function(type, color_bg) {
        let classList = {};
        classList['stone-' + type] = true;
        if (color_bg !== 'transparent') classList['stone-colored'] = true;
        return classList;
      },
      openPalette: function(display_id, style, event) {
        this.palette.el = event.currentTarget;
        this.palette.display_id = display_id;
        this.palette.style = style;

        let hex;
        if (display_id instanceof Object) {
          // 複数選択
          this.palette.el = null;
          hex = 'transparent';
        } else if (typeof display_id === 'number') {
          // ブロック
          hex = this.blocks[display_id][style].replace('#', '');
        } else {
          // ファサード
          hex = this.essentials[display_id][style].replace('#', '');
        }
        this.$refs.palette.open(hex);
      },
      setColor: function (rgb) {
        if (this.palette.display_id instanceof Object) {
          this.palette.display_id.forEach((display_id) => {
            if (typeof display_id === 'number') {
              this.blocks[display_id][this.palette['style']] = rgb;
            } else {
              this.essentials[display_id][this.palette['style']] = rgb;
            }
          });
        } else if (typeof this.palette.display_id === 'number') {
          this.blocks[this.palette.display_id][this.palette['style']] = rgb;
        } else {
          this.essentials[this.palette.display_id][this.palette['style']] = rgb;
        }
      },
      /* ファイルアップロード時にプレビューに反映 */
      onFileChange: function(display_id, e) {
        this.setUploadedImage(e, (image, imagePreview, info) => {
          if (display_id === 'facade') {
            this.$set(this.essentials.facade.file, 'url', image);
            this.$set(this.essentials.facade, 'preview', imagePreview);
            this.$set(this.essentials.facade, 'is_portrait', info.isPortrait);
            this.$set(this.essentials.facade, 'is_oversize', info.isOversize);
          } else {
            this.$set(this.blocks[display_id].file, 'url', image);
            this.$set(this.blocks[display_id], 'preview', imagePreview);
            this.$set(this.blocks[display_id], 'is_portrait', info.isPortrait);
            this.$set(this.blocks[display_id], 'is_oversize', info.isOversize);
          }
        });
      },
      /* 編集パネルに合わせてプレビューをスクロール */
      previewFocus: function(blockId) {
        if (blockId === this.focus.lastBlockId) return;
        this.focus.lastBlockId = blockId;

        let block = document.getElementById('preview_block_' + blockId);
        if (block) {
          /* スムーススクロール */
          let startTime = Date.now();
          let scrollFrom = this.focus.plate.scrollTop;
          let targetPos = block.offsetTop - this.focus.headerHeight;
          let gap = targetPos - scrollFrom;
          let vm = this;

          (function loop() {
            let currentTime = Date.now() - startTime;

            if(currentTime < vm.focus.duration) {
              vm.focus.plate.scrollTop = vm.easing(currentTime, scrollFrom, gap, vm.focus.duration);
              window.requestAnimationFrame(loop);
            } else {
              vm.focus.plate.scrollTop = targetPos;
            }
          })();
        }
      },
      easing: function (t, b, c, d) {
        return c * (0.5 - Math.cos(t / d * Math.PI) / 2) + b;
      }
    },
    computed: {
      date_preview: function() {
        return moment(this.project.date).format('MMMM YYYY');
      },
      visibleBlocks: function() {
        let blocks = [];
        this.blocks.forEach((block) => {
          if (block.is_visible) blocks.push(block);
        });
        return blocks;
      },
      removedBlocks: function() {
        let blocks = [];
        this.trash.forEach((block) => {
          if (typeof block.id === 'number') blocks.push(block);
        });
        return blocks;
      },
      extantRoles: function() {
        let roles = [];
        this.roles.forEach((role) => {
          if (!role._destroy) roles.push(role);
        });
        return roles;
      },
    },
  }
</script>