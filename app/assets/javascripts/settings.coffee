# see GitHub issue #11
($ document).on "submit", "form#edit_user", (evt) ->
  if ($ "input#user_current_password").val().length == 0
    evt.preventDefault()
    $("button[data-target=#modal-passwd]").trigger 'click'