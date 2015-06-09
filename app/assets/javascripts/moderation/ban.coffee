load = ->
  parent = $ "#ban-control-super"
  return unless parent.length > 0

  parent.find('#_ban').on "change", (event) ->
    $t = $ this
    if $t.is(":checked")
      $("#ban-controls").show()
    else
      $("#ban-controls").hide()
  parent.find('#_permaban').on "change", (event) ->
    $t = $ this
    if $t.is(":checked")
      $("#ban-controls-time").hide()
    else
      $("#ban-controls-time").show()

  parent.find("#until").datetimepicker
    defaultDate: parent.find("#until").val()
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

  parent.parent()[0].addEventListener "submit", (event) ->
    event.preventDefault();

    $("#modal-ban").modal "hide"

    checktostr = (selector) ->
      if $(selector)[0].checked
        "1"
      else
        "0"

    data = {
      ban: checktostr "#_ban"
      permaban: checktostr "#_permaban"
      until: $("#until")[0].value.trim()
      reason: $("#reason")[0].value.trim()
      user: $("#_user")[0].value
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
