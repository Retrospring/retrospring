import 'core-js/stable'
import 'regenerator-runtime/runtime'

import '../legacy/jquery'
import 'popper.js'
import 'bootstrap'

import '../legacy/pagination'

_ready = ->
  $('[data-toggle="tooltip"]').tooltip()
  $('.dropdown-toggle').dropdown()

$(document).ready _ready
$(document).on 'turbolinks:load', _ready