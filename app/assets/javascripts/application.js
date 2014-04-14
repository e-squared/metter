//= require jquery
//= require jquery_ujs
//= require jquery-ext
//= require serializeobject
//= require bootstrap-alert
//= require bootstrap-button
//= require bootstrap-tooltip
//= require bootstrap-popover
//= require bootstrap-transition
//= require bootstrap-modal
//= require bootstrap-dropdown
//= require slider
//= require datepicker
//= require personpicker
//= require placepicker
//= require datingpicker
//= require i18n
//= require letters

$(function() {
  // set the focus on the first form element, if available
  $('form input:not([type=hidden]), form textarea, form select').first().focus();

  // disable browser validation of form elements
  $('form').prop('noValidate', true);

  // enhancements for array field inputs
  $(document).on('click', '.btn-input-remove', function() {
    $(this).parent().remove();
    return false;
  });

  $('.btn-input-add').on('click', function() {
    var
      self = $(this),
      input = self.prev().clone();

    self.before(input);
    input.find('input').val('');

    return false;
  });

  $('.slider').slider();
});
