window.reportDialog = (type, target, callback) ->
  swal
    title: "Really report this #{type}?"
    text: "A moderator will review your report and decide what happens.\nIf you'd like, you can also specify a reason."
    type: "input"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: "Report"
    closeOnConfirm: true
    inputPlaceholder: "Specify a reason..."
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
        showNotification "An error occurred, a developer should check the console for details", false
      complete: (jqxhr, status) ->
        callback type, target, jqxhr, status
