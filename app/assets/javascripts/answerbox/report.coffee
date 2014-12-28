$(document).on "click", "a[data-action=ab-report]", (ev) ->
  ev.preventDefault()
  if confirm 'Are you sure you want to report this answer?'
    btn = $(this)
    aid = btn[0].dataset.aId
    $.ajax
      url: '/ajax/report' # TODO: find a way to use rake routes instead of hardcoding them here
      type: 'POST'
      data:
        id: aid
        type: 'answer'
      success: (data, status, jqxhr) ->
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification "An error occurred, a developer should check the console for details", false
      complete: (jqxhr, status) ->
        btn.button "reset"