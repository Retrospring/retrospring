$(document).on "click", "button[name=user-action]", ->
  btn = $(this)
  btn.button "loading"
  type = btn[0].dataset.type
  target = btn[0].dataset.target
  action = btn[0].dataset.action
  if type in ['follower', 'friend']
    count = Number $("h4.entry-text##{type}-count").html()

  target_url = switch action
    when 'follow'
      count++
      '/ajax/create_friend'
    when 'unfollow'
      count--
      '/ajax/destroy_friend'

  success = false

  $.ajax
    url: target_url
    type: 'POST'
    data:
      screen_name: target
    success: (data, status, jqxhr) ->
      success = data.success
      if data.success
        if type in ['follower', 'friend']
          $("h4.entry-text##{type}-count").html(count)
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"
      if success
        switch action
          when 'follow'
            btn[0].dataset.action = 'unfollow'
            btn.attr 'class', 'btn btn-default btn-block profile--follow-btn'
            btn.html 'Unfollow'
          when 'unfollow'
            btn[0].dataset.action = 'follow'
            btn.attr 'class', 'btn btn-primary btn-block profile--follow-btn'
            btn.html 'Follow'


# report user
$(document).on "click", "a[data-action=report-user]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  target = btn[0].dataset.target
  reportDialog "user", target, -> btn.button "reset"

# parallax
PARALLAX_PREFIX = undefined
if typeof document.documentElement.style.webkitTransform == "string"
  PARALLAX_PREFIX = "webkit"
if typeof document.documentElement.style.mozTransform == "string"
  PARALLAX_PREFIX = "moz"
if typeof document.documentElement.style.oTransform == "string"
  PARALLAX_PREFIX = "o"
if typeof document.documentElement.style.msTransform == "string"
  PARALLAX_PREFIX = "ms"
if typeof document.documentElement.style.khtmlTransform == "string"
  PARALLAX_PREFIX = "khtml"
if typeof document.documentElement.style.transform == "string"
  PARALLAX_PREFIX = ""

HEADER_PARALLAX = undefined

if PARALLAX_PREFIX?
  PARALLAX_CSS = "transform"
  if PARALLAX_PREFIX.length
    PARALLAX_CSS = PARALLAX_PREFIX + PARALLAX_CSS.charAt(0).toUpperCase() + PARALLAX_CSS.slice(1)

  window.HEADER_PARALLAX_INERTIA = 0.4;

  HEADER_PARALLAX = ->
    header = $("#profile--header:not(.profile--no-header) img")[0]
    return unless header?
    top = (document.body || document.documentElement).scrollTop * HEADER_PARALLAX_INERTIA
    header.style[PARALLAX_CSS] = "translate3d(0px, #{top}px, 0px)";

  $(window).on "scroll", (event) ->
    HEADER_PARALLAX()

$(document).ready ->
  HEADER_PARALLAX() if HEADER_PARALLAX?
