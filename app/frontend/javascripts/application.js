// ヘッドライン表示
window.addEventListener('DOMContentLoaded', function() {
  const el = document.getElementById('album');
  if (!el) return;
  const album = JSON.parse(el.dataset.album);
  const interval = el.dataset.interval || 10000;
  if (album == null || album.length <= 0) return;

  let images = [new Image()];
  let pages = [];
  let currentPage = 0;

  // 1枚目の写真を読み込む
  loadImage(0);
  images[0].addEventListener('load', function() {
    el.appendChild(pages[0]);
    pages[0].classList.add('show');
    setInterval(pageForward, interval);
    window.addEventListener('load', function() {
      albumLoadChain(1);
    });
  });

  /** ページ送り */
  function pageForward() {
    pages[currentPage].classList.remove('show');
    currentPage++;
    if (currentPage >= album.length || !images[currentPage].complete) { currentPage = 0; }
    pages[currentPage].classList.add('show');
  }

  /**
   * 画像の読み込み開始と次の画像読み込みの予約
   * @param Integer no ロードを開始する配列のキー
   */
  function albumLoadChain(no) {
    el.appendChild(pages[no-1]);
    loadImage(no);

    if (typeof album[no + 1] !== 'undefined') {
      images[no].addEventListener('load', function() {
        albumLoadChain(no + 1);
      });
    } else {
      images[no].addEventListener('load', function() {
        el.appendChild(pages[no]);
      });
    }
  }

  /** 画像のロード */
  function loadImage(no) {
    images[no] = new Image();
    images[no].src = album[no].url;
    pages[no] = document.createElement('div');
    pages[no].style.backgroundImage = 'url(' + images[no].src + ')';
    pages[no].style.backgroundPosition = album[no].x + '% ' + album[no].y + '%';
  }
});
