import 'core-js/stable'
import 'regenerator-runtime/runtime'

import '../legacy/jquery'
import 'popper.js'
import 'bootstrap'
import 'particleground/jquery.particleground.min'

import '../legacy/pagination'
import '../legacy/util'

_ready = ->
  $('[data-toggle="tooltip"]').tooltip()
  $('.dropdown-toggle').dropdown()

  if document.getElementById('particles')?
    jumbo         = $ '.j2-jumbo'
    bodyColorOrig = jumbo.css 'background-color'
    bodyColor     = doppler 0.25, bodyColorOrig
    console.log bodyColor, bodyColorOrig
    particleground document.getElementById('particles'),
      dotColor: bodyColor
      lineColor: bodyColor
      density: 23000

$(document).ready _ready
$(document).on 'turbolinks:load', _ready