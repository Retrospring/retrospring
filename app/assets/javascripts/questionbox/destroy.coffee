$(document).on "click", "a[data-action=ab-question-destroy]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  qid = btn[0].dataset.qId
  swal
    title: translate('frontend.destroy_own.confirm.title')
    text: translate('frontend.destroy_own.confirm.text')
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.y')
    cancelButtonText: translate('views.actions.n')
    closeOnConfirm: true
  , ->
    $.ajax
      url: '/ajax/destroy_question' # TODO: find a way to use rake routes instead of hardcoding them here
      type: 'POST'
      data:
        question: qid
      success: (data, status, jqxhr) ->
        if data.success
          if btn[0].dataset.redirect != undefined
            window.location.pathname = btn[0].dataset.redirect
          else
            $("div.answerbox[data-q-id=#{qid}], div.questionbox[data-id=#{qid}]").slideUp()
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
