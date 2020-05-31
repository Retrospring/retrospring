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
          ($ '#profile_picture_x').val Math.floor(data.x / data.scale)
          ($ '#profile_picture_y').val Math.floor(data.y / data.scale)
          ($ '#profile_picture_w').val Math.floor(data.w / data.scale)
          ($ '#profile_picture_h').val Math.floor(data.h / data.scale)
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
          ($ '#profile_header_x').val Math.floor(data.x / data.scale)
          ($ '#profile_header_y').val Math.floor(data.y / data.scale)
          ($ '#profile_header_w').val Math.floor(data.w / data.scale)
          ($ '#profile_header_h').val Math.floor(data.h / data.scale)

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

previewStyle = null

$(document).ready ->
  previewStyle = document.createElement 'style'
  document.body.appendChild previewStyle

  previewTimeout = null

  $('#update_theme .color').each ->
    $this = $ this
    this.value = '#' + getHexColorFromThemeValue(this.value)

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
    $(this).minicolors 'value', '#' + getHexColorFromThemeValue(preset.shift())

previewTheme = ->
  payload = {}

  $('#update_theme').find('.color').each ->
    n = this.name.substr 6, this.name.length - 7
    payload[n] = parseInt this.value.substr(1, 6), 16

  generateTheme payload

  null

generateTheme = (payload) ->
  theme_attribute_map = {
    'primary_color': 'primary',
    'primary_text': 'primary-text',
    'danger_color': 'danger',
    'danger_text': 'danger-text',
    'warning_color': 'warning',
    'warning_text': 'warning-text',
    'info_color': 'info',
    'info_text': 'info-text',
    'success_color': 'success',
    'success_text': 'success-text',
    'dark_color': 'dark',
    'dark_text': 'dark-text',
    'light_color': 'light',
    'light_text': 'light-text',
    'raised_background': 'raised-bg',
    'raised_accent': 'raised-accent',
    'background_color': 'background',
    'body_text': 'body-text',
    'input_color': 'input-bg',
    'input_text': 'input-text',
    'muted_text': 'muted-text'
  }

  body = ":root {\n"

  (Object.keys(payload)).forEach (plKey) ->
    if theme_attribute_map[plKey]
      if theme_attribute_map[plKey].includes 'text'
        hex = getHexColorFromThemeValue(payload[plKey])
        body += "--#{theme_attribute_map[plKey]}: #{getDecimalTripletsFromHex(hex)};\n"
      else
        body += "--#{theme_attribute_map[plKey]}: ##{getHexColorFromThemeValue(payload[plKey])};\n"

  body += "}"

  previewStyle.innerHTML = body

getHexColorFromThemeValue = (themeValue) ->
  return ('000000' + parseInt(themeValue).toString(16)).substr(-6, 6)

getDecimalTripletsFromHex = (hex) ->
  return hex.match(/.{1,2}/g).map((value) -> parseInt(value, 16)).join(', ')

themePresets = {
  rs: [0x5E35B1, 0xFFFFFF, 0xFF0039, 0xFFFFFF, 0x3FB618, 0xFFFFFF, 0xFF7518, 0xFFFFFF, 0x9954BB, 0xFFFFFF, 0x222222, 0xEEEEEE, 0xF9F9F9, 0x151515, 0x5E35B1, 0xFFFFFF, 0x222222, 0xbbbbbb, 0xFFFFFF, 0x000000, 0x5E35B1],
  dc: [0x141414, 0xeeeeee, 0x362222, 0xeeeeee, 0x1d2e1d, 0xeeeeee, 0x404040, 0xeeeeee, 0xb8b8b8, 0x3b3b3b, 0x303030, 0xEEEEEE, 0x202020, 0xeeeeee, 0x9c9a9a, 0x363636, 0xe6e6e6, 0xbbbbbb, 0x383838, 0xebebeb, 0x787676],
  lc: [0xebebeb, 0x111111, 0xf76363, 0x111111, 0x8aff94, 0x111111, 0xffbd7f, 0x111111, 0x474747, 0xc4c4c4, 0xcfcfcf, 0x111111, 0xdfdfdf, 0x111111, 0x636565, 0xc9c9c9, 0x191919, 0x444444, 0xc7c7c7, 0x141414, 0x878989]
}

$(document).on 'submit', '#update_theme', (event) ->
  $this = $ this
  $this.find('.color').each ->
    this.value = parseInt this.value.substr(1, 6), 16
  true
