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
    // columnWidth: '.grid-sizer',
    gutter: 5,
    percentPosition: false,
    //horizontalOrder: true,
    isFitWidth: false,
    initLayout: false
});
// bind event
$grid.masonry( 'on', 'layoutComplete', function() {
    //console.log('layout is complete');
});

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
var is_get_new_page = 0;
$(window).scroll(function() {
    if($(window).scrollTop() + $(window).height() + 100 >= ($(document).height()) && $("#load_next_page").length > 0) {
        // bottom to get new page
        if(is_get_new_page == 0) {
            $("#load_next_page").show();
            is_get_new_page = 1;
            var cursor = $(".page")[0].textContent;
            var has_next_page = $(".has-next-page")[0].textContent.trim();
            var url = window.location.pathname + "/?cursor=" + cursor;
            url = url.replace("//", "/");
            var $user_id = $(".user-id");
            if ($user_id.length > 0) {
                $user_id = $user_id[0].textContent;
            } else {
                $user_id = undefined;
            }
            if ($user_id !== undefined) {
                url = window.location.origin + url + "&id=" + $user_id;
            } else {
                url = window.location.origin + url;
            }
            // console.log("request path is " + url);
            if (has_next_page === "true") {
                $.ajax({
                    url: url,
                    success: function(res) {
                        var $res = $(res);
                        // store res in jquery data
                        $('.grid').data("res", res);
                        var $page = $res.filter('.page')[0];
                        var $has_next_page = $res.filter('.has-next-page')[0];
                        $(".page")[0].textContent = $page.textContent;
                        $(".has-next-page")[0].textContent = $has_next_page.textContent;
                        $grid.masonryImagesReveal($res, true);
                    },
                    timeout: 5000})
                    .done(function() {
                        // console.log($('.grid').data("res"));
                    })
                    .fail(function() {
                        //console.log("error call ajax");
                    })
                    .always(function() {
                        //console.log("reset nex page");
                        is_get_new_page = 0;
                        $("#load_next_page").hide();
                    });
            } else {
                $("#load_next_page").hide();
                is_get_new_page = 0;
            }
        }
    }
});

$.fn.masonryImagesReveal = function($items, isAppend) {
    // hide by default
    $items.hide();
    // append to container
    if (isAppend == true) {
        $(".grid").append($items);
        $items.imagesLoaded()
            .progress(function(imgLoad, image) {
                // image is imagesLoaded class, not <img>, <img> is image.img
                var $item = $(image.img).parents(".grid-item");
                $item.show();
                $grid.masonry('appended', $item);
                // show next ads
                var $ads = $(image.img).parents(".grid-item").next().children(".ads");
                if ($ads.length!=0) {
                    var $item_ads = $(image.img).parents(".grid-item").next();
                    $item_ads.show();
                    var adsbygoogle=(adsbygoogle = window.adsbygoogle || []);
                    var $error = 0;
                    $ads.children('ins').each(function(){
                        try {
                            adsbygoogle.push(this);
                        } catch(error) {
                            $error = 1;
                        }
                    });
                    if ($error == 0) {
                        $grid.masonry('appended', $item_ads);
                    } else {
                        $item_ads.hide();
                    }
                }
            }).always( function( instance ){
            });
    } else {
        $items.imagesLoaded()
            .always( function( instance ) {
                // console.log('all images loaded');
                // trigger initial layout
                $items.show();
                $grid.masonry();
            })
            .done( function( instance ) {
                // console.log('all images successfully loaded');
            })
            .fail( function() {
                // console.log('all images loaded, at least one is broken');
            });
    }
    return this;
};

// first load to layout
$(document).ready(function() {
    var $items = $('.grid-item');
    $grid.masonryImagesReveal($items, false);
});
