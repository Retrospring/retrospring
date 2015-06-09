$(document).on "keydown", "textarea#q-answer", (evt) ->
  qid = $(this)[0].dataset.id
  if evt.keyCode == 13 and evt.ctrlKey
    # trigger warning:
    $("button#q-answer").trigger 'click'


$(document).on "click", "button#q-answer", ->
  btn = $(this)
  btn.button "loading"
  qid = btn[0].dataset.qId
  $("textarea#q-answer").attr "readonly", "readonly"

  shareTo = []
  ($ "input[type=checkbox][name=share][data-q-id=#{qid}]:checked").each (i, share) ->
    shareTo.push share.dataset.service

  $.ajax
    url: '/ajax/answer'
    type: 'POST'
    dataType: 'json'
    data:
      id: qid
      answer: $("textarea#q-answer[data-id=#{qid}]").val()
      share: JSON.stringify shareTo
      inbox: false
    success: (data, status, jqxhr) ->
      if data.success
        $("div#q-answer-box").slideUp()
        ($ "div#answers").prepend data.render
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea#q-answer").removeAttr "readonly"
