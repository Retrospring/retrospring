($ document).on "click", "button#ib-generate-question", ->
  btn = ($ this)
  btn.button "loading"
  $.ajax
    url: '/ajax/generate_question'
    type: 'POST'
    dataType: 'json'
    success: (data, status, jqxhr) ->
      if data.success
        ($ "div#entries").prepend(data.render) # TODO: slideDown or something
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"

$(document).on "keydown", "textarea[name=ib-answer]", (evt) ->
  iid = $(this)[0].dataset.id
  if evt.keyCode == 13 and evt.ctrlKey
    # trigger warning:
    $("button[name=ib-answer][data-ib-id=#{iid}]").trigger 'click'

$(document).on "click", "button[name=ib-answer]", ->
  btn = $(this)
  btn.button "loading"
  iid = btn[0].dataset.ibId
  $("textarea[name=ib-answer][data-id=#{iid}]").attr "readonly", "readonly"
  $.ajax
    url: '/ajax/answer' # TODO: find a way to use rake routes instead of hardcoding them here
    type: 'POST'
    data:
      id: iid
      answer: $("textarea[name=ib-answer][data-id=#{iid}]").val()
    success: (data, status, jqxhr) ->
      if data.success
        $("div.inbox-box[data-id=#{iid}]").slideUp()
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=ib-answer][data-id=#{iid}]").removeAttr "readonly"

$(document).on "click", "button[name=ib-destroy]", ->
  if confirm 'Are you sure?'
    btn = $(this)
    btn.button "loading"
    iid = btn[0].dataset.ibId
    $("textarea[name=ib-answer][data-id=#{iid}]").attr "readonly", "readonly"
    $.ajax
      url: '/ajax/delete_inbox'
      type: 'POST'
      data:
        id: iid
      success: (data, status, jqxhr) ->
        if data.success
          $("div.inbox-box[data-id=#{iid}]").slideUp()
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification "An error occurred, a developer should check the console for details", false
      complete: (jqxhr, status) ->
        btn.button "reset"
        $("textarea[name=ib-answer][data-id=#{iid}]").removeAttr "readonly"