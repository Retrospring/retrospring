$(document).on "DOMContentLoaded", ->
  parent = $ "#ban-control-super"
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
      until: $("#until")[0].value
      reason: $("#reason")[0].value
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
        showNotification "An error occurred, a developer should check the console for details", false
      complete: (jqxhr, status) ->
