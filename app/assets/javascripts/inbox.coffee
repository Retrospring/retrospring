($ document).on "click", "button#ib-generate-question", ->
  btn = ($ this)
  btn.button "loading"
  $.ajax
    url: '/ajax/generate_question'
    type: 'POST'
    dataType: 'json'
    success: (data, status, jqxhr) ->
      if data.success
        ($ "div#entries").prepend(data.render) # TODO: slideDown or something
        # GitHub issue #26:
        if document.getElementById('ib-delete-all')?
          del_all_btn = ($ "button#ib-delete-all")
        else
          del_all_btn = ($ "button#ib-delete-all-author")
        del_all_btn.removeAttr 'disabled'
        del_all_btn[0].dataset.ibCount = (Number del_all_btn[0].dataset.ibCount) + 1
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      btn.button "reset"

($ document).on "click", "button#ib-author", ->
  $('#author_form').submit ->
    query = $('#author').val()
    window.location.href = '/inbox/' + query
    false


($ document).on "click", "button#ib-delete-all", ->
  btn = ($ this)
  count = btn[0].dataset.ibCount
  swal
    title: translate('frontend.inbox.confirm_all.title', {count: count})
    text: translate('frontend.inbox.confirm_all.text')
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.delete')
    cancelButtonText: translate('views.actions.cancel')
    closeOnConfirm: true
  , ->
    btn.button "loading"
    succ = no
    $.ajax
      url: '/ajax/delete_all_inbox'
      type: 'POST'
      dataType: 'json'
      success: (data, status, jqxhr) ->
        if data.success
          succ = yes
          ($ "div#pagination, button#load-more-btn").slideUp()
          entries = ($ "div#entries")
          entries.slideUp 400, ->
            entries.html("Nothing to see here.")
            entries.fadeIn()
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
        if succ
          # and now: a (broken?) re-implementation of Bootstrap's button.js
          btn.html btn.data('resetText')
          btn.removeClass 'disabled'
          btn[0].dataset.ibCount = 0

($ document).on "click", "button#ib-delete-all-author", ->
  btn = ($ this)
  count = btn[0].dataset.ibCount
  swal
    title: translate('frontend.inbox.confirm_all.title', {count: count})
    text: translate('frontend.inbox.confirm_all.text')
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.delete')
    cancelButtonText: translate('views.actions.cancel')
    closeOnConfirm: true
  , ->
    btn.button "loading"
    succ = no
    $.ajax
      url: "/ajax/delete_all_inbox/#{location.pathname.split('/')[2]}"
      type: 'POST'
      dataType: 'json'
      success: (data, status, jqxhr) ->
        if data.success
          succ = yes
          ($ "div#pagination, button#load-more-btn").slideUp()
          entries = ($ "div#entries")
          entries.slideUp 400, ->
            entries.html("Nothing to see here.")
            entries.fadeIn()
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
        if succ
# and now: a (broken?) re-implementation of Bootstrap's button.js
          btn.html btn.data('resetText')
          btn.removeClass 'disabled'
          btn[0].dataset.ibCount = 0


$(document).on "keydown", "textarea[name=ib-answer]", (evt) ->
  iid = $(this)[0].dataset.id
  if evt.keyCode == 13 and (evt.ctrlKey or evt.metaKey)
    # trigger warning:
    $("button[name=ib-answer][data-ib-id=#{iid}]").trigger 'click'


$(document).on "click", "button[name=ib-answer]", ->
  btn = $(this)
  btn.button "loading"
  iid = btn[0].dataset.ibId
  $("textarea[name=ib-answer][data-id=#{iid}]").attr "readonly", "readonly"

  shareTo = []
  ($ "input[type=checkbox][name=ib-share][data-ib-id=#{iid}]:checked").each (i, share) ->
    shareTo.push share.dataset.service

  $.ajax
    url: '/ajax/answer'
    type: 'POST'
    data:
      id: iid
      answer: $("textarea[name=ib-answer][data-id=#{iid}]").val()
      share: JSON.stringify shareTo
      inbox: true
    success: (data, status, jqxhr) ->
      if data.success
        $("div.inbox-box[data-id=#{iid}]").slideUp()
      showNotification data.message, data.success
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showNotification translate('frontend.error.message'), false
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=ib-answer][data-id=#{iid}]").removeAttr "readonly"


$(document).on "click", "button[name=ib-destroy]", ->
  btn = $(this)
  swal
    title: translate('frontend.inbox.confirm.title')
    text: translate('frontend.inbox.confirm.text')
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: translate('views.actions.delete')
    cancelButtonText: translate('views.actions.cancel')
    closeOnConfirm: true
  , ->
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
          if document.getElementById('ib-delete-all')?
            del_all_btn = ($ "button#ib-delete-all")
          else
            del_all_btn = ($ "button#ib-delete-all-author")
          del_all_btn.removeAttr 'disabled'
          del_all_btn[0].dataset.ibCount = (Number del_all_btn[0].dataset.ibCount) - 1
        showNotification data.message, data.success
      error: (jqxhr, status, error) ->
        console.log jqxhr, status, error
        showNotification translate('frontend.error.message'), false
      complete: (jqxhr, status) ->
        btn.button "reset"
        $("textarea[name=ib-answer][data-id=#{iid}]").removeAttr "readonly"


# Toggle button
$(document).on "click", "button[name=ib-options]", ->
  btn = $(this)
  ibid = btn[0].dataset.ibId
  state = btn[0].dataset.state
  optionBox = $("#ib-options-#{ibid}")

  switch state
    when 'hidden'
      optionBox.slideDown()
      btn[0].dataset.state = 'shown'
    when 'shown'
      optionBox.slideUp()
      btn[0].dataset.state = 'hidden'
