/*
 * Google Analytics - Asynchronous Tracking 
 * http://code.google.com/apis/analytics/docs/tracking/asyncTracking.html
 */
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-155159-9']);
_gaq.push(['_trackPageview']);

(function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
})();