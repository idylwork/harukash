/** Module: クラスにイベントを追加 */
function addClassNameEvent(className, eventName, callback) {
  let el = document.getElementsByClassName(className);
  Array.prototype.forEach.call(el, function(node) {
    node.addEventListener(eventName, callback);
  });
}

document.addEventListener("DOMContentLoaded", () => {
  let clickEvents = {
    submit: function() {
      let form = document.getElementById('form_edit');
      form.submit();
    },
    issue: function() {
      let form = document.getElementById('form_edit');
      let input = document.createElement('input');
      input.name = "button";
      input.type = "hidden";
      input.value = "issue";
      form.appendChild(input);
      form.submit();
    },
  };

  const metaKey = (navigator.userAgent.match(/Mac|PPC/))?
        'metaKey' : 'ctrlKey';
  window.addEventListener('keydown', function(e) {
    if(e[metaKey]) {
      if(e.key === 's' && document.getElementById('form_edit')) {
        clickEvents['submit']();
        e.preventDefault();
        e.stopPropagation();
      }
    }
  });

  addClassNameEvent('click-event', 'click', function(e) {
    clickEvents[e.target.dataset.event]();
  })

  addClassNameEvent('toggle-tip', 'click', function() {
    let show = document.body.classList.toggle('show-tip');
    let url = '/sidedoor/help/' + (show ? 'show' : 'hide')
    let xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.send();
    window.noticeMessage(show ? 'ヘルプを表示しました' : 'ヘルプを非表示にしました');
  })
});
