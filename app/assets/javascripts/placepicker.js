//= require hogan
//= require typeahead

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

  var PlacePicker = function() {
    function PlacePicker(node, options) {
      var self = this;

      utils.bindAll(this);

      this.$node = $(node);
      this.node  = node;
      this.options = options;

      this.geocoder = new google.maps.Geocoder();

      this.flyout = $('#' + this.options.namespace + '-flyout');

      if (this.flyout.length) {
        this.canvas = this.flyout.children().first();
      } else {
        this.flyout = $('<div id="' + this.options.namespace + '-flyout" class="typeahead-flyout"></div>').appendTo(document.body);
        this.canvas = $('<div class="flyout-place"></div>').appendTo(this.flyout);
      }

      this.map = new google.maps.Map(this.canvas[0], {
        zoom:         this.options.initialMapZoom,
        center:       this.options.initialMapPosition,
        scrollwheel:  false,
        mapTypeId:    google.maps.MapTypeId.ROADMAP,
        streetViewControl: false
      });

      this.marker = new google.maps.Marker({
        position:   this.options.initialMapPosition,
        map:        this.map,
        draggable:  true
      });

      this.$node.typeahead([{
        name: this.options.namespace,
        limit: 20,
        flyout: this.flyout,
        template: function(context) { return '<p class="address">' + context.formatted_address + '</p>'; },
        valueKey: 'formatted_address',
        fetch: function(query, callback) {
          self.geocoder.geocode({ address: query, region: self.options.geocodeRegionBias }, function(results, status) {
            /*
            if (status == google.maps.GeocoderStatus.OK) {
              for (var i = 0, ii = results.length; i < ii; i++) {
                results[i].value = results[i].formatted_address;
                results[i].tokens = [results[i].formatted_address];
              };
            }
            */

            callback(results);
          });
        }
      }]).on('typeahead:selected', function(e, datum) {
        return self.options.selected(datum);
      }).on('typeahead:moved', function(e, datum) {
        var
          dropdown = $('.tt-dataset-' + self.options.namespace),
          offset = dropdown.offset(),
          width = dropdown.width();

        self.marker.setPosition(datum.geometry.location);
        self.map.fitBounds(datum.geometry.viewport);
        self.flyout.css({ left: offset.left + width + 2 + 'px', top: offset.top });
      }).on('typeahead:dropdownClosed', function(e) {
        self.flyout.css('left', '-1000px');
      }).on('typeahead:cursorRemoved', function(e) {
        self.flyout.css('left', '-1000px');
      }).on('typeahead:queryChanged', function() {
        self.options.querychanged();
      });

      google.maps.event.addListener(this.marker, 'dragend', function() {
        var
          position = self.marker.getPosition(),
          latLng = new google.maps.LatLng(position.lat(), position.lng());

        self.geocoder.geocode({ latLng: latLng }, function(results, status) {
          if (status == google.maps.GeocoderStatus.OK) {
            self.$node.typeahead('setQuery', results[0].formatted_address);
            self.$node.typeahead('moveFirst');
          } else {
            self.$node.typeahead('setQuery', '');
            self.flyout.css('left', '-1000px');
          }
        });
      });
    }

    $.extend(PlacePicker.prototype, {
      destroy: function() {
        this.$node.typeahead("destroy");
      },

      setQuery: function(query) {
        this.$node.typeahead("setQuery", query);
      },

      isFlyoutVisible: function() {
        return this.flyout.offset().left >= 0;
      }
    });

    return PlacePicker;
  }();

  var defaults = {
    namespace: 'places',
    initialMapZoom: 1,
    initialMapPosition: new google.maps.LatLng(40, -30),
    geocodeRegionBias: 'us',
    selected: $.noop,
    querychanged: $.noop
  }, methods = {
    initialize: function(options) {
      options = $.extend({}, defaults, options);

      return this.each(initialize);

      function initialize() {
        $(this).data("placepicker", new PlacePicker(this, options));
      }
    },

    setQuery: function(query) {
      return this.each(setQuery);

      function setQuery() {
        var picker = $(this).data("placepicker");

        picker && picker.setQuery(query);
      }
    },

    isFlyoutVisible: function() {
      var picker = $(this[0]).data("placepicker");

      return picker && picker.isFlyoutVisible();
    },

    destroy: function() {
      return this.each(destroy);

      function destroy() {
        var $this = $(this), picker = $this.data("placepicker");

        if (picker) {
          picker.destroy();
          $this.removeData("placepicker");
        }
      }
    }
  };

  $.fn.placepicker = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, [].slice.call(arguments, 1));
    } else {
      return methods.initialize.apply(this, arguments);
    }
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

