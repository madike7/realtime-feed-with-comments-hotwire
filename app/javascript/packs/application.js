// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
window.Rails = require("@rails/ujs");
import "@hotwired/turbo-rails"
//import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "embed"
import "@fortawesome/fontawesome-free/js/all";
//import "@fortawesome/fontawesome-free/css/all";


Rails.start()
ActiveStorage.start()

require("trix")
require("@rails/actiontext")
require("controllers")

$(document).on("turbolinks:load", () => {
  console.log("turbolinks!");
});
$(document).on("turbo:load", () => {
  console.log("turbo!");
});