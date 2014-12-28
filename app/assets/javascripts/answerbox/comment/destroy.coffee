$(document).on "click", "a[data-action=ab-comment-destroy]", (ev) ->
  ev.preventDefault()
  if confirm 'Are you sure?'
    btn = $(this)
    cid = btn[0].dataset.cId
    $.ajax
      url: '/ajax/destroy_comment'
      type: 'POST'
      data:
        comment: cid
      success: (data, status, jqxhr) ->
        if data.success
          $("li[data-comment-id=#{cid}]").slideUp()
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification "An error occurred, a developer should check the console for details", false
      complete: (jqxhr, status) ->