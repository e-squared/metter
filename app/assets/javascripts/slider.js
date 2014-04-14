/* =========================================================
 * bootstrap-slider.js v2.0.0
 * http://www.eyecon.ro/bootstrap-slider
 * =========================================================
 * Copyright 2012 Stefan Petre
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================= */

!function($) {
  var Slider = function(element, options) {
    this.element = $(element);

    this.touchCapable = typeof Modernizr !== 'undefined' && Modernizr.touch;

    this.control = $(
      '<div class="slider">' +
        '<div class="slider-track">' +
          '<div class="slider-selection"></div>' +
          '<div class="slider-handle"></div>' +
        '</div>' +
        '<div class="tooltip">' +
          '<div class="tooltip-arrow"></div>' +
          '<div class="tooltip-inner"></div>' + 
        '</div>' +
      '</div>').insertBefore(this.element).append(this.element).width(this.element.width());

    this.tooltip        = this.control.find('.tooltip').addClass('top');
    this.tooltipContent = this.tooltip.find('.tooltip-inner');
    this.selection      = this.control.find('.slider-selection');
    this.handle         = this.control.find('.slider-handle');

    this.min  = this.element.data('slider-min')  || options.min;
    this.max  = this.element.data('slider-max')  || options.max;
    this.step = this.element.data('slider-step') || options.step;
    this.diff = this.max - this.min;

    this.showTooltip = this.element.data('slider-tooltip') === "true" || options.tooltip === true;

    if (!this.showTooltip) {
      this.tooltip.hide();
    }

    this.formatter = options.formatter;

    if (this.touchCapable) {
      this.control.on({ touchstart: $.proxy(this.mousedown, this) });
    } else {
      this.control.on({ mousedown: $.proxy(this.mousedown, this) });
    }

    this.control.on({
      mouseenter: $.proxy(this.mouseenter, this),
      mouseleave: $.proxy(this.mouseleave, this)
    });

    setTimeout($.proxy(function() {
      this.left  = this.control.offset().left;
      this.width = this.control[0].offsetWidth;

      this.tooltip.css('top', -this.tooltip.height() - 22);

      this.setValue(parseInt(this.element.data('slider-value') || this.element.prop('value') || options.value));
    }, this), 100);
  };

  Slider.prototype = {
    constructor: Slider,
    hovering: false,
    dragging: false,

    layout: function() {
      this.handle.css('left', this.percentage[0] + '%');
      this.selection.css('width', this.percentage[0] + '%');

      this.tooltipContent.text(this.formatter(this.value));

      this.tooltip.css('left', this.width * this.percentage[0] / 100 - (this.tooltip.width() / 2) + 'px');
    },

    mouseenter: function(e) {
      this.tooltip.addClass('in');
      this.hovering = true;
    },

    mouseleave: function(e) {
      if (!this.dragging) {
        this.tooltip.removeClass('in');
      }

      this.hovering = false;
    },

    mousedown: function(e) {
      if (this.touchCapable && e.type === 'touchstart') {
        e = e.originalEvent;
      }

      this.left  = this.control.offset().left;
      this.width = this.control[0].offsetWidth;

      this.percentage[0] = this.getPercentage(e);
      this.layout();

      if (this.touchCapable) {
        $(document).on({
          touchmove: $.proxy(this.mousemove, this),
          touchend: $.proxy(this.mouseup, this)
        });
      } else {
        $(document).on({
          mousemove: $.proxy(this.mousemove, this),
          mouseup:   $.proxy(this.mouseup, this)
        });
      }

      this.dragging = true;

      var val = this.calculateValue();

      this.element.trigger({ type: 'slideStart', value: val }).trigger({ type: 'slide', value: val });

      return false;
    },

    mousemove: function(e) {
      if (this.touchCapable && e.type === 'touchstart') {
        e = e.originalEvent;
      }

      this.percentage[0] = this.getPercentage(e);

      this.layout();

      var val = this.calculateValue();

      this.element.trigger({ type: 'slide', value: val }).data('value', val).prop('value', val);

      return false;
    },

    mouseup: function(ev) {
      if (this.touchCapable) {
        $(document).off({
          touchmove: this.mousemove,
          touchend: this.mouseup
        });
      } else {
        $(document).off({
          mousemove: this.mousemove,
          mouseup: this.mouseup
        });
      }

      this.dragging = false;

      if (!this.hovering) {
        this.mouseleave();
      }

      var val = this.calculateValue();

      this.element.trigger({ type: 'slide', value: val }).trigger({ type: 'slideStop', value: val }).data('value', val).prop('value', val);

      return false;
    },

    calculateValue: function() {      
      return this.value = (this.min + Math.round((this.diff * this.percentage[0] / 100) / this.step) * this.step);
    },

    getPercentage: function(e) {
      if (this.touchCapable) {
        e = e.touches[0];
      }

      var percentage = (e.pageX - this.left) * 100 / this.width;
      percentage = Math.round(percentage / this.percentage[1]) * this.percentage[1];

      return Math.max(0, Math.min(100, percentage));
    },

    getValue: function() {
      return this.value;
    },

    setValue: function(val) {
      this.value = Math.max(this.min, Math.min(this.max, val));

      this.percentage = [
        (this.value - this.min) * 100 / this.diff,
        this.step * 100 / this.diff
      ];

      this.layout();
    }
  };

  $.fn.slider = function ( option, val ) {
    return this.each(function() {
      var
        $this = $(this),
        data = $this.data('slider'),
        options = typeof option === 'object' && option;

      if (!data)  {
        $this.data('slider', (data = new Slider(this, $.extend({}, $.fn.slider.defaults, options))));
      }

      if (typeof option == 'string') {
        data[option](val);
      }
    })
  };

  $.fn.slider.defaults = {
    min: 0,
    max: 10,
    step: 1,
    value: 5,
    tooltip: true,
    formatter: function(value) { return value; }
  };

  $.fn.slider.Constructor = Slider;
}(window.jQuery);
