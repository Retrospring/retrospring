$(document).on "click", "button[name=qb-all-ask]", ->
  btn = $(this)
  btn.button "loading"
  $("textarea[name=qb-all-question]").attr "readonly", "readonly"

  rcptSelect = ($ 'select[name=qb-all-rcpt]')

  rcpt = if rcptSelect.length > 0
           rcptSelect.first().val()
         else
           'followers'

  $.ajax
    url: '/ajax/ask'
    type: 'POST'
    data:
      rcpt: rcpt
      question: $("textarea[name=qb-all-question]").val()
      anonymousQuestion: false
    success: (data, status, jqxhr) ->
      if data.success
        $("textarea[name=qb-all-question]").val ''
        $('#modal-ask-followers').modal('hide')
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=qb-all-question]").removeAttr "readonly"

# hotkey for accessing this quickly
$(document).on "keydown", (evt) ->
  if evt.keyCode == 77 and (evt.ctrlKey or evt.metaKey)
    $('.btn[name=toggle-all-ask]').trigger 'click'

# see GitHub issue #2
($ document).on "keydown", "textarea[name=qb-all-question]", (evt) ->
  if evt.keyCode == 13 and (evt.ctrlKey or evt.metaKey)
    ($ "button[name=qb-all-ask]").trigger 'click'
