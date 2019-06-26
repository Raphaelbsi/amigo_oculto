$(document).on 'turbolinks:load', ->
  $('.datepicker').datepicker({
    showMonthAfterYear: true,
    yearRange: 5,
    clear: 'Clear',
    autoClose: true,
    format: 'dd/mm/yyyy'
  });
  return