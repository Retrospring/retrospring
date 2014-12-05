#= require jquery
#= require jquery_ujs
#= require jquery.turbolinks
#= require turbolinks
#= require bootstrap
#= require nprogress
#= require nprogress-turbolinks
#= require growl
#= require_tree .

NProgress.configure
  showSpinner: false

showNotification = (text, success=true) ->
  args =
    title: if success then "Success!" else "Uh-oh..."
    message: text
  if success
    $.growl.notice args
  else
    $.growl.error args

$(document).on "click", "button[name=qb-ask]", ->
  btn = $(this)
  btn.button "loading"
  promote = btn[0].dataset.promote == "true"
  $("textarea[name=qb-question]").attr "readonly", "readonly"
  anonymousQuestion = if $("input[name=qb-anonymous]")[0] != undefined
                        $("input[name=qb-anonymous]")[0].checked
                      else
                        true
  $.ajax
    url: '/ajax/ask' # TODO: find a way to use rake routes instead of hardcoding them here
    type: 'POST'
    data:
      rcpt: $("input[name=qb-to]").val()
      question: $("textarea[name=qb-question]").val()
      anonymousQuestion: anonymousQuestion
    success: (data, status, jqxhr) ->
      if data.success
        $("textarea[name=qb-question]").val ''
        if promote
          $("div#question-box").hide()
          $("div#question-box-promote").show()
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=qb-question]").removeAttr "readonly"

$(document).on "click", "button[name=ib-answer]", ->
  btn = $(this)
  btn.button "loading"
  iid = btn[0].dataset.ibId
  $("textarea[name=ib-answer][data-id=#{iid}]").attr "readonly", "readonly"
  $.ajax
    url: '/ajax/answer' # TODO: find a way to use rake routes instead of hardcoding them here
    type: 'POST'
    data:
      id: iid
      answer: $("textarea[name=ib-answer][data-id=#{iid}]").val()
    success: (data, status, jqxhr) ->
      if data.success
        $("div.inbox-box[data-id=#{iid}]").slideUp()
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=ib-answer][data-id=#{iid}]").removeAttr "readonly"

$(document).on "click", "button[name=ib-destroy]", ->
  btn = $(this)
  btn.button "loading"
  iid = btn[0].dataset.ibId
  $("textarea[name=ib-answer][data-id=#{iid}]").attr "readonly", "readonly"
  $.ajax
    url: '/ajax/delete_inbox'
    type: 'POST'
    data:
      id: iid
    success: (data, status, jqxhr) ->
      if data.success
        $("div.inbox-box[data-id=#{iid}]").slideUp()
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=ib-answer][data-id=#{iid}]").removeAttr "readonly"

$(document).on "click", "button[name=ab-destroy]", ->
  btn = $(this)
  btn.button "loading"
  aid = btn[0].dataset.aId
  $.ajax
    url: '/ajax/destroy_answer' # TODO: find a way to use rake routes instead of hardcoding them here
    type: 'POST'
    data:
      answer: aid
    success: (data, status, jqxhr) ->
      if data.success
        $("div.answer-box[data-id=#{aid}]").slideUp()
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"

$(document).on "click", "button[name=ab-smile]", ->
  btn = $(this)
  aid = btn[0].dataset.aId
  action = btn[0].dataset.action
  count = Number $("span#ab-smile-count-#{aid}").html()
  btn[0].dataset.loadingText = "<i class=\"fa fa-meh-o fa-spin\"></i> <span id=\"ab-smile-count-#{aid}\">#{count}</span>"
  btn.button "loading"

  target_url = switch action
    when 'smile'
      count++
      '/ajax/create_smile'
    when 'unsmile'
      count--
      '/ajax/destroy_smile'

  success = false

  $.ajax
    url: target_url
    type: 'POST'
    data:
      id: aid
    success: (data, status, jqxhr) ->
      success = data.success
      if success
        $("span#ab-smile-count-#{aid}").html(count)
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification "An error occurred, a developer should check the console for details", false
    complete: (jqxhr, status) ->
      btn.button "reset"
      if success
        switch action
          when 'smile'
            btn[0].dataset.action = 'unsmile'
            btn.html "<i class=\"fa fa-frown-o\"></i> <span id=\"ab-smile-count-#{aid}\">#{count}</span>"
          when 'unsmile'
            btn[0].dataset.action = 'smile'
            btn.html "<i class=\"fa fa-smile-o\"></i> <span id=\"ab-smile-count-#{aid}\">#{count}</span>"

$(document).on "click", "button[name=ab-comments]", ->
  btn = $(this)
  aid = btn[0].dataset.aId
  state = btn[0].dataset.state
  commentBox = $("#ab-comments-#{aid}")

  switch state
    when 'hidden'
      commentBox.slideDown()
      btn[0].dataset.state = 'shown'
    when 'shown'
      commentBox.slideUp()
      btn[0].dataset.state = 'hidden'


$(document).on "click", "button[name=user-action]", ->
  btn = $(this)
  btn.button "loading"
  target = btn[0].dataset.target
  action = btn[0].dataset.action
  count = Number $("h4.entry-text#follower-count").html()

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
        $("h4.entry-text#follower-count").html(count)
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
            btn.attr 'class', 'btn btn-default btn-block'
            btn.html 'Unfollow'
          when 'unfollow'
            btn[0].dataset.action = 'follow'
            btn.attr 'class', 'btn btn-primary btn-block'
            btn.html 'Follow'

$(document).on "click", "button#create-account", ->
  Turbolinks.visit "/sign_up"

$(document).on "click", "button#new-question", ->
  $("div#question-box").show()
  $("div#question-box-promote").hide()
