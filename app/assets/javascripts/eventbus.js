var EventBus = function() {
  function EventBus(node, namespace) {
    this.$node = $(node);
    this.namespace = namespace
  }

  $.extend(EventBus.prototype, {
    trigger: function(type) {
      var args = [].slice.call(arguments, 1);

      this.$node.trigger(this.namespace + type, args);
    }
  });

  return EventBus;
}();
