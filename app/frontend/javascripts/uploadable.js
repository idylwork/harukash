import Exif from 'exif-js/exif.js';
export default  {
  methods: {
    /* アップロードされた画像からプレビュー画像を作成 */
    setUploadedImage: function (e, setFunction, width = 500) {
      /* Exif情報に基づいて回転角度を返す */
      function exifOrientation(imageBase64) {
        imageBase64 = imageBase64.replace(/^data\:([^\;]+)\;base64,/gmi, '');
        const binaryString = atob(imageBase64);
        const len = binaryString.length;
        let bytes = new Uint8Array(len);
        for (let i = 0; i < len; i++) {
          bytes[i] = binaryString.charCodeAt(i);
        }
        let exif = Exif.readFromBinaryFile(bytes.buffer);
        if (exif && exif.Orientation) {
          switch (exif.Orientation) {
            case 3: return 180;
            case 6: return 90;
            case 8: return -90;
            default: return 0;
          }
        }
      }

      let files = e.target.files || e.dataTransfer.files;
      if (!files.length) {
        return;
      }
      let file = files[0];
      let image = new Image();
      let reader = new FileReader();

      reader.onload = (e) => {
        // アップロードまでのプレビュー用の縮小画像を作成
        let imageBase64 = e.target.result;
        let imageType = imageBase64.substring(5, imageBase64.indexOf(";"));
        let rotate = exifOrientation(imageBase64);

        image.onload = function() {
          // 縦横比を保存してプレビュー用に縮小
          let ratio = image.width / image.height;
          let height = width / ratio;
          let canvas = document.createElement('canvas');
          canvas.width = width;
          canvas.height = height;

          // Exif情報に基づいて回転
          if (rotate === 90 || rotate === 270) {
            canvas.width = height;
            canvas.height = width;
          }
          let context = canvas.getContext('2d');
          if (0 < rotate && rotate < 360) {
            context.rotate(rotate * Math.PI / 180);
            if (rotate === 90) context.translate(0, -height);
            else if (rotate === 180) context.translate(-width, -height);
            else if (rotate === 270) context.translate(-width, 0);
          }
          context.drawImage(image, 0, 0, width, height);
          let imagePreview = canvas.toDataURL(imageType);
          let info = {
            isPortrait: canvas.height > canvas.width, 
            isOversize: canvas.width > 1200 || canvas.height > 1200
          }
          canvas = null;

          // 結果のコールバックを実行
          setFunction(imageBase64, imagePreview, info);
        };

        image.src = imageBase64;
      };
      reader.readAsDataURL(file);
    },
  }
}
