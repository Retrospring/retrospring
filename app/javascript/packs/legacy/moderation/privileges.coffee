($ document).on "click", "input[type=checkbox][name=check-your-privileges]", ->
  box = $(this)
  box.attr 'disabled', 'disabled'

  privType = box[0].dataset.type
  boxChecked = box[0].checked

  $.ajax
    url: '/ajax/mod/privilege'
    type: 'POST'
    data:
      user: box[0].dataset.user
      type: privType
      status: boxChecked
    success: (data, status, jqxhr) ->
      if data.success
        box[0].checked = if data.checked? then data.checked else !boxChecked
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      box[0].checked = false
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      box.removeAttr "disabled"
