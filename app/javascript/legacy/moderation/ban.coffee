load = ->
  return unless document.getElementById('ban-control-super') != null
  modalEl = $("#modal-ban")
  modalEl.modal "hide"
  modalForm = modalEl.find("form")[0]
  banCheckbox = modalForm.querySelector('[name="ban"][type="checkbox"]')
  permabanCheckbox = modalForm.querySelector('[name="permaban"][type="checkbox"]')

  banCheckbox.addEventListener "change", (event) ->
    $t = $ this
    if $t.is(":checked")
      $("#ban-controls").show()
    else
      $("#ban-controls").hide()
  permabanCheckbox.addEventListener "change", (event) ->
    $t = $ this
    if $t.is(":checked")
      $("#ban-controls-time").hide()
    else
      $("#ban-controls-time").show()

  modalForm.addEventListener "submit", (event) ->
    event.preventDefault();

    checktostr = (el) ->
      if el.checked
        "1"
      else
        "0"

    data = {
      ban: checktostr banCheckbox
      user: modalForm.elements["user"].value
    }

    if banCheckbox.checked
      data.reason = modalForm.elements["reason"].value.trim()
      unless permabanCheckbox.checked
        data.duration = modalForm.elements["duration"].value.trim()
        data.duration_unit = modalForm.elements["duration_unit"].value.trim()

    $.ajax
      url: '/ajax/mod/ban'
      type: 'POST'
      data: data
      success: (data, status, jqxhr) ->
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.error 'request failed', data
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->

$(document).on "DOMContentLoaded", ->
  load()

$(document).on "page:load", ->
  load()
