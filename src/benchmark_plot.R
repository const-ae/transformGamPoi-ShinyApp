

benchmarkPlotUI <- function(id) {
  tagList(
    div_with_floating_gear(
      shinycssloaders::withSpinner(plotOutput(NS(id, "benchmark"), height = "450px"), 4, hide.ui = FALSE),
      menu_content = tagList(
        shinyWidgets::awesomeCheckbox(NS(id, "zoom_in"), "zoom in"),
        shinyWidgets::awesomeCheckbox(NS(id, "relative_knn"), "Relative"),
        shinyWidgets::radioGroupButtons(NS(id, "metric"), choices = c("overlap", "ARI", "AMI", "NMI"), selected = "overlap"),
      )
    )
  )
}

benchmarkPlotServer <- function(id, data, pcadim_sel = reactive(NULL), knn_sel = reactive(NULL), alpha_sel = reactive(NULL), dataset_sel = reactive(NULL)) {
  stopifnot(is.data.frame(data))
  stopifnot(all(c("pca_dim", "knn", "dataset", "transformation", "replicate", "overlap", "AMI", "ARI", "NMI") %in% colnames(data)))
  stopifnot(is.reactive(pcadim_sel))
  stopifnot(is.reactive(knn_sel))
  stopifnot(is.reactive(alpha_sel))
  stopifnot(is.reactive(dataset_sel))
  
  data <- pivot_longer(data, c(overlap, ARI, AMI, NMI), names_to = "metric", values_to = "value")
  
  moduleServer(id, function(input, output, session) {
    
    
    filtered_dat <- reactive({
      filtered_dat <- data 
      filtered_dat <- filter_data_with_pca_sel(filtered_dat, pcadim_sel())
      filtered_dat <- filter_data_with_dataset_sel(filtered_dat, dataset_sel())
      if(! is.null(input$metric)) filtered_dat <- filter(filtered_dat, metric == input$metric)
      if(! is.null(knn_sel())) filtered_dat <- filter(filtered_dat, knn == knn_sel())
      if(! is.null(alpha_sel())) filtered_dat <- filter(filtered_dat, alpha %in% alpha_sel())
      filtered_dat
    })
    
    output$benchmark <- renderPlot({
      if(nrow(filtered_dat()) == 0){
        
      }else if(input$relative_knn){
        dat <- filtered_dat() %>%
          group_by(dataset, knn, pca_dim, replicate) %>%
          mutate(reference_performance = mean(value)) %>%
          mutate(value = value / reference_performance) %>%
          left_join(trans_families, by = "transformation")
        
        label <- switch(input$metric,
                        overlap = "k-NN Overlap",
                        ARI = "Adjusted Rand Index",
                        AMI = "Adjusted Mututal Information",
                        NMI = "Normalized Mututal Information")
        
        ggplot(dat, aes(x = value, y = transformation, color = family, shape = alpha)) +
          geom_vline(xintercept = 1, size = 0.3, linetype = 2) +
          ggbeeswarm::geom_quasirandom(color = "grey", size = 0.3, alpha = 0.7, groupOnX = FALSE) +
          stat_summary(geom = "point", fun = mean, size = 1.8) +
          scale_y_grouped_discrete(grouping = ~ trans_families_labels[deframe(trans_families)[.x]], gap_size = 1.7, limits = rev,
                                   labels = trans_labels_plain, add_group_label = TRUE) +
          scale_color_manual(values = trans_families_colors, labels = trans_families_labels, guide = "none") +
          (if(input$zoom_in) scale_x_continuous(limits = range(pull(dat, value)))
           else scale_x_continuous(limits = c(min(0.2, pull(dat, value)), max(1.8, pull(dat, value))),
                                   breaks = c(0.5, 1.0, 1.5))) +
          labs(y = "", x = paste0("Relative ", label), shape = "Overdispersion")+
          theme_grouped_axis(axis.grouping.line_padding = unit(5, "points"))
        
      }else{
        dat <- filtered_dat()  %>%
          left_join(trans_families, by = "transformation")
        label <- switch(input$metric,
                        overlap = "k-NN Overlap",
                        ARI = "Adjusted Rand Index",
                        AMI = "Adjusted Mututal Information",
                        NMI = "Normalized Mututal Information")
        
        ggplot(dat, aes(x = value, y = transformation, color = family, shape = alpha, group = paste0(transformation,"-", alpha))) +
          ggbeeswarm::geom_quasirandom(color = "grey", size = 0.3, alpha = 0.7, groupOnX = FALSE) +
          stat_summary(geom = "point", fun = mean, size = 1.8) +
          scale_y_grouped_discrete(grouping = ~ trans_families_labels[deframe(trans_families)[.x]], gap_size = 1.7, limits = rev,
                                   labels = trans_labels_plain, add_group_label = TRUE) +
          scale_color_manual(values = trans_families_colors, labels = trans_families_labels, guide = "none") +
          (if(input$zoom_in) scale_x_continuous(limits = range(pull(dat, value)))
           else scale_x_continuous(limits = c(0, dat$knn[1])))+
          labs(y = "", x = label, shape = "Overdispersion") +
          theme_grouped_axis(axis.grouping.line_padding = unit(5, "points"))
      }
    }, res = 96)
  })
}




benchmarkPlotApp <- function() {
  ui <- fluidPage(
    includeCSS("www/main.css"),
    benchmarkPlotUI("consistency_benchmark"),
    optionPaneUI("consistency_pca_sel", show_detailed_pcadim_selector = TRUE),
  )
  server <- function(input, output, session) {
    op <- optionPaneServer("consistency_pca_sel", data = res, metric = overlap, knn_sel = 50, pca_sel = 50)
    benchmarkPlotServer("consistency_benchmark", data = res, pcadim_sel = op$pca_sel, 
                        knn_sel = op$knn_sel, alpha_sel = op$alpha_sel, dataset_sel = op$dataset_sel)
  }
  shinyApp(ui, server)  
}
benchmarkPlotApp()
