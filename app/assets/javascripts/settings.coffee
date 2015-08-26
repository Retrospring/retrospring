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

# theming

previewStyle = document.createElement 'style'
document.head.appendChild previewStyle

previewTimeout = null

previewTheme = ->
  payload = {}

  $('#update_theme').find('.color').each ->
    n = this.name.substr 6, this.name.length - 7
    payload[n] = parseInt this.value.substr(1, 6), 16

  $.post '/settings/theme/preview.css', payload, (data) ->
    previewStyle.innerHTML = data
  , 'text'

  null

themePresets = {
  rs: [0x5E35B1, 0xFFFFFF, 0xFF0039, 0xFFFFFF, 0x3FB618, 0xFFFFFF, 0xFF7518, 0xFFFFFF, 0x9954BB, 0xFFFFFF, 0x222222, 0xEEEEEE, 0xF9F9F9, 0x151515, 0x5E35B1, 0xFFFFFF, 0x222222, 0xbbbbbb],
  dc: [0x222222, 0xeeeeee, 0x222222, 0xeeeeee, 0x222222, 0xeeeeee, 0x222222, 0xeeeeee, 0x222222, 0xeeeeee, 0x222222, 0xeeeeee, 0x222222, 0xeeeeee, 0x111111, 0x555555, 0xeeeeee, 0xbbbbbb],
  lc: [0xdddddd, 0x111111, 0xdddddd, 0x111111, 0xdddddd, 0x111111, 0xdddddd, 0x111111, 0xdddddd, 0x111111, 0xdddddd, 0x111111, 0xdddddd, 0x111111, 0xeeeeee, 0xaaaaaa, 0x111111, 0x444444]
}

$(document).on 'submit', '#update_theme', (event) ->
  $this = $ this
  $this.find('.color').each ->
    this.value = parseInt this.value.substr(1, 6), 16
  true

$(document).ready ->
  $('#update_theme .color').each ->
    $this = $ this
    this.value = '#' + ('000000' + parseInt(this.value).toString(16)).substr(-6, 6)

    $this.minicolors
      control:      'hue'
      defaultValue: this.value
      letterCase:   'lowercase'
      position:     'bottom left'
      theme:        'bootstrap'
      inline:       false
      change:       ->
        clearTimeout previewTimeout
        previewTimeout = setTimeout(previewTheme, 1000)
  true

$(document).on 'click', 'a.theme_preset', (event) ->
  preset = [].concat themePresets[this.dataset.preset]
  $('#update_theme .color').each ->
    $(this).minicolors 'value', '#' + ('000000' + parseInt(preset.shift()).toString(16)).substr(-6, 6)
