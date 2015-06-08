($ document).on "click", "input[type=checkbox][name=gm-group-check]", ->
  box = $(this)
  box.attr 'disabled', 'disabled'

  groupName = box[0].dataset.group

  count = Number ($ "span##{groupName}-members").html()
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
        ($ "span##{groupName}-members").html(count)
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      box[0].checked = false
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      box.removeAttr "disabled"


$(document).on "keyup", "input#new-group-name", (evt) ->
  if evt.which == 13  # return key
    evt.preventDefault()
    $("button#create-group").trigger 'click'


($ document).on "click", "button#create-group", ->
  btn = $(this)
  btn.button "loading"
  input = ($ "input#new-group-name")

  $.ajax
    url: '/ajax/create_group'
    type: 'POST'
    data:
      name: input.val()
      user: btn[0].dataset.user
    dataType: 'json'
    success: (data, status, jqxhr) ->
      if data.success
        ($ "ul.list-group.groups--list").append(data.render)
        input.val ''
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      btn.button "reset"


($ document).on "click", "a#delete-group", (ev) ->
  ev.preventDefault()
  btn = $(this)
  group = btn[0].dataset.group

  swal
    title: translate('frontend.group.title')
    text: translate('frontend.group.text')
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.delete')
    cancelButtonText: translate('views.actions.cancel')
    closeOnConfirm: true
  , ->
    $.ajax
      url: '/ajax/destroy_group'
      type: 'POST'
      data:
        group: group
      dataType: 'json'
      success: (data, status, jqxhr) ->
        if data.success
          ($ "li.list-group-item#group-#{group}").slideUp()
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
