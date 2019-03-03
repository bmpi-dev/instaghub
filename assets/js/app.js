// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
var Masonry = require('masonry-layout');
var Imagesloaded = require('imagesloaded');
var jQueryBridget = require('jquery-bridget');
// make $ available in Chrome console
$ = window.$ = window.jQuery = require("jquery");
// make Masonry a jQuery plugin
jQueryBridget( 'masonry', Masonry, $ );
// provide jQuery argument
Imagesloaded.makeJQueryPlugin( $ );

var $grid = $('.grid').masonry({
    // options
    itemSelector: '.grid-item',
    //horizontalOrder: true,
    //isFitWidth: true
});

// init layout masonry
$grid;

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
var is_get_new_page = 0;
$(window).scroll(function() {
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
        // bottom to get new page
        if(is_get_new_page == 0) {
            $("#load_next_page").show();
            is_get_new_page = 1;
            var cursor = $(".page")[0].textContent;
            $.ajax({
                url: "/?cursor=" + cursor,
                success: function(res) {
                    var $res = $(res);
                    var $page = $res.filter('.page')[0];
                    $(".page")[0].textContent = $page.textContent;
                    $grid.masonryImagesReveal($res);
                }
            });
        }
    }
});

$.fn.masonryImagesReveal = function($items) {
    // hide by default
    $items.hide();
    // append to container
    $(".grid").append($items);
    $items.imagesLoaded().progress(function(imgLoad, image) {
        // image is imagesLoaded class, not <img>, <img> is image.img
        var $item = $( image.img ).parents(".grid-item");
        $item.show();
        $grid.masonry('appended', $item);
        is_get_new_page = 0;
        $("#load_next_page").hide();
    });
    return this;
};
