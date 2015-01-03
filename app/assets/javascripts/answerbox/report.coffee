$(document).on "click", "a[data-action=ab-report]", (ev) ->
  ev.preventDefault()
  swal
    title: "Report?"
    text: "A moderator will check this and decide what happens!"
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: "Report!"
    closeOnConfirm: false
  , ->
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