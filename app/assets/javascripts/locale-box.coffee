$(document).on 'click', '#locale-switch', (event) ->
  event.preventDefault()
  $('#locales-panel').slideToggle()
