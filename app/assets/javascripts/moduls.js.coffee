# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("form").change ->
    $(this).submit();

$ ->
  $("[lvid]").click (e) ->
    if localStorage["selected_lvs"]
      selected_lvs = JSON.parse(localStorage["selected_lvs"]);
    else
      selected_lvs = { };
    lvid = $(this).attr("lvid")
    if selected_lvs[lvid] and selected_lvs[lvid] is "true"
      delete selected_lvs[lvid]
      $(this).attr("lvselected", "false")
    else
      selected_lvs[lvid] = "true"
      $(this).attr("lvselected", "true")
    localStorage["selected_lvs"] = JSON.stringify(selected_lvs);

$ ->
  if localStorage["selected_lvs"]
    selected_lvs = JSON.parse(localStorage.getItem("selected_lvs"));
    for lvid, value of selected_lvs
      $("[lvid='"+lvid+"']").attr("lvselected", "true")
  else
    selected_lvs = { };
    localStorage.setItem("selected_lvs", JSON.stringify(selected_lvs));
