# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("#modulsfilter_form").change ->
    $(this).submit();

$ ->
  $("[lvid]").click (e) ->
    lvid = $(this).attr("lvid")
    semester = $(this).closest('[data-semester]').data('semester')
    lvStorageKey = "selected_lvs"
    if localStorage[lvStorageKey]
      selected_lvs = JSON.parse(localStorage[lvStorageKey]);
    else
      #use a hash for storage, because it's easier to remove items from a hash than from an array
      selected_lvs = { }

    if !selected_lvs[semester]
      selected_lvs[semester] = { }

    if selected_lvs[semester][lvid] and selected_lvs[semester][lvid] is true
      delete selected_lvs[semester][lvid]
      $(this).attr("lvselected", "false")
    else
      selected_lvs[semester][lvid] = true
      $(this).attr("lvselected", "true")
    localStorage[lvStorageKey] = JSON.stringify(selected_lvs);

# initialize selected lvs on page load
$ ->
  for semester, selected_semester_lvs of JSON.parse(localStorage["selected_lvs"])
    for lvid, value of selected_semester_lvs
      $("[lvid='"+lvid+"']").attr("lvselected", "true")

$ ->
  if $.fn.dataTable
    if !$.fn.dataTable.isDataTable( '#module-table' )
      $('#module-table').DataTable( {
        paging: false
      } )
