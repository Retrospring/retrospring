import 'core-js/stable'
import 'regenerator-runtime/runtime'

import './jquery'
import './bootstrap'
import {} from 'jquery-ujs'
import 'jquery.turbolinks/src/jquery.turbolinks'
import 'jquery.guillotine'
import 'particleground/jquery.particleground.min'
import 'jquery.growl'
import NProgress from 'nprogress'
import Cookies from 'js-cookie'

import './answerbox'
import './questionbox'
import './inbox'
import './memes'
import './notifications'
import './pagination'
import './question'
import './settings'
import './user'
import './report'
import './locale-box'
import './util'

#= require jquery3
#= require jquery_ujs
#= require jquery.turbolinks
#= require turbolinks
#= require popper
#= require bootstrap
#= require nprogress
#= require nprogress-turbolinks
#= require growl
#= require cheet
#= require jquery.guillotine
#= require jquery.particleground
#= require sweetalert
#= require js.cookie
#= require i18n
#= require_tree ./i18n
#= require tinycolor-min
#= require jquery.minicolors
# local requires to be seen by everyone:
#= require_tree ./answerbox
#= require_tree ./questionbox
#= require lists
#= require inbox
#= require memes
#= require notifications
#= require pagination
#= require question
#= require settings
#= require user
#= require report
#= require locale-box

# not required:
# _tree ./moderation

NProgress.configure
  showSpinner: false

window.translate = (scope, options) ->
  # for some reason I18n errors when calling it by assign proxy, so we got to wrap it
  I18n.translate(scope, options)

window.showNotification = (text, success=true) ->
  args =
    title: translate((if success then 'frontend.success.title' else 'frontend.error.title'))
    message: text
  if success
    $.growl.notice args
  else
    $.growl.error args

I18n.defaultLocale = 'en';
I18n.locale = Cookies.get('hl') || 'en';

window.showNotificationXHRError = (jqxhr, status, error) ->
  console.log jqxhr, status, error
  showNotification translate('frontend.error.message'), false

$(document).on "click", "button#create-account", ->
  Turbolinks.visit "/sign_up"

_ready = ->
  if typeof sweetAlertInitialize != "undefined"
    sweetAlertInitialize()

  if document.getElementById('particles')?
    jumbo         = $ '.j2-jumbo'
    bodyColorOrig = jumbo.css 'background-color'
    bodyColor     = doppler 0.25, bodyColorOrig
    console.log bodyColor, bodyColorOrig
    particleground document.getElementById('particles'),
      dotColor: bodyColor
      lineColor: bodyColor
      density: 23000

  $(".announcement").each ->
    aId = $(this)[0].dataset.announcementId
    unless (window.localStorage.getItem("announcement#{aId}"))
      $(this).toggleClass("d-none")

  $(document).on "click", ".announcement button.close", (evt) ->
    announcement = event.target.closest(".announcement")
    aId = announcement.dataset.announcementId
    window.localStorage.setItem("announcement#{aId}", true)


$(document).ready _ready
$(document).on 'page:load', _ready
