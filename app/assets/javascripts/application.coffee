#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require semantic-ui
#= require_tree .

$(document).ready ->
  $('.ui.dropdown').dropdown
    on: "hover"