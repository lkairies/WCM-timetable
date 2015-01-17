$ ->
  $("#wochenplan_form").submit ->
    if localStorage["selected_lvs"]
      selected_lvs = JSON.parse(localStorage["selected_lvs"]);
      lvs = []
      for lv, selected of selected_lvs
        if selected
          lvs.push(lv)
      $("#lvs").prop("value", lvs.join(","))
