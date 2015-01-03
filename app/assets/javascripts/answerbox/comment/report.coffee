$(document).on "click", "a[data-action=ab-comment-report]", (ev) ->
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