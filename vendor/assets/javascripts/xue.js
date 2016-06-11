/**
 * jQuery snow effects.
 *
 * This is a heavily modified, jQuery-adapted, browser-agnostic version of 
 * "Snow Effect Script" by Altan d.o.o. (http://www.altan.hr/snow/index.html).
 *
 * Dustin Oprea (2011)
 */

function __ShowSnow(settings)
{

    var snowsrc = settings.SnowImages;
    var no = settings.Quantity;

    var dx, xp, yp;    // coordinate and position variables
    var am, stx, sty;  // amplitude and step variables
    var i; 

    var doc_width = $(window).width() - 10;
    var doc_height = $(window).height();

    dx = [];
    xp = [];
    yp = [];
    am = [];
    stx = [];
    sty = [];
    flakes = [];
    for (i = 0; i < no; ++i) 
    {
        dx[i] = 0;                        // set coordinate variables
        xp[i] = Math.random()*(doc_width-50);  // set position variables
        yp[i] = Math.random()*doc_height;
        am[i] = Math.random()*20;         // set amplitude variables
        stx[i] = 0.02 + Math.random()/10; // set step variables
        sty[i] = 0.7 + Math.random();     // set step variables

        var flake = $("<div />");

        var id = ("dot" + i);
        var z = i + 100;
        flake.attr("id", id);
        flake.css({
                    position: "absolute",
                    zIndex: z,
                    top: "15px",
                    left: "15px"
                });

        flake.append("<img class='degenerate' src='" + getRandomSnowImage(snowsrc) + "'>");
        flake.appendTo("body");

        flakes[i] = $("#" + id);
    }

    var animateSnow;
    animateSnow = function() 
    {  
        for (i = 0; i < no; ++ i) 
        {
            // iterate for every dot
            yp[i] += sty[i];
            if (yp[i] > doc_height - 50) 
            {
                xp[i] = Math.random() * (doc_width - am[i] - 30);
                yp[i] = 0;
                stx[i] = 0.02 + Math.random() / 10;
                sty[i] = 0.7 + Math.random();
            }
      
            dx[i] += stx[i];
            flakes[i].css("top", yp[i] + "px");
            flakes[i].css("left", (xp[i] + am[i] * Math.sin(dx[i])) + "px");
        }

        snowtimer = setTimeout(animateSnow, 10);
    };

	function hidesnow()
    {
		if(window.snowtimer)
            clearTimeout(snowtimer)

        for (i = 0; i < no; i++)
            flakes[i].hide();
	}
		
    animateSnow();
	if (settings.HideSnowTime > 0)
    	setTimeout(hidesnow, settings.HideSnowTime * 1000)

    function getRandomSnowImage(imgs) {
        return imgs[Math.floor(Math.random()*imgs.length)];
    }
}

(function($) {
    $.fn.snow = function(options) {
  
    var settings = $.extend({
            SnowImages:     ["/images/sure_fam.png", "/images/ok.png"],
            Quantity:       7,
            HideSnowTime:   0
        }, options);

    __ShowSnow(settings);

    return this;
  }

})(jQuery);

function makeItSnow() {
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
        if(!HuesHasAlreadyLoadedOhMyGodTurbolinksIsHorrible) {
            $(document).snow()
            $('.degenerate').click(function () {
                Hues.nextSong()
            })
        }
    });
}
