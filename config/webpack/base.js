const { webpackConfig, merge } = require("@rails/webpacker");

const options = {
  resolve: {
    extensions: [".css", ".ts", ".tsx"],
  },
};

module.exports = merge(webpackConfig, options);
