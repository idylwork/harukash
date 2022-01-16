"use strict";

import moment from "moment";
import "./application.js";

window.addEventListener("DOMContentLoaded", function() {
  /* Noticeを削除 (BFCache対策) */
  const notice = document.getElementById("notice");
  if (notice) {
    notice.addEventListener("animationend", function(e) {
      e.target.remove();
    });
  }

  /** ローカルナビゲーション */
  const indexMenu = document.getElementById("index_menu");
  if (indexMenu) {
    const indexNav = document.getElementById("index_nav");
    let hideTimer = null;
    clearTimeout(hideTimer);
    // Open
    document
      .getElementById("index_menu_open")
      .addEventListener("mousedown", () => {
        indexMenu.classList.remove("index-menu-closing");
        indexMenu.classList.add("index-menu-opened");
        indexNav.classList.remove("index-nav-active");
      });
    // Close
    indexMenu.addEventListener("mousedown", () => {
      indexMenu.classList.remove("index-menu-opened");
      indexNav.classList.add("index-nav-active");
      indexMenu.classList.add("index-menu-closing");
      hideTimer = setTimeout(() => {
        indexMenu.classList.remove("index-menu-closing");
      }, 1000);
    });

    // スクロール位置でボタンを表示
    function displayMenuSwitch() {
      if (window.scrollY > 0) {
        indexNav.classList.add("index-nav-active");
      } else {
        indexNav.classList.remove("index-nav-active");
      }
    }
    displayMenuSwitch();
    window.addEventListener("scroll", displayMenuSwitch);
  }

  /** 遅延表示 */
  const blocks = document.getElementsByClassName("haze");
  function haze() {
    for (var i = 0; i < blocks.length; i++) {
      var margin = 70;
      var el = blocks[i];
      var pos = 0;
      if (el.dataset.hazeMargin != null) {
        margin = parseInt(el.dataset.hazeMargin);
        pos =
          document.getElementById(el.dataset.hazeParent).getBoundingClientRect()
            .top + margin;
      } else {
        pos = el.getBoundingClientRect().top + margin;
      }
      if (window.innerHeight > pos) {
        var delay = el.dataset.hazeDelay ? el.dataset.hazeDelay : 0;
        setTimeout(
          function(index) {
            blocks[index].classList.add("show");
          }.bind(null, i),
          delay
        );
      }
    }
  }
  window.addEventListener("load", haze);
  window.addEventListener("scroll", haze);

  Array.prototype.forEach.call(
    document.getElementsByClassName("haze-image"),
    function(el) {
      function addClass() {
        el.classList.add("show");
      }

      let image = new Image();
      if (el.src) {
        image.src = el.src;
        el.src = "";
        image.addEventListener("load", addClass);
        el.src = image.src;
      } else {
        image.src = el.style.backgroundImage.slice(5, -2);
        image.addEventListener("load", addClass);
      }
    }
  );

  /** テキストフィールドの高さを拡張 */
  const field = document.getElementById("contact_textarea");
  if (field) {
    const maxHeight = "400";
    function expandTextarea() {
      if (
        field.scrollHeight > field.offsetHeight &&
        field.offsetHeight < maxHeight
      ) {
        field.style.height = field.scrollHeight + "px";
      }
    }
    field.addEventListener("input", expandTextarea);
  }

  /** コンタクトフォームのバリデーション */
  const contactForm = document.getElementById("contact_form");
  if (contactForm) {
    const letterFront = document.getElementsByClassName(
      "contact-letter-front"
    )[0];
    const letterBack = document.getElementsByClassName(
      "contact-letter-back"
    )[0];
    const contactErrorsEl = document.getElementById("contact_errors");
    const contactLetter = document.getElementById("contact_letter");
    const contactConfirm = document.getElementById("contact_confirm");
    const contactSubmit = document.getElementById("contact_submit");
    const contactBack = document.getElementById("contact_back");
    const locale = document.getElementById("contact_errors").dataset.locale;
    const rules = {
      name: {
        presence: {
          ja: "名前を入力してください",
          en: "enter your name",
        },
        length: {
          maximum: 30,
          ja: "名前が長すぎます",
          en: "your name is too long",
        },
      },
      email: {
        presence: {
          ja: "Eメールアドレスを入力してください",
          en: "enter your email address",
        },
        length: {
          maximum: 300,
          ja: "Eメールアドレスが長すぎます",
          en: "your email address is too long",
        },
        format: {
          with: /^[a-zA-Z][a-zA-Z\d\-\.]+@[a-zA-Z\d\-\.]+\.[a-z]+$/,
          ja: "Eメールアドレスが正しくありません",
          en: "enter a valid email address",
        },
      },
      body: {
        presence: {
          ja: "メッセージを入力してください",
          en: "enter your message",
        },
        length: {
          maximum: 10000,
          ja: "メッセージが長すぎます",
          en: "your message is too long",
          format: {
            with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
            message: "enter a valid email address",
          },
        },
      },
    };
    let isValidated = false;
    const accessedAt = moment();

    contactConfirm.addEventListener("mousedown", function(e) {
      let errors = [];
      let isIncludesUrl = false;

      Object.keys(rules).forEach(function(name) {
        let target = contactForm["contact[" + name + "]"];

        if (rules[name].presence && !target.value.length) {
          errors.push(rules[name].presence[locale]);
        } else {
          if (name === "body" && /https?:\/\//.test(target.value)) {
            isIncludesUrl = true;
          }

          if (
            rules[name].length &&
            target.value.length > rules[name].length.maximum
          ) {
            errors.push(rules[name].length[locale]);
          }
          if (
            rules[name].format &&
            !rules[name].format.with.test(target.value)
          ) {
            errors.push(rules[name].format[locale]);
          }
        }
      });

      const interval = Math.floor(-accessedAt.diff() / 1000);
      const remainingInterval = (isIncludesUrl ? 60 : 10) - interval;

      if (remainingInterval > 0) {
        errors.push(remainingInterval + "秒お待ちください");
      }

      // エラーメッセージ表示更新
      let li;
      contactErrorsEl.textContent = null;
      errors.forEach(function(error) {
        li = document.createElement("li");
        li.textContent = error;
        contactErrorsEl.appendChild(li);
      });

      letterBack.style.height = letterFront.offsetHeight;
      contactLetter.classList.add("flipped");
      if (errors.length) {
        contactLetter.classList.add("is-error");
      } else {
        contactLetter.classList.remove("is-error");

        // Spam対策解除
        if (!isValidated) {
          let input = document.createElement("input");
          input.type = "hidden";
          input.name = "is_validated";
          input.value = "true";
          contactForm.appendChild(input);
          isValidated = true;
        }
      }
    });

    contactSubmit.addEventListener("mousedown", function(e) {
      contactForm.submit();
    });
    contactBack.addEventListener("mousedown", function(e) {
      contactLetter.classList.remove("flipped");
      expandTextarea();
    });
  }
}); /* DOMContentLoaded */
