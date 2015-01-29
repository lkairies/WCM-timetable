$ ->
  $(".wochenplan_form").submit ->
    semester = $(this).find('#semester').attr('value')
    if localStorage["selected_lvs"]
      selected_semester_lvs = JSON.parse(localStorage["selected_lvs"])[semester];
      lvs = []
      for lv, selected of selected_semester_lvs
        if selected
          lvs.push(lv)
      $("#lvs").prop("value", lvs.join(","))
