const path = require('path')
const { environment } = require('@rails/webpacker')

environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

environment.config.merge({
  resolve: {
    alias: {
      retrospring: path.resolve(__dirname, '..', '..', 'app/javascript/retrospring'),
      utilities: path.resolve(__dirname, '..', '..', 'app/javascript/retrospring/utilities')
    }
  }
});

module.exports = environment
