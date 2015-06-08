window.reportDialog = (type, target, callback) ->
  swal
    title: translate('frontend.report.confirm.title', {type: type})
    text: translate('frontend.report.confirm.text')
    type: "input"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.report')
    cancelButtonText: translate('views.actions.cancel')
    closeOnConfirm: true
    inputPlaceholder: translate('frontend.report.confirm.input')
  , (value) ->
    if typeof value == "boolean" && value == false
      return false

    $.ajax
      url: '/ajax/report'
      type: 'POST'
      data:
        id: target
        type: type
        reason: value
      success: (data, status, jqxhr) ->
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
        callback type, target, jqxhr, status
