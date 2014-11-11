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
        $.snackbar # allahu snackbar
          content: data.message
          style: "snackbar"
          timeout: 5000
      else
        console.log data, status, jqxhr
        $.snackbar # allahu snackbar
          content: "An error occurred, a developer should check the console for details"
          style: "snackbar"
          timeout: 5000
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      $.snackbar # allahu snackbar
        content: "An error occurred, a developer should check the console for details"
        style: "snackbar"
        timeout: 5000
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=qb-question]").removeAttr "readonly"

$(document).on "click", "button[name=ib-answer]", ->
  btn = $(this)
  btn.button "loading"
  iid = $("input[name=ib-id]").val()
  $.ajax
    url: '/ajax/inbox' # TODO: find a way to use rake routes instead of hardcoding them here
    type: 'POST'
    data:
      id: iid
      answer: $("textarea[name=ib-answer]").val()
    success: (data, status, jqxhr) ->
      if data.success
        $("div#inbox-box[data-id=#{iid}]").val ''
        $("div#inbox-box").slideUp()
        $.snackbar # allahu snackbar
          content: data.message
          style: "snackbar"
          timeout: 5000
      else
        console.log data, status, jqxhr
        $.snackbar # allahu snackbar
          content: "An error occurred, a developer should check the console for details"
          style: "snackbar"
          timeout: 5000
    error: (jqxhr, status, error) ->
      console.log jqxhr, status, error
      $.snackbar # allahu snackbar
        content: "An error occurred, a developer should check the console for details"
        style: "snackbar"
        timeout: 5000
    complete: (jqxhr, status) ->
      btn.button "reset"
      $("textarea[name=qb-question]").removeAttr "readonly"

$(document).on "click", "button#create-account", ->
  Turbolinks.visit "/sign_up"

$(document).on "click", "button#new-question", ->
  $("div#question-box").show()
  $("div#question-box-promote").hide()
