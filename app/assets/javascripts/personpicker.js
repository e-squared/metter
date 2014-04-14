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

  var PersonPicker = function() {
    function PersonPicker(node, options) {
      var self = this;

      utils.bindAll(this);

      this.$node = $(node);
      this.node  = node;
      this.options = options;

      this.flyout = $('#' + this.options.namespace + '-flyout');

      if (!this.flyout.length) {
        this.flyout = $('<div id="' + this.options.namespace + '-flyout" class="typeahead-flyout"></div>').appendTo(document.body);
      }

      this.compiledFlyout = Hogan.compile(this.options.flyoutTemplate);
      this.renderFlyout = $.proxy(this.compiledFlyout.render, this.compiledFlyout);

      this.$node.typeahead([{
        name: this.options.namespace,
        remote: {
          url: this.options.autocompleteUrl,
          rateLimitWait: 75,
          filter: this.options.filter
        },
        template: this.options.autocompleteTemplate,
        engine: Hogan,
        limit: 10,
        flyout: this.flyout
      }]).on('typeahead:selected', function(e, datum) {
        return self.options.selected(datum);
      }).on('typeahead:moved', function(e, datum) {
        var
          dropdown = $('.tt-dataset-' + self.options.namespace),
          offset = dropdown.offset(),
          width = dropdown.width(),
          left;

        $.extend(datum, { texts: self.options.texts });

        if (width <= 0 || offset.left <= 0) {
          left = '-1000px';
        } else {
          left = (offset.left + width + 2) + 'px';
        }

        self.flyout.html(self.renderFlyout(datum)).css({ left: left, top: offset.top + 'px' });
      }).on('typeahead:dropdownClosed', function(e) {
        self.flyout.css('left', '-1000px');
      }).on('typeahead:cursorRemoved', function(e) {
        self.flyout.css('left', '-1000px');
      }).on('typeahead:queryChanged', function() {
        self.options.querychanged();
      });
    }

    $.extend(PersonPicker.prototype, {
      destroy: function() {
        this.$node.typeahead("destroy");
      },

      addLocalData: function(data) {
        this.$node.typeahead("addLocalData", data);
      },

      setQuery: function(query) {
        this.$node.typeahead("setQuery", query);
      }
    });

    return PersonPicker;
  }();

  var defaults = {
    namespace: 'people',
    autocompleteUrl: null,
    autocompleteTemplate: [
      '<p class="person-years">{{years}}</p>',
      '<p class="person-name">{{{name}}}</p>',
      '<p class="person-description">{{{descriptionTruncated}}} <span class="hidden">{{weight}}/{{rank}}</span></p>'
    ].join(''),
    flyoutTemplate: [
      '<div class="flyout-person">',
      //'  {{#wikipediaUrl}}',
      //'    <div class="copyright">',
      //'      From Wikipedia, the free encyclopedia',
      //'    </div>',
      //'  {{/wikipediaUrl}}',
      '  {{#imageUrl}}',
      '    <img src="{{imageUrl}}" class="photo">',
      '  {{/imageUrl}}',
      '  {{#about}}',
      '    <p>{{{about}}}{{#wikipediaUrl}} <span class="source">({{texts.source}}: <a href="{{wikipediaUrl}}" target="_blank">Wikipedia</a>)</span>{{/wikipediaUrl}}</p>',
      '  {{/about}}',
      '  {{^about}}',
      '    <p>{{{description}}}</p>',
      '  {{/about}}',
      '  <p><b>{{texts.born}}:</b><br>{{{born}}}</p>',
      '  {{#died}}',
      '    <p><b>{{texts.died}}:</b><br>{{{died}}}</p>',
      '  {{/died}}',
      '  {{#alternativeNames}}',
      '    <p><b>{{texts.alternativeNames}}:</b></p>',
      '    {{{alternativeNames}}}',
      '  {{/alternativeNames}}',
      '  {{#wikipediaUrl}}',
      '    <p><b>{{texts.authorityControl}}:</b><br>',
      '      {{#viafUrl}}<a href="{{viafUrl}}" target="_blank">VIAF</a>, {{/viafUrl}}',
      '      {{#lccnUrl}}<a href="{{lccnUrl}}" target="_blank">LCCN</a>, {{/lccnUrl}}',
      '      {{#worldcatUrl}}<a href="{{worldcatUrl}}" target="_blank">Worldcat</a>, {{/worldcatUrl}}',
      '      {{#gndUrl}}<a href="{{gndUrl}}" target="_blank">GND</a>, {{/gndUrl}}',
      '      <a href="{{wikipediaUrl}}" target="_blank">Wikipedia</a>',
      '    </p>',
      '  {{/wikipediaUrl}}',
      '</div>',
    ].join(''),
    selected: $.noop,
    querychanged: $.noop,
    texts: {
      born: 'Born',
      died: 'Died',
      source: 'Source',
      alternativeNames: 'Alternative Names',
      authorityControl: 'Authority Control'
    }
  }, methods = {
    initialize: function(options) {
      options = $.extend({}, defaults, options);

      $(this).data("personpicker", new PersonPicker(this, options));
    },

    setQuery: function(query) {
      var picker = $(this).data("personpicker");

      picker && picker.setQuery(query);
    },

    addLocalData: function(data) {
      var picker = $(this).data("personpicker");

      picker && picker.addLocalData(data);
    },

    destroy: function() {
      var
        $this = $(this),
        picker = $this.data("personpicker");

      if (picker) {
        picker.destroy();
        $this.removeData("personpicker");
      }
    }
  };

  $.fn.personpicker = function(method) {
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

