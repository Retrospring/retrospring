$(document).on "click", "a[data-action=ab-report]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  aid = btn[0].dataset.aId
  reportDialog "answer", aid, -> btn.button "reset"
