// Simple JSONP helper with error handler.
// Jason Davies, http://www.jasondavies.com/
(function(exports) {
  var id = 0;
  exports.jsonp = function() {
    var currentScript = null,
        callbackParam = "callback";

    function getJSON(url, data, callback, error) {
      var src = url + (url.indexOf("?") === -1 ? "?" : "&"),
          head = document.getElementsByTagName("head")[0],
          newScript = document.createElement("script"),
          params = [],
          paramName = "";

      var s = "x" + id++;
      jsonp.callbacks[s] = callback;

      data[callbackParam] = "jsonp.callbacks." + s;
      for (paramName in data){  
        params.push(paramName + "=" + encodeURIComponent(data[paramName]));  
      }

      // Cache busting.
      params.push("_=" + +new Date);
      src += params.join("&");

      newScript.type = "text/javascript";  
      newScript.src = src;
      if (error) newScript.onerror = error;
      // Cancel existing script, if any.
      if (currentScript) head.removeChild(currentScript);
      head.appendChild(currentScript = newScript); 
    }

    getJSON.callback = function(x) {
      if (!arguments.length) return x;
      callbackParam = x + "";
      return getJSON;
    };

    return getJSON;
  }

  exports.jsonp.callbacks = {};
})(window);
