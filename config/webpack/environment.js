const { environment } = require('@rails/webpacker')
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const path = require('path')
const vue =  require('./loaders/vue')
const webpack = require('webpack')

/* Vueを追加 */
environment.loaders.append('vue', vue)
environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin())

// SASS-Loader
/* node_modulesでsass-loaderを使用 */
const sassLoaderConfig = environment.loaders.get('sass').use.find(item => item.loader === 'sass-loader')
Object.assign(sassLoaderConfig.options, {
  additionalData: "@import 'application.scss';",
  sassOptions: {
    includePaths: [
      "node_modules",
      path.resolve(__dirname, "../../app/frontend/stylesheets/"),
    ],
  },
});

// CommonsChunk
/*
environment.plugins.append(
  'CommonsChunkVendor',
  new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor',
    minChunks: (module) => {
      // this assumes your vendor imports exist in the node_modules directory
      return module.context && module.context.indexOf('node_modules') !== -1
    }
  })
)
*/

/*
// sass-loaderの設定を取得
const sassLoaders = environment.loaders.get('sass')
const sassLoaderConfig = sassLoaders.use.filter(config => config.loader === 'sass-loader')[0]
// sass-loaderにパス設定
Object.assign(sassLoaderConfig.options, {
  options: {
    includePaths: glob.sync('node_modules').map((d) => path.join(__dirname, d))
  }
})
*/

/** Sourcemap無効化設定 ここから */
/*
const webpack = require('webpack');
const environment = require('./environment').toWebpackConfig();

// UglifyJsPlugin のインスタンスを見つけて置き換える
environment.plugins = environment.plugins
  .map(plug => {
  if (plug instanceof webpack.optimize.UglifyJsPlugin) {
    return new webpack.optimize.UglifyJsPlugin({
      sourceMap: false,
      parallel: true,
      mangle: false,
      uglifyOptions: {
        mangle: false
      },
      compress: {
        warnings: false
      },
      output: {
        comments: false
      }
    });
  }
  return plug;
})
environment.devtool = 'eval';
/** SourceMap無効化 ここまで */

//environment.loaders.prepend('vue', vue)
module.exports = environment;
