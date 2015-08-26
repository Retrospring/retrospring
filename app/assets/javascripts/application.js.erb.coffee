#= require jquery
#= require jquery_ujs
#= require jquery.turbolinks
#= require turbolinks
#= require bootstrap
#= require twemoji
#= require nprogress
#= require nprogress-turbolinks
#= require growl
#= require cheet
#= require jquery.guillotine
#= require jquery.particleground
#= require sweet-alert
#  require rickshaw-rails
#= require js.cookie
#= require i18n
#= require i18n/translations
#= require tinycolor-min
#= require jquery.minicolors
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
#= require locale-box
#= require util
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

  if twemoji?
    twemoji.parse document.body,
      size: 16
      callback: (icon, options) ->
        switch icon
          # copyright, registered, trademark
          when 'a9' or 'ae' or '2122'
            false
          else
            ''.concat(options.base, options.size, '/', icon, options.ext)


$(document).ready _ready
$(document).on 'page:load', _ready
