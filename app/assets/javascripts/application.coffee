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
  console.log "some AJAX magic should happen here!"
  btn.button "reset"
  $("textarea[name=qb-question]").removeAttr "readonly"
  if true # data.success
    $("textarea[name=qb-question]").val ''
    if promote
      $("div#question-box").hide()
      $("div#question-box-promote").show()
    else
      $.snackbar # allahu snackbar
        content: "Successfully asked question"
        style: "snackbar"
        timeout: 5000

$(document).on "click", "button#create-account", ->
  Turbolinks.visit "/sign_up"

$(document).on "click", "button#new-question", ->
  $("div#question-box").show()
  $("div#question-box-promote").hide()
