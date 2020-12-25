module.exports = {
  test: /\.coffee(\.erb)?$/,
  use: [{
    loader: 'coffee-loader',
    options: {
      bare: false,
      transpile: {
        presets: ['@babel/preset-env'],
      },
    }
  }]
}
