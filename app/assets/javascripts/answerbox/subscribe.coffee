# the laziest coding known to man
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
        btn[0].children[0].nextSibling.textContent = ["Subscribe", "Unsubscribe"][torpedo]
        showNotification "Successfully " + endpoint + "d.", true
      else
        showNotification "Couldn't unsubscribe from the answer.", false
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
