//import 'material-components-web/dist/material-components-web.js';

import {MDCRipple} from '@material/ripple';
import {MDCSwitch} from '@material/switch';
import {MDCRadio} from '@material/radio';
import {MDCSnackbar} from '@material/snackbar';
import {MDCDialog} from '@material/dialog';
import {MDCSlider} from '@material/slider';
//import {MDCTabBar} from '@material/tab-bar';

document.addEventListener("DOMContentLoaded", () => {
  // Ripple
  document.querySelectorAll('.mdc-button').forEach((el) => {
    let ripple = new MDCRipple(el);
  });

  // Switch
  let switches = [];
  document.querySelectorAll('.mdc-switch').forEach((el, key) => { switches[key] = new MDCSwitch(el); });

  // Radio
  document.querySelectorAll('.mdc-radio').forEach((el) => { new MDCRadio(el) });

  // Snackbar - Flash Message From Rails
  const snackbar = new MDCSnackbar(document.querySelector('.mdc-snackbar'));
  const notice = document.getElementById('notice');
  if (notice) {
    const noticeText = document.getElementById('notice_text');
    if (noticeText.innerHTML) {
      snackbar.show({
        message: noticeText.innerHTML,
        timeout: 3200,
        actionText: 'OK',
        actionHandler: function() {}
      });
    }
  }

  // Snackbar - Grobal Function
  window.noticeMessage = function(message, timeout = 1800) {
    snackbar.show({
      message,
      timeout,
      actionText: 'OK',
    });
  }


  // Dialog
  const elDialog = document.querySelector('.mdc-dialog');
  if (elDialog) {
    const dialog = new MDCDialog(elDialog);
    const dialogOpen = document.getElementsByClassName('dialog-open');
    if (dialog && dialogOpen) {
      Array.prototype.forEach.call(dialogOpen, function(node) {
        node.addEventListener('mousedown', (e) => {
          elDialog.id = e.target.dataset.dialog || e.target.parentElement.dataset.dialog;
          dialog.show();
        });
      });
      dialog.root_.addEventListener('mousedown', (e) => {
        if (e.target === dialog.root_) {
          dialog.close();
        }
      });

      const dialogClose = document.getElementsByClassName('dialog-close');
      if (dialogClose) {
        Array.prototype.forEach.call(dialogClose, function(node) {
          node.addEventListener('mousedown', () => { dialog.close(); });
        });
      }
    }
  }

  // Slider
  document.querySelectorAll('.mdc-slider').forEach((el) => {
    let slider = new MDCSlider(el);
    let input = slider.root_.getElementsByClassName('mdc-slider__input')[0];

    window.slider = slider
    slider.value = input.value;
    slider.listen('MDCSlider:change', () => {
      input.value = slider.value;
    });
    setTimeout(function() {
      slider.layout();
    }, 500);
  });

  //const tabBar = new MDCTabBar(document.querySelector('.mdc-tab-bar'));
}); /* DOMContentLoaded */

//MDC Chips
//import {MDCChipSet} from '@material/chips';
//new MDCChipSet(document.querySelector('.mdc-chip-set'));

//MDC TextField
//import {MDCTextField} from '@material/textfield';
//new MDCTextField(document.querySelector('.mdc-text-field'));
//document.querySelectorAll('.mdc-text-field').forEach((el) => { console.log(el);new MDCTextField(el) });
