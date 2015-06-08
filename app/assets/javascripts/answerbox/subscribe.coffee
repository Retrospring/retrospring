# the laziest coding known to man
# TODO: so lazy, I don't know how to localize it properly
$(document).on "click", "a[data-action=ab-submarine]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  aid = btn[0].dataset.aId
  torpedo = 0
  if btn[0].dataset.torpedo == "yes"
    torpedo = 1

  endpoint = "subscribe"
  if torpedo == 0
    endpoint = "un" + endpoint

  $.ajax
    url: '/ajax/' + endpoint # TODO: find a way to use rake routes instead of hardcoding them here
    type: 'POST'
    data:
      answer: aid
    success: (data, status, jqxhr) ->
      if data.success
        btn[0].dataset.torpedo = ["yes", "no"][torpedo]
        btn[0].children[0].nextSibling.textContent = if torpedo then translate("views.actions.unsubscribe") else translate("views.actions.subscribe")
        showNotification translate("frontend.subscription.#{endpoint}"), true
      else
        showNotification translate("frontend.subscription.fail.#{endpoint}"), false
    error: showNotificationXHRError
    complete: (jqxhr, status) ->
