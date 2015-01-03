$(document).on "click", "a[data-action=ab-comment-destroy]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  cid = btn[0].dataset.cId
  swal
    title: "Really delete?"
    text: "You will not be able to recover this comment."
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: "Delete"
    closeOnConfirm: true
  , ->
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