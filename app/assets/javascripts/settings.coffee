# see GitHub issue #11
($ document).on "submit", "form#edit_user", (evt) ->
  if ($ "input#user_current_password").val().length == 0
    evt.preventDefault()
    $("button[data-target=#modal-passwd]").trigger 'click'


# Profile pic
($ document).on 'change', 'input#user_profile_picture[type=file]', ->
  input = ($ this)[0]

  ($ '#profile-picture-crop-controls').slideUp()

  if input.files and input.files[0]
    fr = new FileReader()
    ($ fr).on 'load', (e) ->
      cropper = ($ '#profile-picture-cropper')
      preview = ($ '#profile-picture-preview')
      ($ '.jcrop-holder').remove()
      jcrop = $.Jcrop('#profile-picture-cropper')

      preview.on 'load', ->
        jcrop.setImage e.target.result, ->
          side = if preview[0].naturalWidth > preview[0].naturalHeight
            preview[0].naturalHeight
          else
            preview[0].naturalWidth
          console.log side

          jcrop.setOptions
            onChange: showPreview
            onSelect: showPreview
            aspectRatio: 1
            setSelect: [ 0, 0, side, side ]
            allowSelect: false

          ($ '#profile-picture-crop-controls').slideDown()

      preview.fadeOut 400, ->
        ($ this).attr('src', e.target.result)
        ($ this).fadeIn 400

      showPreview = (coords) ->
        rx = 100 / coords.w
        ry = 100 / coords.h
        ($ '#profile-picture-preview').css
          width: Math.round(rx * preview[0].naturalWidth) + 'px'
          height: Math.round(ry * preview[0].naturalHeight) + 'px'
          marginLeft: '-' + Math.round(rx * coords.x) + 'px'
          marginTop: '-' + Math.round(ry * coords.y) + 'px'
          ($ '#crop_x').val Math.floor(coords.x)
          ($ '#crop_y').val Math.floor(coords.y)
          ($ '#crop_w').val Math.floor(coords.w)
          ($ '#crop_h').val Math.floor(coords.h)

  fr.readAsDataURL(input.files[0])