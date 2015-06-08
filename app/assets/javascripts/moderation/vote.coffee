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
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      if success
        switch action
          when 'vote'
            btn.attr 'disabled', 'disabled'
            btn[0].dataset.action = 'unvote'
            console.log("vote for #{upvote ? 'downvote' : 'upvote'}")
            other_btn = $ "button[name=mod-vote][data-id=#{id}][data-vote-type=#{if upvote then 'downvote' else 'upvote'}]"
            other_btn.removeAttr 'disabled'
            other_btn[0].dataset.action = 'unvote'
          when 'unvote'
            btn.removeAttr 'disabled'
            btn[0].dataset.action = 'vote'
            console.log("vote for #{upvote ? 'downvote' : 'upvote'}")
            other_btn = $ "button[name=mod-vote][data-id=#{id}][data-vote-type=#{if upvote then 'downvote' else 'upvote'}]"
            other_btn.removeAttr 'disabled', 'disabled'
            other_btn[0].dataset.action = 'vote'
