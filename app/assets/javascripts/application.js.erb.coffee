#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require bootstrap
#= require bootstrap-material-design
#= require nprogress
#= require nprogress-turbolinks
#= require_tree .

NProgress.configure
  showSpinner: false

showSnackbar = (text) ->
  $.snackbar # allahu snackbar
    content: data.message
    style: "snackbar"
    timeout: 5000

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
        showSnackbar data.message
      else
        console.log data, status, jqxhr
        showSnackbar "An error occurred, a developer should check the console for details"
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showSnackbar "An error occurred, a developer should check the console for details"
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
        showSnackbar data.message
      else
        console.log data, status, jqxhr
        showSnackbar "An error occurred, a developer should check the console for details"
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      showSnackbar "An error occurred, a developer should check the console for details"
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=ib-answer][data-id=#{iid}]").removeAttr "readonly"

$(document).on "click", "button#create-account", ->
  Turbolinks.visit "/sign_up"

$(document).on "click", "button#new-question", ->
  $("div#question-box").show()
  $("div#question-box-promote").hide()
