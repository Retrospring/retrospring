#= require jquery
#= require jquery_ujs
#= require jquery.turbolinks
#= require turbolinks
#= require bootstrap
#= require growl
#= require cheet
#= require jquery.guillotine
#= require sweet-alert
#= require_tree .

Turbolinks.enableProgressBar()

window.showNotification = (text, success=true) ->
  args =
    title: if success then "Success!" else "Uh-oh..."
    message: text
  if success
    $.growl.notice args
  else
    $.growl.error args

$(document).on "click", "button#create-account", ->
  Turbolinks.visit "/sign_up"

_ready = ->
  sweetAlertInitialize()

$(document).ready _ready
$(document).on 'page:load', _ready
