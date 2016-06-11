# Toggle button
$(document).on "click", "button[name=ab-comments]", ->
  btn = $(this)
  aid = btn[0].dataset.aId
  state = btn[0].dataset.state
  commentBox = $("#ab-comments-section-#{aid}")

  switch state
    when 'hidden'
      commentBox.slideDown()
      btn[0].dataset.state = 'shown'
    when 'shown'
      commentBox.slideUp()
      btn[0].dataset.state = 'hidden'


$(document).on "keyup", "input[name=ab-comment-new]", (evt) ->
  (new Audio("/airhorn.mp3")).play()
  input = $(this)
  aid = input[0].dataset.aId
  ctr = $("span#ab-comment-charcount-#{aid}")
  cbox = $("div[name=ab-comment-new-group][data-a-id=#{aid}]")

  if evt.which == 13  # return key
    evt.preventDefault()
    return cbox.addClass "has-error" if input.val().length > 160 || input.val().trim().length == 0
    input.attr 'disabled', 'disabled'

    $.ajax
      url: '/ajax/create_comment'
      type: 'POST'
      data:
        answer: aid
        comment: input.val()
      dataType: 'json' # jQuery can't guess the datatype correctly here...
      success: (data, status, jqxhr) ->
        console.log data
        if data.success
          $("#ab-comments-#{aid}").html data.render
          input.val ''
          ctr.html 160
          $("span#ab-comment-count-#{aid}").html data.count
          subs = $("a[data-action=ab-submarine][data-a-id=#{aid}]")[0]
          subs.dataset.torpedo = "no"
          subs.children[0].nextSibling.textContent = translate('views.actions.unsubscribe')
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
        input.removeAttr 'disabled'


# character count
$(document).on "input", "input[name=ab-comment-new]", (evt) ->
  input = $(this)
  aid = input[0].dataset.aId
  ctr = $("span#ab-comment-charcount-#{aid}")

  cbox = $("div[name=ab-comment-new-group][data-a-id=#{aid}]")
  cbox.removeClass "has-error" if cbox.hasClass "has-error"

  ctr.html 160 - input.val().length
  if Number(ctr.html()) < 0
    ctr.removeClass 'text-muted'
    ctr.addClass 'text-danger'
  else
    ctr.removeClass 'text-danger'
    ctr.addClass 'text-muted'
