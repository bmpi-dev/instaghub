// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
// make $ available in Chrome console
window.$ = window.jQuery = require("jquery")

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

$(window).scroll(function() {
    var is_get_new_page = 0
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
        // bottom to get new page
        if(is_get_new_page == 0) {
            is_get_new_page = 1
            var page_len = $(".page").length
            var cursor = $(".page")[page_len - 1].textContent
            $.ajax({
                url: "/?cursor=" + cursor,
                success: function(res) {
                    var new_page = res
                    $(".grid").append(res)
                    is_get_new_page = 0
                }
            })
        }
    }
});
