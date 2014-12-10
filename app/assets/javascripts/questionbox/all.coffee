$(document).on "click", "button[name=qb-all-ask]", ->
  btn = $(this)
  btn.button "loading"
  $("textarea[name=qb-all-question]").attr "readonly", "readonly"

  $.ajax
    url: '/ajax/ask'
    type: 'POST'
    data:
      rcpt: "followers"
      question: $("textarea[name=qb-all-question]").val()
      anonymousQuestion: false
    success: (data, status, jqxhr) ->
      if data.success
        $("textarea[name=qb-all-question]").val ''
        $('#modal-ask-followers').modal('hide')
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=qb-all-question]").removeAttr "readonly"


# see GitHub issue #2
($ document).on "keydown", "textarea[name=qb-all-question]", (evt) ->
  if evt.keyCode == 13 and evt.ctrlKey
    ($ "button[name=qb-all-ask]").trigger 'click'