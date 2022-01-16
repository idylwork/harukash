/**
 * 管理画面 Vue初期化
 */
import Vue from 'vue/dist/vue.esm'
import InputColor from 'input_color'
import CategoryList from 'category_list'
import ProjectList from 'project_list'
import ProjectEditor from 'project_editor'
import HeadlineList from 'headline_list'
import HeadlineEditor from 'headline_editor'
import StickyEditor from 'sticky_editor'
import Datepicker from 'datepicker'

document.addEventListener('DOMContentLoaded', () => {
  vueInit('project_list', ProjectList);
  vueInit('category_list', CategoryList);
  vueInit('headline_list', HeadlineList);
  vueInit('headline_editor', HeadlineEditor, function (params) { if (params.file) params.headline.preview = params.file.url; });
  vueInit('sticky_editor', StickyEditor);
  vueInit('datepicker', Datepicker);

  const projectEditor = document.getElementById('project_editor');
  window.pe = projectEditor;
  if (projectEditor) {
    let params = JSON.parse(projectEditor.dataset.project);
    params.roles = JSON.parse(projectEditor.dataset.roles);
    params.blocks = JSON.parse(projectEditor.dataset.blocks);
    params.categoryNames = JSON.parse(projectEditor.dataset.categoryNames);
    params.block_new_id = 1;
    params.trash = [];
    params.enableHtml = !!projectEditor.dataset.enableHtml;
    if (projectEditor.dataset.cache) {
      // エラー時はブロックIDと削除済みブロックの情報を初期化する
      const cache = JSON.parse(projectEditor.dataset.cache);
      if (cache.block_new_id) {
        params.block_new_id += parseInt(cache.block_new_id, 10);
      }
      if (cache.trash) {
        params.trash = cache.trash;
      }
    }

    new Vue({
      el: projectEditor,
      render: h => h(ProjectEditor, {
        props: { params }
      }),
    });
  }

  const inputColor = document.getElementById('input_color');
  if (inputColor) {
    new Vue({
      el: inputColor,
      render: h => h(InputColor, {props: {
        name: inputColor.name,
        value: inputColor.value
      }}),
    });
  }

  /** Vueを初期化する */
  function vueInit(elId, VueObject, filter = null) {
    const el = document.getElementById(elId);
    if (el) {
      const json = el.dataset.json;
      let params = [];
      if (json) {
        params = JSON.parse(json);
        if (filter) { filter(params); }
      }

      new Vue({
        el: el,
        render: h => h(VueObject, {
          props: { params: params }
        }),
      });
    }
  }
}); // DOMContentLoaded
