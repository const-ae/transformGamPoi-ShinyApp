div_with_floating_gear <- function(panel, menu_content){
  div(class = "floating_gear_holder",
      div(class = "floating_gear", shinyWidgets::dropdownButton(menu_content, icon = icon("cog", lib = "glyphicon"), size = "sm", right = TRUE)),
      panel)
}