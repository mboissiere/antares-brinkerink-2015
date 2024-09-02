library(ggplot2)

saveImportExportRanking <- function(output_dir) {
  
  national_data <- getNationalAntaresData("annual")
  
  folder_name <- graphs_folder_names_by_mode["national"]
  
  ranking_dir <- file.path(output_dir, folder_name, "Import-Export Ranking")
  
  if (!dir.exists(ranking_dir)) {
    dir.create(ranking_dir, recursive = TRUE)
  }
  
  national_tbl <- as_tibble(national_data)
  
  national_tbl <- national_tbl %>%
    mutate(BALANCE_TWH = BALANCE/MWH_IN_TWH,
           EXPORT_TWH = -BALANCE_TWH,
           Status = ifelse(BALANCE > 0, "Export", "Import"))
  
  national_tbl <- national_tbl %>%
    filter(BALANCE_TWH != 0)
  
  national_tbl <- national_tbl %>%
    arrange(EXPORT_TWH)

  p <- ggplot(national_tbl, aes(x = reorder(area, EXPORT_TWH), y = BALANCE_TWH, fill = Status)) +
    geom_bar(stat = "identity", width = 0.8) +  
    scale_fill_manual(values = c("Export" = "green", "Import" = "red")) +
    labs(x = "Country", y = "Export (TWh)", title = "Country Export/Import Balance") +
    scale_y_continuous(sec.axis = dup_axis(name = "Export (TWh)")) +  # Duplicate y-axis on the right
    geom_text(aes(label = ifelse(abs(BALANCE_TWH) >= 10, round(BALANCE_TWH, 0), round(BALANCE_TWH, 1))),
              vjust = ifelse(national_tbl$BALANCE_TWH > 0, -0.5, 1.5),  # Position labels above or below the bars
              hjust = 0.5,  # Center the text horizontally
              size = 2) +  # Adjust size as needed
    
    geom_vline(xintercept = seq(1.5, nrow(national_tbl) - 0.5, by = 1), color = "grey90", linetype = "solid") +  # Vertical lines for readability
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, margin = margin(t = 0, r = 5, b = 0, l = -5)),  # Adjusting text position
          axis.ticks.x = element_blank(), 
          legend.position = "none",
          
          panel.grid.major.x = element_line(color = "grey90", linetype = "dotted", size = 0.5),
          axis.title.y.right = element_text(margin = margin(l = 10)))  # Add space between axis and text
  
  plot_path <- file.path(ranking_dir, "allCountries.png")
  ggsave(filename = plot_path, plot = p, 
         width = importexport_width/importexport_resolution, height = importexport_height/importexport_resolution,
         dpi = importexport_resolution)
  # Maybe I could just directly do the division in importexport_width... But less control in parameters
}