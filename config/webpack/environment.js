const path = require('path')
const { environment } = require('@rails/webpacker')

environment.config.merge({
  resolve: {
    alias: {
      retrospring: path.resolve(__dirname, '..', '..', 'app/javascript/retrospring'),
      utilities: path.resolve(__dirname, '..', '..', 'app/javascript/retrospring/utilities')
    }
  }
})

module.exports = environment
