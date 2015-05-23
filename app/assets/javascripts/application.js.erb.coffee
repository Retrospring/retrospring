#= require jquery
#= require jquery_ujs
#= require jquery.turbolinks
#= require turbolinks
#= require bootstrap
#= require nprogress
#= require nprogress-turbolinks
#= require growl
#= require cheet
#= require jquery.guillotine
#= require jquery.particleground
#= require sweet-alert
# local requires to be seen by everyone:
#= require_tree ./answerbox
#= require_tree ./questionbox
#= require groups
#= require inbox
#= require memes
#= require notifications
#= require pagination
#= require piwik
#= require question
#= require settings
#= require user
#= require report
#= require oauth
# not required:
# _tree ./moderation

NProgress.configure
  showSpinner: false

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
  if typeof sweetAlertInitialize != "undefined"
    sweetAlertInitialize()

  if document.getElementById('particles')?
    particleground document.getElementById('particles'),
      dotColor: '#5e35b1'
      lineColor: '#5e35b1'

$(document).ready _ready
$(document).on 'page:load', _ready
