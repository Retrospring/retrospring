($ document).on "click", "input[type=checkbox][name=gm-group-check]", ->
  box = $(this)
  box.attr 'disabled', 'disabled'

  groupName = box[0].dataset.group

  count = Number $("span##{groupName}-members").html()
  boxChecked = box[0].checked

  count += if boxChecked then 1 else -1

  $.ajax
    url: '/ajax/group_membership'
    type: 'POST'
    data:
      user: box[0].dataset.user
      group: groupName
      add: boxChecked
    success: (data, status, jqxhr) ->
      if data.success
        box[0].checked = if data.checked? then data.checked else !boxChecked
        $("span##{groupName}-members").html(count)
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      box[0].checked = false
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      box.removeAttr "disabled"