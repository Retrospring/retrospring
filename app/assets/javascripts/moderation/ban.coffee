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

  untilInput = $ modalForm.elements["until"]
  untilInput.datetimepicker
    defaultDate: untilInput.val()
    sideBySide: true
    icons:
      time: "fa fa-clock-o"
      date: "fa fa-calendar"
      up: "fa fa-chevron-up"
      down: "fa fa-chevron-down"
      previous: "fa fa-chevron-left"
      next: "fa fa-chevron-right"
      today: "fa fa-home"
      clear: "fa fa-trash-o"
      close: "fa fa-times"

  modalForm.addEventListener "submit", (event) ->
    event.preventDefault();

    checktostr = (el) ->
      if el.checked
        "1"
      else
        "0"

    data = {
      ban: checktostr banCheckbox
      permaban: checktostr permabanCheckbox
      until: modalForm.elements["until"].value.trim()
      reason: modalForm.elements["reason"].value.trim()
      user: modalForm.elements["user"].value
    }

    $.ajax
      url: '/ajax/mod/ban'
      type: 'POST'
      data: data
      success: (data, status, jqxhr) ->
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->

$(document).on "DOMContentLoaded", ->
  load()

$(document).on "page:load", ->
  load()
