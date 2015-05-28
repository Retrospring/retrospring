# see GitHub issue #11
($ document).on "submit", "form#edit_user", (evt) ->
  if ($ "input#user_current_password").val().length == 0
    evt.preventDefault()
    $("button[data-target=#modal-passwd]").trigger 'click'

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


# Profile pic
($ document).on 'change', 'input#user_profile_picture[type=file]', ->
  input = this

  ($ '#profile-picture-crop-controls').slideUp 400, ->
    if input.files and input.files[0]
      readImage input.files[0], (src) ->
        cropper = ($ '#profile-picture-cropper')
        preview = ($ '#profile-picture-preview')

        updateVars = (data, action) ->
          ($ '#crop_x').val Math.floor(data.x / data.scale)
          ($ '#crop_y').val Math.floor(data.y / data.scale)
          ($ '#crop_w').val Math.floor(data.w / data.scale)
          ($ '#crop_h').val Math.floor(data.h / data.scale)
#          rx = 100 / data.w
#          ry = 100 / data.h
#          ($ '#profile-picture-preview').css
#            width: Math.round(rx * preview[0].naturalWidth) + 'px'
#            height: Math.round(ry * preview[0].naturalHeight) + 'px'
#            marginLeft: '-' + Math.round(rx * data.x) + 'px'
#            marginTop: '-' + Math.round(ry * data.y) + 'px'

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

          unless ($ '#profile-picture-crop-controls')[0].dataset.bound?
            ($ '#cropper-zoom-out').click -> cropper.guillotine 'zoomOut'
            ($ '#cropper-zoom-in').click -> cropper.guillotine 'zoomIn'
            ($ '#profile-picture-crop-controls')[0].dataset.bound = true
          ($ '#profile-picture-crop-controls').slideDown()

        cropper.attr 'src', src

($ document).on 'change', 'input#user_profile_header[type=file]', ->
  input = this

  ($ '#profile-header-crop-controls').slideUp 400, ->
    if input.files and input.files[0]
      readImage input.files[0], (src) ->
        cropper = ($ '#profile-header-cropper')
        preview = ($ '#profile-header-preview')

        updateVars = (data, action) ->
          ($ '#crop_h_x').val Math.floor(data.x / data.scale)
          ($ '#crop_h_y').val Math.floor(data.y / data.scale)
          ($ '#crop_h_w').val Math.floor(data.w / data.scale)
          ($ '#crop_h_h').val Math.floor(data.h / data.scale)

        cropper.on 'load', ->
          if ({}.toString).call(src) == "[object URL]"
            freeURL src

          cropper.guillotine
            width: 1500
            height: 350
            onChange: updateVars

          updateVars cropper.guillotine('getData'), 'drag'

          unless ($ '#profile-header-crop-controls')[0].dataset.bound?
            ($ '#cropper-header-zoom-out').click -> cropper.guillotine 'zoomOut'
            ($ '#cropper-header-zoom-in').click -> cropper.guillotine 'zoomIn'
            ($ '#profile-header-crop-controls')[0].dataset.bound = true
          ($ '#profile-header-crop-controls').slideDown()

        cropper.attr 'src', src
