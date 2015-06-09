$(document).on "click", "a[data-action=ab-destroy]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  aid = btn[0].dataset.aId
  swal
    title: translate('frontend.destroy_question.confirm.title')
    text: translate('frontend.destroy_question.confirm.text')
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.y')
    cancelButtonText: translate('views.actions.n')
    closeOnConfirm: true
  , ->
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
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
