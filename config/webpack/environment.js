const { environment } = require('@rails/webpacker');
const webpack = require('webpack');

environment.config.set('resolve.alias', {
  videojs: 'video.js'
});

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    videojs: 'video.js/dist/video.cjs.js',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default'],
  })
);

module.exports = environment;
