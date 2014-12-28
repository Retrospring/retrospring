($ document).on "click", "button[name=mod-vote]", ->
  btn = $(this)
  id = btn[0].dataset.id
  action = btn[0].dataset.action
  upvote = btn[0].dataset.voteType == 'upvote'
  btn.attr 'disabled', 'disabled'

  target_url = switch action
    when 'vote'
      '/ajax/mod/create_vote'
    when 'unvote'
      '/ajax/mod/destroy_vote'

  success = false

  $.ajax
    url: target_url
    type: 'POST'
    data:
      id: id
      upvote: upvote
    success: (data, status, jqxhr) ->
      success = data.success
      if success
        ($ "span#mod-count-#{id}").html(data.count)
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.removeAttr 'disabled'
      if success
        switch action
          when 'vote'
            btn[0].dataset.action = 'unvote'
            other_btn = ($ "button[name=mod-vote][data-id=#{id}][data-action=vote]")
            other_btn.attr 'disabled', 'disabled'
            other_btn[0].dataset.action = 'unvote'
          when 'unvote'
            btn[0].dataset.action = 'vote'
            other_btn = ($ "button[name=mod-vote][data-id=#{id}][data-action=unvote]")
            other_btn.removeAttr 'disabled'
            other_btn[0].dataset.action = 'vote'