# see GitHub issue #11
($ document).on "submit", "form#edit_user", (evt) ->
  if ($ "input#user_current_password").val().length == 0
    evt.preventDefault()
    $("button[data-target=#modal-passwd]").trigger 'click'


# Profile pic
($ document).on 'change', 'input#user_profile_picture[type=file]', ->
  input = ($ this)[0]

  ($ '#profile-picture-crop-controls').slideUp 400, ->
    if input.files and input.files[0]
      fr = new FileReader()
      ($ fr).on 'load', (e) ->
        cropper = ($ '#profile-picture-cropper')
        preview = ($ '#profile-picture-preview')

        cropper.on 'load', ->
          side = if cropper[0].naturalWidth > cropper[0].naturalHeight
            cropper[0].naturalHeight
          else
            cropper[0].naturalWidth

          cropper.guillotine
            width: side
            height: side
            onChange: (data, action) ->
              console.log data
              ($ '#crop_x').val Math.floor(data.x)
              ($ '#crop_y').val Math.floor(data.y)
              ($ '#crop_w').val Math.floor(data.w)
              ($ '#crop_h').val Math.floor(data.h)
#              rx = 100 / data.w
#              ry = 100 / data.h
#              ($ '#profile-picture-preview').css
#                width: Math.round(rx * preview[0].naturalWidth) + 'px'
#                height: Math.round(ry * preview[0].naturalHeight) + 'px'
#                marginLeft: '-' + Math.round(rx * data.x) + 'px'
#                marginTop: '-' + Math.round(ry * data.y) + 'px'

          ($ '#cropper-zoom-out').click -> cropper.guillotine 'zoomOut'
          ($ '#cropper-zoom-in').click -> cropper.guillotine 'zoomIn'
          ($ '#profile-picture-crop-controls').slideDown()

        cropper.attr 'src', e.target.result

    fr.readAsDataURL(input.files[0])