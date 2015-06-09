$(document).on "click", "button[name=ab-smile-comment]", ->
  btn = $(this)
  cid = btn[0].dataset.cId
  action = btn[0].dataset.action
  count = Number $("span#ab-comment-smile-count-#{cid}").html()
  btn[0].dataset.loadingText = "<i class=\"fa fa-meh-o fa-spin\"></i> <span id=\"ab-smile-count-#{cid}\">#{count}</span>"
  btn.button "loading"

  target_url = switch action
    when 'smile'
      count++
      '/ajax/create_comment_smile'
    when 'unsmile'
      count--
      '/ajax/destroy_comment_smile'

  success = false

  $.ajax
    url: target_url
    type: 'POST'
    data:
      id: cid
    success: (data, status, jqxhr) ->
      success = data.success
      if success
        $("span#ab-comment-smile-count-#{cid}").html(count)
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      btn.button "reset"
      if success
        switch action
          when 'smile'
            btn[0].dataset.action = 'unsmile'
            btn.html "<i class=\"fa fa-frown-o\"></i> <span id=\"ab-comment-smile-count-#{cid}\">#{count}</span>"
          when 'unsmile'
            btn[0].dataset.action = 'smile'
            btn.html "<i class=\"fa fa-smile-o\"></i> <span id=\"ab-comment-smile-count-#{cid}\">#{count}</span>"
