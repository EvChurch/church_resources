// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import "core-js/stable";
import "regenerator-runtime/runtime";
import "../stylesheets/application.scss";
import "./vendor/bootstrap";
import videojs from "video.js";
import "videojs-youtube";
import $ from "jquery";

import "@hotwired/turbo-rails";
require("@rails/activestorage").start();
require("channels");

// Dispose all video.js players before Turbo caches the page to prevent
// leaked instances and duplicate event handlers on back/forward navigation.
$(document).on("turbo:before-cache", () => {
  Object.keys(videojs.getPlayers()).forEach((id) => {
    const player = videojs.getPlayers()[id];
    if (player) player.dispose();
  });
});

$(document).on("turbo:load", () => {
  const players = $(".video-js");
  players.each((_index, player) => {
    const config = JSON.parse(player.getAttribute("data-player-config") || "{}");
    const vp = videojs(player, config);
    vp.on("play", () => {
      players.each((_index, other) => {
        if (other !== player) {
          const otherPlayer = videojs.getPlayers()[other.id];
          if (otherPlayer) otherPlayer.pause();
        }
      });
    });
  });
});

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context("../images", true);
const imagePath = (name) => images(name, true);
