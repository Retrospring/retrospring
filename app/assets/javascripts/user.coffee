$(document).on "click", "button[name=user-action]", ->
  btn = $(this)
  btn.button "loading"
  type = btn[0].dataset.type
  target = btn[0].dataset.target
  action = btn[0].dataset.action
  if type in ['follower', 'friend']
    count = Number $("h4.entry-text##{type}-count").html()

  target_url = switch action
    when 'follow'
      count++
      '/ajax/create_friend'
    when 'unfollow'
      count--
      '/ajax/destroy_friend'

  success = false

  $.ajax
    url: target_url
    type: 'POST'
    data:
      screen_name: target
    success: (data, status, jqxhr) ->
      success = data.success
      if data.success
        if type in ['follower', 'friend']
          $("h4.entry-text##{type}-count").html(count)
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"
      if success
        switch action
          when 'follow'
            btn[0].dataset.action = 'unfollow'
            btn.attr 'class', 'btn btn-default btn-block profile--follow-btn'
            btn.html 'Unfollow'
          when 'unfollow'
            btn[0].dataset.action = 'follow'
            btn.attr 'class', 'btn btn-primary btn-block profile--follow-btn'
            btn.html 'Follow'


# report user
$(document).on "click", "a[data-action=report-user]", (ev) ->
  ev.preventDefault()
  btn = $(this)
  target = btn[0].dataset.target
  reportDialog "user", target, -> btn.button "reset"
