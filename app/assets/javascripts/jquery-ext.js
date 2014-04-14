(function($) {
  $.fn.setClass = function(className) {
    return this.each(function() {
      $(this).removeClass().addClass(className);
    });
  };
})(jQuery);

Array.prototype.uniq = function() {
  var u = {}, a = [];

  for (var i = 0, ii = this.length; i < ii; i++) {
    if (u.hasOwnProperty(this[i])) {
      continue;
    }

    a.push(this[i]);
    u[this[i]] = 1;
  }

  return a;
};
