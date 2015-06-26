$(document).on 'click', '#locale-switch', (event) ->
  event.preventDefault()
  $('#locales-panel').slideToggle()
  $("html, body").animate({ scrollTop: $(document).height() }, 1000)
