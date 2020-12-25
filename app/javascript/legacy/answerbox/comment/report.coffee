$(document).on "click", "a[data-action=ab-comment-report]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  cid = btn[0].dataset.cId
  reportDialog "comment", cid, -> btn.button "reset"
