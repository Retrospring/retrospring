$(document).on "click", "button[name=mod-delete-report]", ->
  btn = $(this)
  id = btn[0].dataset.id
  swal
    title: translate('frontend.destroy_report.confirm.title')
    text: translate('frontend.destroy_report.confirm.text')
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.delete')
    cancelButtonText: translate('views.actions.cancel')
    closeOnConfirm: true
  , ->
    $.ajax
      url: '/ajax/mod/destroy_report'
      type: 'POST'
      data:
        id: id
      success: (data, status, jqxhr) ->
        if data.success
          $("div.moderationbox[data-id=#{id}]").slideUp()
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
