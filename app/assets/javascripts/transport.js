//= require requestcache

var Transport = function() {
  function Transport(options) {
    options = (typeof options === "string") ? { url: options } : options;

    this.url = options.url;
    this.wildcard = options.wildcard || "%QUERY";
    this.filter = options.filter;
    this.replace = options.replace;

    this.requestCache = options.requestCache || new RequestCache();
    this.maxPendingRequests = (typeof options.maxParallelRequests === "number") ? options.maxParallelRequests : 6;
    this.pendingRequestsCount = 0;
    this.pendingRequests = {};

    this.ajaxSettings = {
      type: "get",
      cache: options.cache,
      timeout: options.timeout,
      dataType: options.dataType || "json",
      beforeSend: options.beforeSend
    };

    this._fetch = (/^throttle$/i.test(options.rateLimitFn) ? throttle : debounce)(this._fetch, options.rateLimitWait || 300);

    function debounce(func, wait, immediate) {
      var timeout, result;

      return function() {
        var context = this, args = arguments, later, callNow;

        later = function() {
          timeout = null;

          if (!immediate) {
            result = func.apply(context, args);
          }
        };

        callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);

        if (callNow) {
          result = func.apply(context, args);
        }

        return result;
      };
    }

    function throttle(func, wait) {
      var context, args, timeout, result, previous = 0, later;

      later = function() {
        previous = new Date();
        timeout = null;
        result = func.apply(context, args);
      };

      return function() {
        var now = new Date(), remaining = wait - (now - previous);

        context = this;
        args = arguments;

        if (remaining <= 0) {
          clearTimeout(timeout);
          timeout = null;
          previous = now;
          result = func.apply(context, args);
        } else if (!timeout) {
          timeout = setTimeout(later, remaining);
        }

        return result;
      };
    }
  }

  $.extend(Transport.prototype, {
    get: function(query, callback) {
      var
        self = this,
        encodedQuery = encodeURIComponent(query || "").replace(/\./g, "%2E"),
        url, response;

      callback = callback || $.noop;
      url = this.replace ? this.replace(this.url, encodedQuery) : this.url.replace(this.wildcard, encodedQuery);

      if (response = this.requestCache.get(url)) {
        setTimeout(function() {
          callback(self.filter ? self.filter(response) : response);
        }, 0);
      } else {
        this._fetch(url, callback);
      }

      return !!response;
    },

    setData: function(data) {
      this.ajaxSettings.data = data;
      this.requestCache.clear();
    },

    _fetch: function(url, callback) {
      var self = this;

      if (this.pendingRequestsCount < this.maxPendingRequests) {
        this._sendRequest(url).done(done);
      } else {
        this.onDeckRequestArgs = [].slice.call(arguments, 0);
      }

      function done(response) {
        var data = self.filter ? self.filter(response) : response;

        callback && callback(data);
        self.requestCache.set(url, response);
      }
    },

    _sendRequest: function(url) {
      var self = this, jqXhr = this.pendingRequests[url];

      if (!jqXhr) {
        this.pendingRequestsCount++;
        jqXhr = this.pendingRequests[url] = $.ajax(url, this.ajaxSettings).always(always);
      }

      return jqXhr;

      function always() {
        self.pendingRequestsCount--;
        self.pendingRequests[url] = null;

        if (self.onDeckRequestArgs) {
          self._fetch.apply(self, self.onDeckRequestArgs);
          self.onDeckRequestArgs = null;
        }
      }
    }
  });

  return Transport;
}();
