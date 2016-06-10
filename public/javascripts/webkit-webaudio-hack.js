if (!String.prototype.repeat) {
  String.prototype.repeat = function(count) {
    'use strict';
    if (this == null) {
      throw new TypeError('can\'t convert ' + this + ' to object');
    }
    var str = '' + this;
    count = +count;
    if (count != count) {
      count = 0;
    }
    if (count < 0) {
      throw new RangeError('repeat count must be non-negative');
    }
    if (count == Infinity) {
      throw new RangeError('repeat count must be less than infinity');
    }
    count = Math.floor(count);
    if (str.length == 0 || count == 0) {
      return '';
    }
    // Ensuring count is a 31-bit integer allows us to heavily optimize the
    // main part. But anyway, most current (August 2014) browsers can't handle
    // strings 1 << 28 chars or longer, so:
    if (str.length * count >= 1 << 28) {
      throw new RangeError('repeat count must not overflow maximum string size');
    }
    var rpt = '';
    for (;;) {
      if ((count & 1) == 1) {
        rpt += str;
      }
      count >>>= 1;
      if (count == 0) {
        break;
      }
      str += str;
    }
    return rpt;
  }
}
if (typeof(window.AudioContext) === 'undefined' &&
    typeof(window.webkitAudioContext) !== 'undefined') {
  window.AudioContext = window.webkitAudioContext
  if (typeof(window.AudioContext.prototype.createGain) === 'undefined' &&
      typeof(window.AudioContext.prototype.createGainNode) !== 'undefined') {
    window.AudioContext.prototype.createGain =
      window.audioContext.prototype.createGainNode
  }
  if (typeof(window.AudioContext.prototype.hack_createBufferSource) ===
      'undefined') {
    window.AudioContext.prototype._hack_createBufferSource =
      window.AudioContext.prototype.createBufferSource
    window.AudioContext.prototype.createBufferSource = function() {
      var node = this.hack_createBufferSource()
      if (typeof(node.start) === 'undefined') {
        // This doesn't permit the 2-argument start method.
        node.start = node.noteOn
      }
      if (typeof(node.stop) === 'undefined') {
        node.stop = node.noteOff
      }
      return node
    }
  }
}
