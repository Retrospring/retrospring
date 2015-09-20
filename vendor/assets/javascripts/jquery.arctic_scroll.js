(function ($) {
    $.fn.arctic_scroll = function (options) {

        var defaults = {
            elem: $(this),
            speed: 500,
            scroll_selector: 'html,body'
        };
        
        var options = $.extend(defaults, options),
            to_scroll = options.scroll_selector,
            ua = $.browser;
        /*
        if ( ua.msie && ua.version.slice(0,1) == "8" ) {
            to_scroll = window;
        } else if ( ua.msie && ua.version.slice(0,1) == "7" ) {
            to_scroll = window;
        }
        */
        options.elem.click(function(event){     
            event.preventDefault();
            var offset = ($(this).attr('data-offset')) ? $(this).attr('data-offset') : false,
                position = ($(this).attr('data-position')) ? $(this).attr('data-position') : false;         
            if (offset) {
                var toMove = parseInt(offset);
                $(options.scroll_selector).stop(true, false).animate({scrollTop: ($(this.hash).offset().top + toMove) }, options.speed);
            } else if (position) {
                var toMove = parseInt(position);
                $(options.scroll_selector).stop(true, false).animate({scrollTop: toMove }, options.speed);
            } else {
                $(options.scroll_selector).stop(true, false).animate({scrollTop: ($(this.hash).offset().top) }, options.speed);
            }
        });

    };
})(jQuery);