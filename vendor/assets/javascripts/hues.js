"use strict";

if(window.Hues == undefined){

var _self;

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

var tower = new DataTower();

var self = (_self = {
  defaults: {
    respack: encodeURIComponent("lol"),
    song: 0,
    hues: "colors"
  },

  beatAnalysisHandle: null,

  /* Values are 0: normal, 1: auto, 2: full auto */
  autoMode: 2,

  /* loaded packs */
  respacks: {},

  /* The currently active list of hues */
  hues: [],
  /* The currently active list of songs */
  songs: [],

  /* Index of the current hue */
  hueIndex: null,
  /* The current hue */
  hue: null,

  /* Index of the currently playing song */
  songIndex: null,
  /* The currently playing song */
  song: null

}, _defineProperty(_self, "beatAnalysisHandle", null), _defineProperty(_self, "beatDuration", null), _defineProperty(_self, "beat", { time: 0, buildup: null, loop: null, loopCount: 0 }), _defineProperty(_self, "beatString", ""), _defineProperty(_self, "loopBeats", 0), _defineProperty(_self, "buildupBeats", 0), _defineProperty(_self, "inverted", false), _defineProperty(_self, "setupPromise", null), _defineProperty(_self, "eventListeners", []), _defineProperty(_self, "setAutoMode", function setAutoMode(autoMode) {
  switch (autoMode) {
    case "normal":
      self.autoMode = 0;break;
    case "auto":
      self.autoMode = 1;break;
    case "full auto":
      self.autoMode = 2;break;
    default:
      throw Error("Unknown auto mode: " + autoMode);
  }
  tower.sendTo("automodechange", autoMode);
}), _defineProperty(_self, "getAutoMode", function getAutoMode() {
  switch (self.autoMode) {
    case 0:
      return "normal";
    case 1:
      return "auto";
    case 2:
      return "full auto";
  }
}), _defineProperty(_self, "randomSong", function randomSong() {
  var songs = self.songs;
  var i;
  if (self.songIndex === null) {
    i = Math.floor(Math.random() * songs.length);
  } else {
    i = Math.floor(Math.random() * (songs.length - 1));
    if (i >= self.songIndex) {
      i += 1;
    }
  }
  changeSong(i);
}), _defineProperty(_self, "getBeatString", function getBeatString() {
  var length = arguments[0];
  if (typeof length === "undefined") {
    length = 256;
  }
  var song = self.song;
  var beatString = "";
  if (song) {
    beatString = self.beatString;
    while (beatString.length < length) {
      beatString += song.rhythm;
    }
  }

  return beatString;
}), _defineProperty(_self, "updateBeatString", function updateBeatString() {
  var song = self.song;
  if (!song) {
    self.beatString = "";
    return;
  }

  var beatString = "";
  var beat = self.beat;

  if (beat.buildup !== null && typeof song.buildupRhythm !== "undefined") {
    /* Currently in buildup */
    beatString += song.buildupRhythm.slice(beat.buildup);
  } else if (beat.loop !== null) {
    beatString += song.rhythm.slice(beat.loop);
  }

  /* Add a copy of the loop rhythm to make sure fades calculate correctly */
  beatString += song.rhythm;

  self.beatString = beatString;
}), _defineProperty(_self, "setupComplete", function setupComplete() {
  return self.setupPromise;
}), _self);

var addHues = function addHues(respackName) {
  var huesList = arguments[1];

  var respack = self["respacks"][respackName];
  if (typeof respack === "undefined") {
    throw Error("Unknown respack: " + respackName);
  };

  var hues = respack["hues"];
  if (typeof hues === "undefined") {
    throw Error("Respack does not contain hues: " + respackName);
  };

  var addHue = function addHue(hue) {
    /* Avoid duplicate hues; skip a hue if it's already in the list */
    var hues = self["hues"];
    var i = hues.indexOf(hue);
    if (i < 0) {
      hues.push(hue);
    }
  };

  if (typeof huesList !== "undefined") {
    huesList.forEach(function (hueIndex) {
      addHue(hues[hueIndex]);
    });
  } else {
    hues.forEach(addHue);
  }
};

var addSongs = function addSongs(respackName) {
  var songsList = arguments[1];

  var respack = self["respacks"][respackName];
  if (typeof respack === "undefined") {
    throw Error("Unknown respack: " + respackName);
  };

  var songs = respack["songs"];
  if (typeof songs === "undefined") {
    throw Error("Respack does not contain songs: " + respackName);
  };

  var addSong = function addSong(song) {
    /* Avoid duplicate songs; skip a song if it's already in the list */
    var songs = self["songs"];
    var i = songs.indexOf(song);
    if (i < 0) {
      songs.push(song);
    }
  };

  if (typeof songsList !== "undefined") {
    songsList.forEach(function (songIndex) {
      addSong(songs[songIndex]);
    });
  } else {
    songs.forEach(addSong);
  }
};

var playSong = function playSong() {
  return changeSong(self["songIndex"]);
};

var prevSong = function prevSong() {
  var i = self["songIndex"];
  i -= 1;
  if (i < 0) {
    i = self["songs"].length - 1;
  }
  return changeSong(i);
};

var nextSong = function nextSong() {
  var i = self["songIndex"];
  i += 1;
  if (i >= self["songs"].length) {
    i = 0;
  }
  return changeSong(i);
};

var addEventListener = function addEventListener(ev, callback) {
  ev = ev.toLowerCase();
  tower.bind(ev, callback);
};

var removeEventListener = function removeEventListener(ev, callback) {
  ev = ev.toLowerCase();
  tower.unbind(ev, callback);
};

/* Load configuration, which is set in a global (window) object */
(function () {
  var song = window.huesConfig.defaultSong;
  if (typeof song !== 'undefined') {
    self.defaults.song = song;
  }

  var autoMode = window.huesConfig["autoMode"];
  if (typeof autoMode !== 'undefined') {
    self.setAutoMode(autoMode);
  }
})();

/* The public object */
var Hues = {
  element: [],
  tower: tower,
  setAutoMode: self.setAutoMode,
  getAutoMode: self.getAutoMode,
  randomSong: self.randomSong,
  getBeatString: self.getBeatString,
  setupComplete: self.setupComplete,
  addHues: addHues,
  addSongs: addSongs,
  playSong: playSong,
  prevSong: prevSong,
  nextSong: nextSong,
  ready: false,
  playing: false
};

var audioCtx = new AudioContext();
var currentBuildupSource = null;
var currentBuildupBuffer = null;
var currentBuildupStartTime = null;
var currentLoopSource = null;
var currentLoopBuffer = null;
var currentLoopStartTime = null;

var gainNode = audioCtx.createGain();
gainNode.connect(audioCtx.destination);

var muted = false;
if (localStorage.getItem('Hues.muted') === "true") {
  muted = true;
}
var savedGain = parseFloat(localStorage.getItem('Hues.gain'));
if (savedGain === null || isNaN(savedGain)) {
  savedGain = -10.0;
}

var clampGain = function clampGain() {
  if (savedGain < -80) {
    savedGain = -80;
  } else if (savedGain > 5) {
    savedGain = 5;
  }
};
var dbToVolume = function dbToVolume(db) {
  return Math.pow(10, db / 20);
};

clampGain();
if (muted) {
  gainNode.gain.value = 0;
} else {
  gainNode.gain.value = dbToVolume(savedGain);
}

addEventListener('volumechange', function (muted, gain) {
  localStorage.setItem('Hues.muted', muted);
  localStorage.setItem('Hues.gain', gain);
});

Hues["respack"] = {};

var setElement = function setElement(newElement, newTarget) {
  Hues.tower.sendTo("changeElement", { elem: newElement, target: newTarget });
  Hues.element[newElement] = newTarget;
};
Hues["setElement"] = setElement;

var isMuted = function isMuted() {
  return muted;
};
Hues["isMuted"] = isMuted;
var getVolume = function getVolume() {
  return savedGain;
};
Hues.getVolume = getVolume;
var mute = function mute() {
  if (!muted) {
    muted = true;
    gainNode.gain.value = 0;
    tower.sendTo('volumechange', muted, savedGain);
  }
};
Hues["mute"] = mute;
var unmute = function unmute() {
  if (muted) {
    muted = false;
    gainNode.gain.value = dbToVolume(savedGain);
    tower.sendTo('volumechange', muted, savedGain);
  }
};
Hues["unmute"] = unmute;

var setVolume = function setVolume(db) {
  savedGain = db;
  clampGain();
  if (!muted) {
    gainNode.gain.value = dbToVolume(savedGain);
  }
  tower.sendTo('volumechange', muted, savedGain);
};
Hues.setVolume = setVolume;

var adjustVolume = function adjustVolume(db) {
  savedGain += db;
  clampGain();
  if (!muted) {
    gainNode.gain.value = dbToVolume(savedGain);
  }
  tower.sendTo('volumechange', muted, savedGain);
};
Hues.adjustVolume = adjustVolume;

var loadBegin = function loadBegin(respack) {
  return new Promise(function (resolve, reject) {
    //I hate promises
    resolve(respack);
  });
};

var loadRespackHues = function loadRespackHues(respack) {
  return new Promise(function (resolve, reject) {
    if (respack["name"] == "colors") {
      fetch(respack["uri"] + "/hues.xml").catch(reject).then(function (response) {

        if (response.status == 404) {
          resolve(respack);
          return;
        }

        if (!response.ok) {
          return;
        }

        response.text().catch(reject).then(function (bodyText) {
          respack["hues"] = [];

          var parser = new DOMParser();
          var doc = parser.parseFromString(bodyText, "application/xml");
          var iterator = doc.evaluate("/hues/hue", doc, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
          var node = iterator.iterateNext();
          while (node) {
            var hue = {};
            hue["name"] = node.getAttribute("name");
            var hex = node.textContent;
            if (!hex[0] == "#") {
              hex = "#" + hex;
            }
            hue["hex"] = hex;

            /* The effects need the hue value as r,g,b floating-point */
            var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
            if (!result) {
              throw Error("Could not parse color value for " + name + ": " + hex);
            }
            hue["rgb"] = [parseInt(result[1], 16) / 255, parseInt(result[2], 16) / 255, parseInt(result[3], 16) / 255];

            respack["hues"].push(hue);

            node = iterator.iterateNext();
          };

          resolve(respack);
        });
      });
    } else {
      resolve(respack);
    }
  });
};

var loadRespackSongTrackFetch = function loadRespackSongTrackFetch(uri) {
  return new Promise(function (resolve, reject) {
    fetch(uri).then(function (response) {
      if (!response.ok) {
        reject(Error("Failed to fetch " + uri + ": " + response.status + " " + response.statusText));
        return;
      }
      resolve(response.arrayBuffer());
    }).catch(reject);
  });
};

var loadRespackSongTrackDecode = function loadRespackSongTrackDecode(buffer) {
  return new Promise(function (resolve, reject) {
    audioCtx.decodeAudioData(buffer, function (audioBuffer) {
      resolve(audioBuffer);
    }, function (error) {
      reject(Error("Could not decode audio: " + error));
    });
  });
};

var loadRespackSongTrack = function loadRespackSongTrack(uri) {
  return new Promise(function (resolve, reject) {
    loadRespackSongTrackFetch(uri + ".ogg").then(loadRespackSongTrackDecode).then(resolve).catch(function (error) {
      tower.sendTo("log", "ogg failed to load: ", error);
    });
  });
};

var loadRespackSongLoop = function loadRespackSongLoop(respack, song) {
  return new Promise(function (resolve, reject) {
    var uri = respack["uri"] + "/Songs/" + encodeURIComponent(song["loop"]);
    loadRespackSongTrack(uri).catch(reject).then(function (audioBuffer) {
      song["loopBuffer"] = audioBuffer;
      resolve(song);
    });
  });
};

var loadRespackSongBuildup = function loadRespackSongBuildup(respack, song) {
  return new Promise(function (resolve, reject) {
    if (!song["buildup"]) {
      resolve(song);
      return;
    }

    var uri = respack["uri"] + "/Songs/" + encodeURIComponent(song["buildup"]);
    loadRespackSongTrack(uri).catch(reject).then(function (audioBuffer) {
      song["buildupBuffer"] = audioBuffer;
      resolve(song);
    });
  });
};

var loadRespackSongMedia = function loadRespackSongMedia(respack, song) {
  var loop = loadRespackSongLoop(respack, song);
  var buildup = loadRespackSongBuildup(respack, song);
  return Promise.all([loop, buildup]).then(function () {
    return Promise.resolve(song);
  });
};

var loadRespackSongs = function loadRespackSongs(respack) {
  return new Promise(function (resolve, reject) {
    if (respack["name"] == "colors") {
      resolve(respack);
    } else {
      fetch(respack["uri"] + "/songs.xml").catch(reject).then(function (response) {

        if (response.status == 404) {
          resolve(respack);
          return;
        }

        if (!response.ok) {
          reject(Error("Could not fetch respack songs.xml: " + response.status + " " + response.statusText));
          return;
        }

        response.text().catch(reject).then(function (bodyText) {
          respack["songs"] = [];
          var songPromises = [];

          var parser = new DOMParser();
          var doc = parser.parseFromString(bodyText, "application/xml");
          var iterator = doc.evaluate("/songs/song", doc, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
          var node = iterator.iterateNext();
          while (node) {
            var song = {};
            song["loop"] = node.getAttribute("name");

            var songIterator = doc.evaluate("*", node, null, XPathResult.UNORDERED_NODE_ITERATOR_TYPE, null);
            var songNode = songIterator.iterateNext();
            while (songNode) {
              song[songNode.localName] = songNode.textContent;
              songNode = songIterator.iterateNext();
            }

            /* Replace U+2011 NON-BREAKING HYPHEN with standard hyphen.
             * For bug compatibility with Xmas respack */
            song.rhythm = song.rhythm.replace(/‑/g, '-');
            if (song.buildupRhythm) {
              song.buildupRhythm = song.buildupRhythm.replace(/‑/g, '-');
            }

            respack["songs"].push(song);
            tower.sendTo("progress", 0, 1);
            songPromises.push(loadRespackSongMedia(respack, song).then(function () {
              tower.sendTo("progress", 1, 0);
            }));

            node = iterator.iterateNext();
          };

          Promise.all(songPromises).then(function () {
            resolve(respack);
          }).catch(reject);
        });
      });
    }
  });
};

var loadRespack = function loadRespack(uri) {
  return new Promise(function (resolve, reject) {
    // Strip a trailing /, since we're going to be generating uris with this
    // as the base.
    var rname = uri;
    if (uri.slice(-1) == "/") {
      uri = uri.slice(0, -1);
    }
    if (uri.indexOf(":") < 0) {
      uri = "https://coderobe.net/data/nanohues/" + uri;
    }
    var respack = {
      "uri": uri,
      "name": rname
    };

    tower.sendTo("log", "Loading respack at " + uri);
    tower.sendTo("progress", 0, 4);

    var respackLoad = loadBegin(respack);

    respackLoad.then(function (respack) {
      tower.sendTo("log", "Loaded respack info for " + respack["name"]);
      tower.sendTo("progress", 1, 0);
    });

    var respackHues = respackLoad.then(loadRespackHues);
    respackHues.then(function (respack) {
      if (respack["hues"]) {
        tower.sendTo("log", "Loaded " + respack["hues"].length + " hues from " + respack["name"]);
      }
      tower.sendTo("progress", 1, 0);
    });

    var respackSongs = respackLoad.then(loadRespackSongs);
    respackSongs.then(function (respack) {
      if (respack["songs"]) {
        tower.sendTo("log", "Loaded " + respack["songs"].length + " songs from " + respack["name"]);
      }
      tower.sendTo("progress", 1, 0);
    });

    Promise.all([respackHues, respackSongs]).catch(reject).then(function () {
      tower.sendTo("log", "All content from respack " + respack["name"] + " has loaded");
      self["respacks"][respack["name"]] = respack;
      resolve(respack);
    });
  });
};
Hues["loadRespack"] = loadRespack;

var initializePromise = null;
Hues.initialize = function (options) {
  if (!initializePromise) {
    initializePromise = new Promise(function (resolve, reject) {
      tower.sendTo("progressstart");

      var builtinPromise = loadRespack("colors");

      var optRespack = options.respack;
      if (typeof optRespack === 'undefined') {
        optRespack = self.defaults.respack;
      }

      var respacks = [].concat(optRespack);
      var respackPromises = [builtinPromise];

      for (var i = 0; i < respacks.length; i++) {
        tower.sendTo("log", "Loading respack " + respacks[i]);
        respackPromises.push(loadRespack(respacks[i]));
      }

      var setupPromise = Promise.all(respackPromises).then(function (respacks) {
        var builtin = respacks.shift();

        var haveHues = false;
        for (var i = 0; i < respacks.length; i++) {
          var respack = respacks[i];
          if (respack.hues) {
            addHues(respack.name);
            haveHues = true;
          }
          if (respack.songs) {
            addSongs(respack.name);
          }
        }

        if (!haveHues) {
          addHues(builtin.name);
        }
        tower.sendTo("log", "Loaded hues:");
        tower.sendTo("log", self["hues"]);
        tower.sendTo("log", "Loaded songs:");
        tower.sendTo("log", self["songs"]);
        /* Preset the selected song */
        var song = options.song;
        if (typeof song === 'undefined') {
          song = 0;
        }
        self.songIndex = song;
        self.song = self.songs[song];

        tower.sendTo("progressend");
      });

      resolve(setupPromise);
    });
  }
  return initializePromise;
};

var stopSong = function stopSong() {
  tower.sendTo("log", "Stopping playback");
  Hues.playing = false;
  tower.sendTo("isPlaying", false);

  if (currentLoopSource) {
    currentLoopSource.stop();
    currentLoopSource.disconnect();
    currentLoopSource = null;
  }
  if (currentLoopBuffer) {
    currentLoopBuffer = null;
  }
  if (currentBuildupSource) {
    currentBuildupSource.stop();
    currentBuildupSource.disconnect();
    currentBuildupSource = null;
  }
  if (currentBuildupBuffer) {
    currentBuildupBuffer = null;
  }

  stopBeatAnalysis();
};
Hues["stopSong"] = stopSong;

var changeSong = function changeSong(songIndex) {
  stopSong();

  Hues.playing = true;
  tower.sendTo("isPlaying", true);

  tower.sendTo("log", "New song index is " + songIndex);
  var song = self["songs"][songIndex];

  tower.sendTo("log", self);
  tower.sendTo("log", song);
  self["songIndex"] = songIndex;
  self["song"] = song;

  tower.sendTo("log", "Switching to " + song["title"]);

  var buildupBuffer = song["buildupBuffer"];
  var buildupDuration = 0;
  var buildupSource = null;
  if (buildupBuffer && buildupBuffer.length > 0) {
    buildupDuration = buildupBuffer.duration;
    buildupSource = audioCtx.createBufferSource();
    buildupSource.buffer = buildupBuffer;
    buildupSource.connect(gainNode);
  }

  var loopBuffer = song["loopBuffer"];
  var loopDuration = loopBuffer.duration;
  var loopSource = audioCtx.createBufferSource();
  loopSource.buffer = loopBuffer;
  loopSource.loop = true;
  loopSource.connect(gainNode);

  var loopBeats = song["rhythm"].length;
  self["loopBeats"] = loopBeats;
  var beatDuration = loopDuration / loopBeats;
  self["beatDuration"] = beatDuration;
  var buildupBeats = Math.round(buildupDuration / beatDuration);
  self["buildupBeats"] = buildupBeats;

  tower.sendTo("log", "Loop duration is " + loopDuration + " (" + song["rhythm"].length + " beats)");
  tower.sendTo("log", "Beat duration is " + beatDuration);
  tower.sendTo("log", "Buildup duration is " + buildupDuration + " (" + buildupBeats + " beats)");

  if (buildupBuffer) {
    /* Songs that have buildups might be missing buildupRhythm, or
     * have it too short. Fix that by padding it. */
    if (typeof song["buildupRhythm"] !== "undefined") {
      var buildupDelta = Math.round(buildupDuration / beatDuration) - song["buildupRhythm"].length;
      if (buildupDelta > 0) {
        song["buildupRhythm"] += ".".repeat(buildupDelta);
      }
    } else {
      song["buildupRhythm"] = ".".repeat(Math.round(buildupDuration / beatDuration));
    }
  }

  if (buildupSource) {
    currentBuildupSource = buildupSource;
    currentBuildupBuffer = buildupBuffer;
  }
  currentLoopSource = loopSource;
  currentLoopBuffer = loopBuffer;

  var loopStart;
  var buildupStart;

  var startPlayback = function startPlayback() {
    buildupStart = audioCtx.currentTime;
    loopStart = buildupStart + buildupDuration;
    if (buildupSource) {
      buildupSource.start(buildupStart);
    }
    loopSource.start(loopStart);

    currentBuildupStartTime = buildupStart;
    currentLoopStartTime = loopStart;

    self.updateBeatString();
    startBeatAnalysis();

    tower.sendTo("songchange", song, loopStart, buildupStart, beatDuration);
    self.inverted = false;
    tower.sendTo("inverteffect", audioCtx.currenTime, self.inverted);
  };

  var suspend = Promise.resolve();
  if (audioCtx.suspend && audioCtx.resume) {
    suspend = audioCtx.suspend();
  }

  var playback = suspend.then(startPlayback);

  var resume;
  if (audioCtx.suspend && audioCtx.resume) {
    resume = playback.then(function () {
      return audioCtx.resume();
    });
  } else {
    resume = playback;
  }

  return resume.then(function () {
    return song;
  });
};
Hues["changeSong"] = changeSong;

var getCurrentSong = function getCurrentSong() {
  return self["song"];
};
Hues["getCurrentSong"] = getCurrentSong;

var getCurrentHue = function getCurrentHue() {
  var index = self["hueIndex"];
  var hue = self["hue"];
  return { "index": index, "hue": hue };
};
Hues["getCurrentHue"] = getCurrentHue;

var changeHue = function changeHue(hueIndex) {
  var hues = self.hues;
  if (hueIndex < 0) {
    hueIndex = 0;
  }
  if (hueIndex >= hues.length) {
    hueIndex = hues.length - 1;
  }
  var hue = hues[hueIndex];
  self.hueIndex = hueIndex;
  self.hue = hue;
  tower.sendTo("huechange", { "index": hueIndex, "hue": hue });
};

var randomHue = function randomHue() {
  var hues = self["hues"];
  var index = self["hueIndex"];
  var newIndex;
  if (index === null) {
    newIndex = Math.floor(Math.random() * hues.length);
  } else {
    newIndex = Math.floor(Math.random() * (hues.length - 1));
    if (newIndex >= index) {
      newIndex += 1;
    }
  }
  changeHue(newIndex);
};

tower.bind("huechange", function (data) {
  var color = data.hue;
  if (Hues.element.colorValue) {
    Hues.element.colorValue.attr("style", "background: " + color.hex + " !important;");
  }
  if (Hues.element.colorName) {
    Hues.element.colorName.innerHTML = color.name+"spring";
  }
});

var doBeatEffect = function doBeatEffect() {
  var beatString = self.beatString;
  if (beatString == "") {
    return;
  }

  var beat = self.beat;
  var current = beatString[0];
  var rest = beatString.slice(1);

  /* . is the null character, no effect. */
  if (current == ".") {
    return;
  }

  /* beat effects:
   *
   * "x": Vertical blur (snare)
   *   Changes color.
   * "o": Horizontal blur (bass)
   *   Changes color.
   * "-": No blur
   *   Changes color.
   * "+": Blackout
   *   Blackout lasts until the next non-null effect.
   *   Blackout fades in over the course of ~2 frames in the flash
   *   (+0.4 alpha per frame), this works out to be about 40ms at 60fps.
   *   There's no fade-out, the blackout ends instantly.
   * "|": Short blackout
   *   A blackout that only covers part of a single beat.
   *   It has the same fade-in and lack of fade-out as standard blackout.
   *   The length of the blackout is 1/1.7 of the beat length.
   * ":": Color only
   * "*": Same as :
   * "X": Vertical blur only
   * "O": Horizontal blur only
   * "~": Fade color
   *   Color change only.
   *   Instead of being immediate, the color is faded from the previous
   *   to new color.
   *   The duration of the fade is until the start of the next non-null
   *   effect.
   * "=": Fade
   *   Same as "~"
   *   effect).
   * "i": Invert all colors
   *   Toggles between normal and inverted states.
   * "I": Invert
   * "¤": Whiteout (undocumented effect)
   *   Same as +, but with white rather than black. All the timers, etc.,
   *   are shared with blackout.
   */

  /* Effects that cause vertical blur */
  if (current == "x" || current == "X") {
    tower.sendTo("verticalblureffect", beat.time);
  }

  /* Effects that cause horizontal blur */
  if (current == "o" || current == "O" || current == "+") {
    tower.sendTo("horizontalblureffect", beat.time);
  }

  /* Effects that cause color change */
  if (current == "x" || current == "o" || current == "-" /* || current == ":"*/) {
      randomHue();
    }

  if (current == "+" || current == "|") {
    changeHue(0x00);
  }

  if (current == "¤") {
    changeHue(0x01);
  }

  /* Invert toggle */
  if (current == "i" || current == "I") {
    self.inverted = !self.inverted;
    tower.sendTo("inverteffect", beat.time, self.inverted);
  }
};

var beatAnalyze = function beatAnalyze() {
  if (!currentLoopBuffer) {
    stopBeatAnalysis();
    return;
  }

  var time = audioCtx.currentTime;
  var song = self.song;
  var beat = self.beat;
  var beatDuration = self.beatDuration;

  var loopCount = 0;
  if (time >= currentLoopStartTime) {
    loopCount = Math.floor((time - currentLoopStartTime) / currentLoopBuffer.duration);
  }

  if (beat.buildup === null && beat.loop === null) {
    // We haven't played the first beat of the song yet, so initialize
    // for looping...
    if (typeof song.buildupRhythm !== "undefined") {
      beat.buildup = -1;
    } else {
      beat.loop = -1;
    }
    beat.time = 0;
    beat.loopCount = 0;

    tower.sendTo("log", "build start", currentBuildupStartTime, "loop start", currentLoopStartTime);
  }

  var doBeatActions = function doBeatActions() {
    self.beat = beat;
    self.updateBeatString();

    doBeatEffect();

    tower.sendTo("beat", beat);
  };

  if (beat.buildup !== null) {
    var nextBeat = { buildup: beat.buildup + 1, loop: null, loopCount: 0 };
    nextBeat.time = currentLoopStartTime - (self.buildupBeats - nextBeat.buildup) * beatDuration;

    while (nextBeat.time < time && nextBeat.buildup < self.buildupBeats) {
      beat = nextBeat;

      doBeatActions();

      nextBeat = {
        buildup: beat.buildup + 1,
        loop: null,
        loopCount: beat.loopCount
      };
      nextBeat.time = currentLoopStartTime - (self.buildupBeats - nextBeat.buildup) * beatDuration;
    }
  }

  if (beat.buildup == self.buildupBeats - 1) {
    // Transition from buildup to loop
    beat.buildup = null;
    beat.loop = -1;
  }

  if (beat.loop !== null) {
    var nextBeat = {
      buildup: null,
      loop: beat.loop + 1,
      loopCount: beat.loopCount
    };
    nextBeat.time = currentLoopStartTime + nextBeat.loopCount * currentLoopBuffer.duration + nextBeat.loop * beatDuration;

    while (nextBeat.time < time) {
      beat = nextBeat;

      doBeatActions();

      if (beat.loop == self.loopBeats - 1) {
        beat.loop = -1;
        beat.loopCount = beat.loopCount + 1;
        tower.sendTo("log", "loop count now", beat.loopCount);
      }

      nextBeat = {
        buildup: null,
        loop: beat.loop + 1,
        loopCount: beat.loopCount
      };
      nextBeat.time = currentLoopStartTime + nextBeat.loopCount * currentLoopBuffer.duration + nextBeat.loop * beatDuration;
    }
  }

  tower.sendTo("frame", time);
  self["beatAnalysisHandle"] = window.requestAnimationFrame(beatAnalyze);
};

var startBeatAnalysis = function startBeatAnalysis() {
  if (self["beatAnalysisHandle"] === null) {
    tower.sendTo("log", "Starting beat analysis");
    self["beatAnalysisHandle"] = window.requestAnimationFrame(beatAnalyze);
  }
};

var stopBeatAnalysis = function stopBeatAnalysis() {
  tower.sendTo("log", "Stopping beat analysis");
  var handle = self["beatAnalysisHandle"];
  if (handle !== null) {
    window.cancelAnimationFrame(self["beatAnalysisHandle"]);
    self["beatAnalysisHandle"] = null;
  }
  var beat = { "buildup": null, "loop": null };
  self["beat"] = beat;
  tower.sendTo("beat", beat);
};

Hues.tower.bind("progressend", function () {
  Hues.ready = true;
});

window.Hues = Hues;

}