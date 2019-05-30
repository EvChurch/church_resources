// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import '../stylesheets/application';
import './vendor/bootstrap';
import videojs from 'video.js';
import 'videojs-youtube';

require('@rails/ujs').start();
require('turbolinks').start();
require('@rails/activestorage').start();
require('channels');

$(document).on('turbolinks:load', () => {
  const players = $('.video-js');
  players.each((_index, player) => {
    videojs(player);
    $(player).on('play', () => {
      players.each((_index, player_to_compare) => {
        if (player_to_compare !== player) {
          player_to_compare.pause();
        }
      });
    });
  });
});

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
