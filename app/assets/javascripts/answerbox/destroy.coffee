$(document).on "click", "a[data-action=ab-destroy]", (ev) ->
  ev.preventDefault()
  if confirm 'Are you sure?'
    btn = $(this)
    btn.button "loading"
    aid = btn[0].dataset.aId
    $.ajax
      url: '/ajax/destroy_answer' # TODO: find a way to use rake routes instead of hardcoding them here
      type: 'POST'
      data:
        answer: aid
      success: (data, status, jqxhr) ->
        if data.success
          $("div.answerbox[data-id=#{aid}]").slideUp()
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification "An error occurred, a developer should check the console for details", false
      complete: (jqxhr, status) ->
        btn.button "reset"