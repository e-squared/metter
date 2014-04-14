//= require eventtarget
//= require eventbus
//= require requestcache
//= require transport
//= require hogan

(function($) {
  var utils = {
    bindAll: function(obj) {
      var val;

      for (var key in obj) {
        $.isFunction(val = obj[key]) && (obj[key] = $.proxy(val, obj));
      }
    },

    isBlankString: function(str) {
      return !str || /^\s*$/.test(str);
    }
  };

  var InputView = function() {
    function InputView(input) {
      var self = this;

      utils.bindAll(this);

      this.specialKeyCodeMap = {
        9:  "tab",
        27: "esc",
        37: "left",
        39: "right",
        13: "enter",
        38: "up",
        40: "down"
      };

      this.$input = $(input)
        .attr({ autocomplete: "off", spellcheck: false })
        .on("focus.dp", this._handleFocus)
        .on("blur.dp", this._handleBlur)
        .on("keydown.dp", this._handleSpecialKeyEvent)
        .on("input.dp", this._compareQueryToInputValue);

      this.query = this.$input.val();
    }

    $.extend(InputView.prototype, EventTarget, {
      _handleFocus: function() {
        this.trigger("focused");
      },

      _handleBlur: function() {
        this.trigger("blured");
      },

      _handleSpecialKeyEvent: function(e) {
        var keyName = this.specialKeyCodeMap[e.which || e.keyCode];
        keyName && this.trigger(keyName + "Keyed", e);
      },

      _compareQueryToInputValue: function() {
        var
          inputValue = this.getInputValue(),
          isSameQuery = compareQueries(this.query, inputValue),
          isSameQueryExceptWhitespace = isSameQuery ? this.query.length !== inputValue.length : false;

        if (isSameQueryExceptWhitespace) {
          this.trigger("whitespaceChanged", { value: this.query });
        } else if (!isSameQuery) {
          this.trigger("queryChanged", { value: this.query = inputValue });
        }

        function compareQueries(a, b) {
          a = (a || "").replace(/^\s*/g, "").replace(/\s{2,}/g, " ");
          b = (b || "").replace(/^\s*/g, "").replace(/\s{2,}/g, " ");
          return a === b;
        }
      },

      destroy: function() {
        this.$input.off(".dp");
        this.$input = null;
      },

      focus: function() {
        this.$input.focus();
      },

      blur: function() {
        this.$input.blur();
      },

      getQuery: function() {
        return this.query;
      },

      setQuery: function(query) {
        this.query = query;
      },

      getInputValue: function() {
        return this.$input.val();
      },

      setInputValue: function(value, silent) {
        this.$input.val(value);
        !silent && this._compareQueryToInputValue();
      },

      isCursorAtEnd: function() {
        var
          valueLength = this.$input.val().length,
          selectionStart = this.$input[0].selectionStart,
          range;

        if (typeof selectionStart === "number") {
          return selectionStart === valueLength;
        } else if (document.selection) {
          range = document.selection.createRange();
          range.moveStart("character", -valueLength);

          return valueLength === range.text.length;
        }

        return true;
      }
    });

    return InputView;
  }();

  var EventsView = function() {
    function EventsView(input, options) {
      utils.bindAll(this);

      this.$input = $(input);

      this.isOpen = false;
      this.isEmpty = true;
      this.namespace = options.namespace;
      this.template = options.template;
      this.header = options.header;
      this.footer = options.footer;
      this.margin = options.margin || 10;
      this.isMouseOver = false;

      this.$container = $(options.container).on("mouseenter.dp", this._handleMouseenter).on("mouseleave.dp", this._handleMouseleave);
      this.$window = $(window).on("scroll resize", this._positionContainer);
    }

    $.extend(EventsView.prototype, EventTarget, {
      _handleMouseenter: function() {
        this.isMouseOver = true;
      },

      _handleMouseleave: function() {
        this.isMouseOver = false;
      },

      _show: function() {
        this._positionContainer();
        this.$container.show();
        this.trigger("opened");
      },

      _hide: function() {
        this.$container.hide();
        this.trigger("closed");
      },

      destroy: function() {
        this.$container.off(".dp");
        this.$container = null;
      },

      isVisible: function() {
        return this.isOpen && !this.isEmpty;
      },

      open: function() {
        if (!this.isOpen) {
          this.isOpen = true;
          !this.isEmpty && this._show();
        }
      },

      close: function() {
        if (this.isOpen) {
          this.isOpen = false;
          this._hide();
        }
      },

      closeUnlessMouseIsOver: function() {
        if (!this.isMouseOver) {
          this.close();
        }
      },

      render: function(events) {
        var
          datasetClassName = 'dp-dataset-' + this.namespace,
          wrapper = '<div class="dp-event">%body</div>',
          compiledHtml, $list, event,
          $dataset = this.$container.find('.' + datasetClassName),
          itemBuilder, fragment, $item;

        if ($dataset.length === 0) {
          $list = $('<span class="dp-events"></span>').css({ display: 'block' });
          $dataset = $('<div></div>').addClass(datasetClassName).append(this.header).append($list).append(this.footer).appendTo(this.$container);
        }

        if (events.length > 0) {
          this.isEmpty = false;
          this.isOpen && this._show();

          itemBuilder = document.createElement('div');
          fragment = document.createDocumentFragment();

          for (var i = 0, ii = events.length; i < ii; i++) {
            event = events[i];

            itemBuilder.innerHTML = wrapper.replace("%body", this.template(event));
            $item = $(itemBuilder.firstChild).data("event", event);

            fragment.appendChild($item[0]);
          }

          $dataset.show().find('.dp-events').html(fragment);
          this.$container.scrollTop(0);
        } else {
          this.clear();
        }

        this.trigger("rendered");
      },

      clear: function() {
        var
          $dataset = this.$container.find(".dp-dataset-" + this.namespace),
          $items = $dataset.find(".dp-events");

        $dataset.hide();
        $items.empty();

        if (this.$container.find(".dp-events > .dp-event").length === 0) {
          this.isEmpty = true;
          this._hide();
        }
      },

      _positionContainer: function(e) {
        if (!this.isVisible()) {
          return;
        }

        var position = {
          top: this.$window.scrollTop() + this.margin,
          left: this.$input.offset().left + this.$input.width() + 80,
          height: this.$window.innerHeight() - 2 * this.margin
        }

        this.$container.css(position);
      }
    });

    return EventsView;
  }();

  var DatingPicker = function() {
    function DatingPicker(input, options) {
      utils.bindAll(this);

      this.$input = $(input);
      this.input = input;

      this.eventsTransport = new Transport(options.events);
      this.datesTransport = new Transport(options.dates);
      this.eventBus = new EventBus(input, "datingpicker:");
      this.eventTemplate = Hogan.compile(options.events.template);

      this.inputView = new InputView(input)
        .on("blured tabKeyed escKeyed", this._closeEvents)
        .on("queryChanged", this._getDates)
        .on("queryChanged", this._getEvents)
        .on("queryChanged", this._handleQueryChanged)
        .on("focused queryChanged whitespaceChanged", this._openEvents);

      this.eventsView = new EventsView(input, {
        namespace: options.namespace,
        template: $.proxy(this.eventTemplate.render, this.eventTemplate),
        header: options.events.header,
        footer: options.events.footer,
        container: $('<div id="' + options.namespace + '-flyout" class="datingpicker-flyout"></div>').appendTo(document.body).hide()
      }).on("rendered", this._handleEventsRendered)
        .on("opened", this._handleEventsOpened);
    }

    $.extend(DatingPicker.prototype, EventTarget, {
      destroy: function() {
        this.inputView.destroy();
        this.eventsView.destroy();
      },

      setQuery: function(query) {
        this.inputView.setQuery(query);
        this.inputView.setInputValue(query);
        this._clearEvents();
        this._getEvents();
      },

      setYearBase: function(year) {
        var data = { base: year };

        this.datesTransport.setData(data);
        this._getDates();

        this.eventsTransport.setData(data);
        this._clearEvents();
        this._getEvents();
      },

      _handleQueryChanged: function() {
        this.eventBus.trigger("queryChanged");
      },

      _getDates: function() {
        var self = this, query = this.inputView.getQuery();

        if (utils.isBlankString(query) || query.length < 2) {
          return;
        }

        this.eventBus.trigger("parsing:start");

        this.datesTransport.get(query, function(result) {
          self.eventBus.trigger("parsing:completed");

          if (query === self.inputView.getQuery()) {
            self.eventBus.trigger("parsing:result", result);
          } else {
            self.eventBus.trigger("parsing:canceled");
          }
        });
      },

      _getEvents: function() {
        var self = this, query = this.inputView.getQuery();

        if (utils.isBlankString(query) || query.length < 2) {
          return;
        }

        this.eventsTransport.get(query, function(events) {
          if (query === self.inputView.getQuery()) {
            self.eventsView.render(events);
          }
        });
      },

      _clearEvents: function() {
        this.eventsView.clear();
      },

      _openEvents: function() {
        this.eventsView.open();
      },

      _closeEvents: function(e) {
        this.eventsView[e.type === "blured" ? "closeUnlessMouseIsOver" : "close"]();
      },

      _handleEventsRendered: function(e) {
        this.eventBus.trigger("eventsRendered");
      },

      _handleEventsOpened: function(e) {
        this.eventBus.trigger("eventsOpened");
      }
    });

    return DatingPicker;
  }();

  var defaults = {
    namespace: 'dating',
    events: null,
    eventTemplate: [
      '<p class="event-date">{{date}}</p>',
      '<p class="event-description">{{{description}}}</p>'
    ].join('')
  }, methods = {
    initialize: function(options) {
      options = $.extend({}, defaults, options);

      $(this).data("datingpicker", new DatingPicker(this, options));
    },

    setQuery: function(query) {
      var picker = $(this).data("datingpicker");
      picker && picker.setQuery(query);
    },

    setYearBase: function(year) {
      var picker = $(this).data("datingpicker");
      picker && picker.setYearBase(year);
    },

    destroy: function() {
      var
        $this = $(this),
        picker = $this.data("datingpicker");

      if (picker) {
        picker.destroy();
        $this.removeData("datingpicker");
      }
    }
  };

  $.fn.datingpicker = function(method) {
    var args =  arguments;

    return this.each(function() {
      if (methods[method]) {
        methods[method].apply(this, [].slice.call(args, 1));
      } else {
        methods.initialize.apply(this, args);
      }
    });
  };
})(jQuery);

