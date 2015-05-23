($ document).on 'submit', 'form.mogrify_doorkeeper_application', (ev) ->
  # ev.preventDefault()
  scopes = ["public"]
  ($ this).find("[name=\"scopes\"]").each ->
    if this.checked
      scopes.push this.value
  ($ "[name=\"doorkeeper_application[scopes]\"]").val(scopes.join " ")


($ document).on 'click', '#delete_oauth_app_btn', (ev) ->
  ev.preventDefault()
  swal
    title: "Really delete your app?"
    text: "It will be really gone!"
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: "Delete"
    closeOnConfirm: true
  , =>
    this.parentElement.submit()

($ document).on 'click', '#delete_oautherization_btn', (ev) ->
  ev.preventDefault()
  swal
    title: "Really revoke app permissions?"
    text: "The app won't be able to perform tasks under your behalf."
    type: "warning"
    showCancelButton: true
    confirmButtonColor: "#DD6B55"
    confirmButtonText: "Delete"
    closeOnConfirm: true
  , =>
    this.parentElement.submit()

readImage = (file, callback) ->
  fr = new FileReader()
  fr.addEventListener "load", (e) ->
    callback e.target.result
  fr.readAsBinaryString file

freeURL = () ->

if window.URL? or window.webkitURL?
  readImage = (file, callback) ->
    callback (window.URL || window.webkitURL).createObjectURL file
  freeURL = (url) ->
    URL.revokeObjectURL url

($ document).on 'change', 'input#doorkeeper_application_icon[type=file]', ->
  input = this

  ($ '#app-icon-crop-controls').slideUp 400, ->
    if input.files and input.files[0]
      readImage input.files[0], (src) ->
        cropper = ($ '#app-icon-cropper')
        preview = ($ '#app-icon-preview')

        updateVars = (data, action) ->
          ($ '#crop_x').val Math.floor(data.x / data.scale)
          ($ '#crop_y').val Math.floor(data.y / data.scale)
          ($ '#crop_w').val Math.floor(data.w / data.scale)
          ($ '#crop_h').val Math.floor(data.h / data.scale)

        cropper.on 'load', ->
          if ({}.toString).call(src) == "[object URL]"
            freeURL src

          side = if cropper[0].naturalWidth > cropper[0].naturalHeight
            cropper[0].naturalHeight
          else
            cropper[0].naturalWidth

          cropper.guillotine
            width: side
            height: side
            onChange: updateVars

          updateVars cropper.guillotine('getData'), 'drag' # just because

          unless ($ '#app-icon-crop-controls')[0].dataset.bound?
            ($ '#cropper-zoom-out').click -> cropper.guillotine 'zoomOut'
            ($ '#cropper-zoom-in').click -> cropper.guillotine 'zoomIn'
            ($ '#app-icon-crop-controls')[0].dataset.bound = true
          ($ '#app-icon-crop-controls').slideDown()

        cropper.attr 'src', src
