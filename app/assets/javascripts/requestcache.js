var RequestCache = function() {
  function RequestCache(options) {
    options = options || {};

    this.sizeLimit = options.sizeLimit || 10;
    this.clear();
  }

  $.extend(RequestCache.prototype, {
    get: function(url) {
      return this.cache[url];
    },

    set: function(url, response) {
      var requestToEvict;

      if (this.cachedKeysByAge.length === this.sizeLimit) {
        requestToEvict = this.cachedKeysByAge.shift();
        delete this.cache[requestToEvict];
      }

      this.cache[url] = response;
      this.cachedKeysByAge.push(url);
    },

    clear: function() {
      this.cache = {};
      this.cachedKeysByAge = [];
    }
  });

  return RequestCache;
}();
