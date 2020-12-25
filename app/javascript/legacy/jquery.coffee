# HACK: Can't believe I have to do this, but this is a workaround 
# as long as we have to deal with all the legacy code
#
# We're going to set up a global jQuery instance here and configure it
# with all our plugins because with newfangled bundling the old approach
# and especially jQuery doesn't really work out

import jQuery from 'jquery'
window.$ = window.jQuery = jQuery