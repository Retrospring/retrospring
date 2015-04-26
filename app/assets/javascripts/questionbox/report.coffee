$(document).on "click", "a[data-action=ab-question-report]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  qId = btn[0].dataset.qId
  reportDialog "question", qId, -> btn.button "reset"
