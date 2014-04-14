$(function() {
  if (!$("body.letters-new").length) {
    return;
  }

  var
    defaultIconHtml = '<i class="icon-spinner icon-input icon-input-wait icon-input-hidden"></i>',
    personPopoverTemplate = Hogan.compile($("#person-popover").html()),
    addressPopoverTemplate = Hogan.compile($("#address-popover").html()),
    datingPopoverTemplate = Hogan.compile($("#dating-popover").html()),
    yearBase = null,

    addressComponentTypes = _t("letters.form.address_component_types"),

    senderName,
    senderNameInput = $('#letter_sender_name').addClass('has-icon span5'),
    senderNameIcon = $(defaultIconHtml).attr("data-add-person", "#letter_sender_name").appendTo(senderNameInput.closest('.controls')),
    senderNamePopoverTitle,
    senderNamePopoverContent,

    senderAddress,
    senderAddressInput = $('#letter_sender_address').addClass('has-icon span5'),
    senderAddressIcon = $(defaultIconHtml).appendTo(senderAddressInput.closest('.controls')),
    senderAddressPopoverTitle,
    senderAddressPopoverContent,

    recipientName,
    recipientNameInput = $('#letter_recipient_name').addClass('has-icon span5'),
    recipientNameIcon = $(defaultIconHtml).attr("data-add-person", "#letter_recipient_name").appendTo(recipientNameInput.closest('.controls')),
    recipientNamePopoverTitle,
    recipientNamePopoverContent,

    recipientAddress,
    recipientAddressInput = $('#letter_recipient_address').addClass('has-icon span5'),
    recipientAddressIcon = $(defaultIconHtml).appendTo(recipientAddressInput.closest('.controls')),
    recipientAddressPopoverTitle,
    recipientAddressPopoverContent,

    dateOfWriting,
    dateOfWritingInput = $('#letter_date_of_writing').addClass('has-icon span5'),
    dateOfWritingIcon = $(defaultIconHtml).attr("data-dating", "#letter_date_of_writing").appendTo(dateOfWritingInput.closest('.controls')),
    dateOfWritingPopoverTitle,
    dateOfWritingPopoverContent,

    summary,
    summaryInput = $('#letter_summary').addClass('has-icon span5'),
    summaryIcon = $(defaultIconHtml).appendTo(summaryInput.closest('.controls'));

  senderNameInput.personpicker({
    namespace: 'people-sender',
    autocompleteUrl: '/people/search.json?query=%QUERY',
    filter: filterPeople,
    selected: function(person) {
      senderName = person;
      senderAddressInput.focus();
      yearBase = person.birthYear
      dateOfWritingInput.datingpicker("setYearBase", yearBase);
      return false;
    },
    querychanged: function() {
      senderName = null;
      senderNameIcon.addClass("icon-input-hidden");
    },
    texts: {
      born: _t("letters.form.born"),
      died: _t("letters.form.died"),
      source: _t("letters.form.source"),
      alternativeNames: _t("letters.form.alternative_names"),
      authorityControl: _t("letters.form.authority_control")
    }
  }).on("focus", function() { adjustWindowScrollPosition($(this), 520); }).on("blur", function() { checkSenderName(true); });

  if (!$("div.alert").length) {
    senderNameInput.focus();
  }

  senderAddressInput.placepicker({
    namespace: 'places-sender',
    selected: function(place) {
      var usa = false, type;

      place.address_components = place.address_components.reverse();

      place.address_components.push({ types: ['latitude'], long_name: round(place.geometry.location.lat(), 5) });
      place.address_components.push({ types: ['longitude'], long_name: round(place.geometry.location.lng(), 5) });

      for (var i = 0, ii = place.address_components.length; i < ii; i++) {
        ac = place.address_components[i];

        type = ac.types[0];

        if (type == "country" && (ac.long_name == "United States" || ac.long_name == "USA")) {
          usa = true;
        }

        if (usa && type == "administrative_area_level_1") {
          ac.translated_type = _t("united_states.administrative_area_level_1");
        } else if (usa && type == "administrative_area_level_2") {
          ac.translated_type = _t("united_states.administrative_area_level_2");
        } else {
          ac.translated_type = addressComponentTypes[type];
        }
      }

      senderAddress = place;
      recipientNameInput.focus();
      return false;
    },
    querychanged: function() {
      senderAddress = null;
      senderAddressIcon.addClass("icon-input-hidden");
    }
  }).on("focus", function() { adjustWindowScrollPosition($(this), 400); }).on("blur", function() { checkSenderAddress(true); });

  recipientNameInput.personpicker({
    namespace: 'people-recipient',
    autocompleteUrl: '/people/search.json?query=%QUERY',
    filter: filterPeople,
    selected: function(person) {
      recipientName = person;
      recipientAddressInput.focus();
      return false;
    },
    querychanged: function() {
      recipientName = null;
      recipientNameIcon.addClass("icon-input-hidden");
    },
    texts: {
      born: _t("letters.form.born"),
      died: _t("letters.form.died"),
      source: _t("letters.form.source"),
      alternativeNames: _t("letters.form.alternative_names"),
      authorityControl: _t("letters.form.authority_control")
    }
  }).on("focus", function() { adjustWindowScrollPosition($(this), 520); }).on("blur", function() { checkRecipientName(true); });

  recipientAddressInput.placepicker({
    namespace: 'places-recipient',
    selected: function(place) {
      var usa = false, type;

      place.address_components = place.address_components.reverse();

      place.address_components.push({ types: ['latitude'], long_name: round(place.geometry.location.lat(), 5) });
      place.address_components.push({ types: ['longitude'], long_name: round(place.geometry.location.lng(), 5) });

      for (var i = 0, ii = place.address_components.length; i < ii; i++) {
        ac = place.address_components[i];

        type = ac.types[0];

        if (type == "country" && (ac.long_name == "United States" || ac.long_name == "USA")) {
          usa = true;
        }

        if (usa && type == "administrative_area_level_1") {
          ac.translated_type = _t("united_states.administrative_area_level_1");
        } else if (usa && type == "administrative_area_level_2") {
          ac.translated_type = _t("united_states.administrative_area_level_2");
        } else {
          ac.translated_type = addressComponentTypes[type];
        }
      }

      recipientAddress = place;
      dateOfWritingInput.focus();
      return false;
    },
    querychanged: function() {
      recipientAddress = null;
      recipientAddressIcon.addClass("icon-input-hidden");
    }
  }).on("focus", function() { adjustWindowScrollPosition($(this), 400); }).on("blur", function() { checkRecipientAddress(true); });

  dateOfWritingInput.datingpicker({
    namespace: 'dating-dateofwriting',
    events: {
      url: "/events/search.json?mode=picker&query=%QUERY",
      template: '<h4>{{date}}</h4><ul>{{#events}}<li class="{{cssClass}}">{{{description}}}</li>{{/events}}</ul>',
      filter: function(data) {
        var datum, result = [], lastItem;

        for (var i = 0, ii = data.length; i < ii; i++) {
          datum = data[i];
          lastItem = result[result.length - 1] || {};

          if (lastItem.date == datum.date) {
            lastItem.events.push(datum);
          } else {
            result.push({ date: datum.date, events: [datum] });
          }
        }

        return result;
      },
      header: [
        '<div class="header">',
        '  <span>' + _t("letters.form.filter") + ':</span>',
        '  <label><input type="checkbox" class="events-flyout-toggle" data-type="history-event" checked="checked"> ' + _t("letters.form.history") + '</label>',
        '  <label><input type="checkbox" class="events-flyout-toggle" data-type="birth-event" checked="checked"> ' + _t("letters.form.births") + '</label>',
        '  <label><input type="checkbox" class="events-flyout-toggle" data-type="death-event" checked="checked"> ' + _t("letters.form.deaths") + '</label>',
        '  <label><input type="checkbox" class="events-flyout-toggle" data-type="holiday-event" checked="checked"> ' + _t("letters.form.holidays") + '</label>',
        '</div>'
      ].join("")
    },
    dates: {
      url: "/dating/parse.json?query=%QUERY"
    }
  }).on("datingpicker:eventsRendered datingpicker:eventsOpened", function() {
    adjustEventsFlyoutHeader();
    $("input.events-flyout-toggle", $("#dating-dateofwriting-flyout")).prop("checked", true);
  }).on("datingpicker:parsing:start", function() {
    dateOfWritingIcon.setClass('icon-spinner icon-input icon-input-wait');
  }).on("datingpicker:parsing:completed", function() {
    dateOfWritingIcon.addClass("icon-input-hidden");
  }).on("datingpicker:parsing:result", function(e, result) {
    dateOfWriting = parseDates(result);
    $("#date-adjust-dialog").removeData("modal");

    checkDateOfWriting(true);
  });

  senderNameIcon.popover({
    trigger: "hover", html: true,
    title: function() { return senderNamePopoverTitle; },
    content: function() { return senderNamePopoverContent; }
  });

  senderAddressIcon.popover({
    trigger: "hover", html: true,
    title: function() { return senderAddressPopoverTitle; },
    content: function() { return senderAddressPopoverContent; }
  });

  recipientNameIcon.popover({
    trigger: "hover", html: true,
    title: function() { return recipientNamePopoverTitle; },
    content: function() { return recipientNamePopoverContent; }
  });

  recipientAddressIcon.popover({
    trigger: "hover", html: true,
    title: function() { return recipientAddressPopoverTitle; },
    content: function() { return recipientAddressPopoverContent; }
  });

  dateOfWritingIcon.popover({
    trigger: "hover", html: true,
    title: function() { return dateOfWritingPopoverTitle; },
    content: function() { return dateOfWritingPopoverContent; }
  });

  $(document).on("click", "i.icon-input-error[data-add-person]", function() {
    var input = $($(this).attr("data-add-person"));

    $('.modal-body .alert-invalid', $('#new-person-dialog')).remove();
    $('.modal-body .input-multiple .input-append', $('#new-person-dialog')).each(function(i) { if (i > 0) { $(this).remove(); }});
    $('input, textarea', $('#new_person')).val('');
    $("#person_name").val(input.val());
    $("#new_person").data("sourceInput", input);
    $("#new-person-dialog").modal().on("shown", function() { $("#person_name").focus(); });
  });

  $(document).on("click", "i.icon-input-error[data-dating]", function() {
    $("#date-help-dialog").modal({ remote: "/dating/help" });
  });

  $(document).on("click", "i.icon-input-success[data-dating]", function() {
    $("#date-adjust-dialog").modal({ remote: "/dating/adjust?query=" + encodeURIComponent(dateOfWritingInput.val()) + (yearBase ? "&base=" + yearBase : "") });
  });

  $(document).on("click", "a.switch-to-manual-date-entry", function() {
    $("#date-help-dialog").modal("hide");

    setTimeout(function() {
      $("#date-adjust-dialog").modal({ remote: "/dating/adjust?query=" + encodeURIComponent(dateOfWritingInput.val()) + (yearBase ? "&base=" + yearBase : "") });
    }, 500);

    return false;
  });

  $("#date-adjust-dialog form").on("submit", function(e) {
    var data = $(this).serializeObject();

    dateOfWriting = parseDates(data);
    dateOfWritingInput.datingpicker("setQuery", dateOfWriting.query);

    checkDateOfWriting(true);
    $("#date-adjust-dialog").modal("hide");
    dateOfWritingInput.focus();

    return false;
  });

  $("#new_person").on("ajax:success", function(e, person) {
    $("#new-person-dialog").modal("hide");

    senderNameInput.personpicker("addLocalData", filterPeople([person]));
    recipientNameInput.personpicker("addLocalData", filterPeople([person]));

    $(this).data("sourceInput").personpicker("setQuery", person.name).focus();
  }).on("ajax:error", function(e, xhr, status, error) {
    var
      errors = xhr.responseJSON,
      wrapper = $('<div class="alert alert-block alert-error alert-invalid"></div>'),
      list = $('<ul></ul>').appendTo(wrapper);

    for (var i = 0, ii = errors.length; i < ii; i++) {
      $('<li></li>').text(errors[i]).appendTo(list);
    }

    $('.modal-body .alert-invalid').remove();
    $('.modal-body', this).prepend(wrapper).scrollTop(0);
  });

  $(document).on("change", "input.events-flyout-toggle", function(e) {
    var
      show = this.checked,
      selector = "li." + $(this).attr("data-type"),
      flyout = $("#dating-dateofwriting-flyout");

    $(selector, flyout)[show ? "removeClass" : "addClass"]("hidden");

    $('.dp-event', flyout).each(function() {
      $(this)[$("li:not(.hidden)", this).length ? "removeClass" : "addClass"]("hidden");
    });

    adjustEventsFlyoutHeader();
    dateOfWritingInput.focus();
  });

  function adjustEventsFlyoutHeader() {
    var flyout = $("#dating-dateofwriting-flyout");

    $(".header", flyout).width($(".dp-events", flyout).width());
  }

  function adjustWindowScrollPosition(input, neededHeight) {
    var
      $window = $(window),
      offsetTop = input.offset().top,
      windowScroll = $window.scrollTop(),
      windowHeight = $(window).height(),
      top = offsetTop - windowScroll,
      height = input.innerHeight(),
      bottom = top + height,
      remainingHeight = windowHeight - bottom;

    if (remainingHeight < neededHeight) {
      $('body,html').animate({ scrollTop: Math.min(offsetTop - 30, windowScroll + (neededHeight - remainingHeight)) }, 800);
    }
  }

  function filterPeople(result) {
    for (var i = 0, ii = result.length; i < ii; i++) {
      result[i].dateOfBirth = parseDate(result[i].dateOfBirth);
      result[i].dateOfDeath = parseDate(result[i].dateOfDeath);
    }

    return result;
  }

  function isBlank(str) {
    return !str || /^\s*$/.test(str);
  }

  function parseDates(obj) {
    if (!obj) {
      return null;
    }

    obj.formatted_dates = [];
    obj.sorting_date = parseDate(obj.sorting_date);
    obj.formatted_sorting_date = formatDate(obj.sorting_date);

    for (var i = 0, ii = obj.dates.length; i < ii; i++) {
      obj.dates[i] = parseDate(obj.dates[i]);
      obj.formatted_dates.push(formatDate(obj.dates[i]));
    }

    return obj;
  }

  function parseDate(str) {
    var range, c;

    if (!str) {
      return str;
    }

    if (typeof str === "object" && str.first && str.last) {
      return [parseDate(str.first), parseDate(str.last)];
    } else if (typeof str === "string" && /\.\./.test(str)) {
      range = str.split("..", 2);

      return [parseDate(range[0]), parseDate(range[1])];
    } else {
      if (/\d\.\d/.test(str)) {
        c = str.split(".", 3);

        return new Date(Date.parse(c[2] + "-" + c[1] + "-"+ c[0]));
      } else if (/\d\/\d/.test(str)) {
        c = str.split("/", 3);

        return new Date(Date.parse(c[2] + "-" + c[0] + "-"+ c[1]));
      } else {
        return new Date(Date.parse(str));
      }
    }
  }

  function formatDate(date) {
    if (date.length == 2) {
      return formatDate(date[0]) + "&nbsp;...&nbsp;" + formatDate(date[1]);
    }

    var d = date.getDate(), m = date.getMonth(), y = date.getFullYear();
    m++;

    if (d < 10) {
      d = '0' + d;
    }

    if (m < 10) {
      m = '0' + m;
    }

    if (i18n.locale == "de") {
      return d + "." + m + "." + y;
    } else {
      return m + "/" + d + "/" + y;
    }
  }

  function round(x, n) {
    var a = Math.pow(10, n);
    return Math.round(x * a) / a;
  }

  function flattenArray(array) {
    return $.map(array, function(n) { return n; });
  }

  function sortDateArray(dates) {
    return dates.sort(function(a, b) {
      if (a < b) { return -1; }
      if (a > b) { return 1; }
      return 0;
    })
  }

  function checkSenderName(primary) {
    var errors = [];

    if (!primary && !senderName || isBlank(senderNameInput.val())) {
      return;
    }

    if (senderName) {
      if (recipientName) {
        if (senderName.token === recipientName.token) {
          errors.push(_t("letters.form.sender_and_recipient_are_the_same_person"));
        }

        if (recipientName.dateOfDeath && senderName.dateOfBirth > recipientName.dateOfDeath) {
          errors.push(_t("letters.form.sender_was_born_after_recipient_died"));
        }

        if (senderName.dateOfDeath && senderName.dateOfDeath < recipientName.dateOfBirth) {
          errors.push(_t("letters.form.sender_died_before_recipient_was_born"));
        }
      }
    } else {
      primary && errors.push(_t("letters.form.unrecognized_name_html"));
    }

    if (errors.length) {
      senderNamePopoverTitle = _t("error");
      senderNamePopoverContent = errors[0];
      senderNameIcon.setClass('icon-exclamation-sign icon-input icon-input-error');
    } else {
      senderNamePopoverTitle = senderName.name;
      senderNamePopoverContent = personPopoverTemplate.render(senderName);
      senderNameIcon.setClass('icon-ok-sign icon-input icon-input-success');
    }

    if (primary) {
      checkRecipientName(false);
      checkDateOfWriting(false);
    }
  }

  function checkSenderAddress(primary) {
    var ac, errors = [];

    if (senderAddressInput.placepicker("isFlyoutVisible")) {
      return;
    }

    if (isBlank(senderAddressInput.val())) {
      return;
    }

    if (!senderAddress) {
      errors.push(_t("letters.form.unrecognized_address_html"));
    }

    if (errors.length) {
      senderAddressPopoverTitle = _t("error");
      senderAddressPopoverContent = errors[0];
      senderAddressIcon.setClass('icon-exclamation-sign icon-input icon-input-error');
    } else {
      senderAddressPopoverTitle = _t("letters.form.address");
      senderAddressPopoverContent = addressPopoverTemplate.render(senderAddress);
      senderAddressIcon.setClass('icon-ok-sign icon-input icon-input-success');
    }
  }

  function checkRecipientName(primary) {
    var errors = [];

    if (!primary && !recipientName || isBlank(recipientNameInput.val())) {
      return;
    }

    if (recipientName) {
      if (senderName) {
        if (recipientName.token === senderName.token) {
          errors.push(_t("letters.form.recipient_and_sender_are_the_same_person"));
        }

        if (senderName.dateOfDeath && recipientName.dateOfBirth > senderName.dateOfDeath) {
          errors.push(_t("letters.form.recipient_was_born_after_sender_died"));
        }

        if (recipientName.dateOfDeath && recipientName.dateOfDeath < senderName.dateOfBirth) {
          errors.push(_t("letters.form.recipient_died_before_sender_was_born"));
        }
      }
    } else {
      primary && errors.push(_t("letters.form.unrecognized_name_html"));
    }

    if (errors.length) {
      recipientNamePopoverTitle = _t("error");
      recipientNamePopoverContent = errors[0];
      recipientNameIcon.setClass('icon-exclamation-sign icon-input icon-input-error');
    } else {
      recipientNamePopoverTitle = recipientName.name;
      recipientNamePopoverContent = personPopoverTemplate.render(recipientName);
      recipientNameIcon.setClass('icon-ok-sign icon-input icon-input-success');
    }

    primary && checkSenderName(false);
  }

  function checkRecipientAddress(primary) {
    var errors = [];

    if (isBlank(recipientAddressInput.val())) {
      return;
    }

    if (!recipientAddress) {
      errors.push(_t("letters.form.unrecognized_address_html"));
    }

    if (errors.length) {
      recipientAddressPopoverTitle = _t("error");
      recipientAddressPopoverContent = errors[0];
      recipientAddressIcon.setClass('icon-exclamation-sign icon-input icon-input-error');
    } else {
      recipientAddressPopoverTitle = _t("letters.form.address");
      recipientAddressPopoverContent = addressPopoverTemplate.render(recipientAddress);
      recipientAddressIcon.setClass('icon-ok-sign icon-input icon-input-success');
    }
  }

  function checkDateOfWriting(primary) {
    var date, dates, first, last, errors = [], val = $.trim(dateOfWritingInput.val()), size = val.length;

    if (size == 0) {
      return;
    }

    dateOfWritingIcon.setClass('icon-spinner icon-input icon-input-wait');

    if (dateOfWriting && dateOfWriting.dates.length > 0) {
      if (senderName) {
        dates = sortDateArray(flattenArray(dateOfWriting.dates));

        first = dates[0];
        last  = dates[dates.length - 1];

        if (last < senderName.dateOfBirth) {
          errors.push(_t("letters.form.sender_was_born_after_date_of_writing"));
        }

        if (senderName.dateOfDeath && first > senderName.dateOfDeath) {
          errors.push(_t("letters.form.sender_died_before_date_of_writing"));
        }
      }
    } else {
      errors.push(_t("letters.form.unrecognized_dating_html"));
    }

    if (errors.length) {
      dateOfWritingPopoverTitle = _t("error");
      dateOfWritingPopoverContent = errors[0];
      dateOfWritingIcon.setClass('icon-exclamation-sign icon-input icon-input-error');
    } else {
      dateOfWritingPopoverTitle = _t("letters.form.dating");
      dateOfWritingPopoverContent = datingPopoverTemplate.render(dateOfWriting);
      dateOfWritingIcon.setClass('icon-ok-sign icon-input icon-input-success');
    }

    primary && checkSenderName(false);
  }
});
