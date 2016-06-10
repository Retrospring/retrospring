var HuesLogFunc = function(){
  console.log("ayy lmao")
  /*
  let args = Array.prototype.slice.call(arguments)
  args.unshift("[nanohues]")
  console.log.apply(console, args)
  */
}

$(function(){
  var HuesHasAlreadyLoadedOhMyGodTurbolinksIsHorrible = false
  for(var streamnum in window.Hues.tower.streams){
    var stream = window.Hues.tower.streams[streamnum]
    if(stream.name == "log"){
      for(var fnum in stream.faucets){
        var ffunc = stream.faucets[fnum]
        if(ffunc == HuesLogFunc)
          HuesHasAlreadyLoadedOhMyGodTurbolinksIsHorrible = true
      }
    }
  }
  if(!HuesHasAlreadyLoadedOhMyGodTurbolinksIsHorrible){
    Hues.tower.bind("log", HuesLogFunc)
    Hues.tower.bind("progressend", function(){
      Hues.setVolume(-5)
      console.log("loading finished")
      Hues.playSong()
    })
    /*Hues.tower.bind("songchange", function(track){
      $("#element").html(track.title)
    })*/

    Hues.initialize({})
  }

  Hues.setElement("colorName", $(".navbar-brand:first")[0])
  Hues.setElement("colorValue", $("body"))
})