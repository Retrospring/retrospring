($ document).on "click", "input[type=checkbox][name=gm-list-check]", ->
  box = $(this)
  box.attr 'disabled', 'disabled'

  listName = box[0].dataset.list

  count = Number ($ "span##{listName}-members").html()
  boxChecked = box[0].checked

  count += if boxChecked then 1 else -1

  $.ajax
    url: '/ajax/list_membership'
    type: 'POST'
    data:
      user: box[0].dataset.user
      list: listName
      add: boxChecked
    success: (data, status, jqxhr) ->
      if data.success
        box[0].checked = if data.checked? then data.checked else !boxChecked
        ($ "span##{listName}-members").html(count)
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      box[0].checked = false
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      box.removeAttr "disabled"


$(document).on "keyup", "input#new-list-name", (evt) ->
  if evt.which == 13  # return key
    evt.preventDefault()
    $("button#create-list").trigger 'click'


($ document).on "click", "button#create-list", ->
  btn = $(this)
  btn.button "loading"
  input = ($ "input#new-list-name")

  $.ajax
    url: '/ajax/create_list'
    type: 'POST'
    data:
      name: input.val()
      user: btn[0].dataset.user
    dataType: 'json'
    success: (data, status, jqxhr) ->
      if data.success
        ($ "#lists-list ul.list-group").append(data.render)
        input.val ''
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      btn.button "reset"


($ document).on "click", "a#delete-list", (ev) ->
  ev.preventDefault()
  btn = $(this)
  list = btn[0].dataset.list

  swal
    title: translate('frontend.list.title')
    text: translate('frontend.list.text')
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.delete')
    cancelButtonText: translate('views.actions.cancel')
    closeOnConfirm: true
  , ->
    $.ajax
      url: '/ajax/destroy_list'
      type: 'POST'
      data:
        list: list
      dataType: 'json'
      success: (data, status, jqxhr) ->
        if data.success
          ($ "li.list-group-item#list-#{list}").slideUp()
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
