$(document).on "click", "a[data-action=ab-comment-destroy]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  cid = btn[0].dataset.cId
  swal
    title: translate('frontend.destroy_comment.confirm.title')
    text: translate('frontend.destroy_comment.confirm.text')
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.delete')
    cancelButtonText: translate('views.actions.cancel')
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
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
