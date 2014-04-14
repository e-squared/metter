var EventTarget = function() {
  var eventSplitter = /\s+/;

  return {
    on: function(events, callback) {
      var event;

      if (!callback) {
        return this;
      }

      this._callbacks = this._callbacks || {};

      events = events.split(eventSplitter);

      while (event = events.shift()) {
        this._callbacks[event] = this._callbacks[event] || [];
        this._callbacks[event].push(callback);
      }

      return this;
    },

    trigger: function(events, data) {
      var event, callbacks;

      if (!this._callbacks) {
        return this;
      }

      events = events.split(eventSplitter);

      while (event = events.shift()) {
        if (callbacks = this._callbacks[event]) {
          for (var i = 0, ii = callbacks.length; i < ii; i++) {
            callbacks[i].call(this, { type: event, data: data });
          }
        }
      }

      return this;
    }
  };
}();
