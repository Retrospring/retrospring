$(document).on "click", "a[data-action=ab-comment-report]", (ev) ->
  ev.preventDefault()
  if confirm 'Are you sure you want to report this comment?'
    btn = $(this)
    cid = btn[0].dataset.cId
    $.ajax
      url: '/ajax/report'
      type: 'POST'
      data:
        id: cid
        type: 'comment'
      success: (data, status, jqxhr) ->
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification "An error occurred, a developer should check the console for details", false
      complete: (jqxhr, status) ->
        btn.button "reset"