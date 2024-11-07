library(dplyr)
library(tidyr)
library(ggplot2)

source(".\\src\\antaresReadResults_aux\\colorPalettes.R")

saveLoadMonotone <- function(output_dir,
                             mode, # "global", "continental", "national" or "regional"
                             unit = "MWh",
                             timestep = "hourly",
                             monotone_palette_lst = eCO2MixFusion_lst
) {
  
  if (READ_2060) {
    antares_tbl <- getGlobalAntaresData("hourly", FALSE)
  } else {
    antares_data <- getAntaresDataByMode(timestep, mode)
    
    antares_tbl <- as_tibble(antares_data)
  }
  
  
  folder_name <- graphs_folder_names_by_mode[[mode]]
  
  load_monot_dir <- file.path(output_dir, folder_name, "Load monotones")
  
  if (!dir.exists(load_monot_dir)) {
    dir.create(load_monot_dir, recursive = TRUE)
  }
  
  data_lst <- data_to_iterate_by_mode[[mode]]
  
  max_index <- 1
  min_index <- 100
  
  for (item in data_lst) {
    item_tbl <- antares_tbl %>%
      filter(area == item)
    
    item_tbl_sorted <- item_tbl[order(-item_tbl$LOAD), ] %>%
      select(timeId, time, LOAD, all_of(ENERGY_SOURCE_COLUMNS))
    
    item_tbl_succint <- adaptAntaresVariables(item_tbl_sorted)
    
    item_tbl_long <- item_tbl_succint %>%
      select(time, LOAD, all_of(RENAMED_ENERGY_SOURCE_COLUMNS)) %>%
      pivot_longer(cols = RENAMED_ENERGY_SOURCE_COLUMNS, names_to = "energy_source", values_to = "production")
    
    item_tbl_long$energy_source <- factor(item_tbl_long$energy_source, levels = rev(RENAMED_ENERGY_SOURCE_COLUMNS))
    
    
    item_tbl_long <- item_tbl_long %>%
      mutate(percent_time = (row_number() - 1) / (n() - 1) * 100)
    
    max_value <- max(item_tbl_long$LOAD)
    min_value <- min(item_tbl_long$LOAD)
    
    
    p <- ggplot(item_tbl_long, aes(x = percent_time)) +
      geom_area(aes(y = production, fill = energy_source), position = "stack") +
      geom_step(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +
      scale_fill_manual(values = monotone_palette_lst) + 
      labs(x = "% of time", y = paste0("Production (MWh)"), fill = paste(item, "energy mix")) +
      # avant il y avait unit ici mais c'était faux donc j'ai remis des bon vieux MWh hop
      # bcp de choses ici qui dépendent de unit, ce serait bien de le streamline...
      theme_minimal() +
      theme(
        legend.position = "right",
        legend.text = element_text(size = 8), # Legend text size
        legend.title = element_text(size = 10), # Legend title size
        legend.key.size = unit(0.4, "cm"), # Size of the legend keys
        legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
        legend.margin = margin(0, 0, 0, 0), # Margin around the legend
        legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box
        
        axis.title.x = element_text(size = 10), # X-axis title size
        axis.title.y = element_text(size = 10), # Y-axis title size
        
        axis.text.x = element_text(size = 8), # X-axis labels size
        axis.text.y = element_text(size = 8)  # Y-axis labels size
      ) +
      # Add annotations for the maximum and minimum values
      annotate("text", x = max_index, y = max_value, label = paste("Peak:", round(max_value, 2)), 
               vjust = -1, hjust = 0, color = "black", size = 3) +  # Adjust vjust/hjust as needed
      annotate("text", x = min_index, y = max_value, label = paste("Base:", round(min_value, 2)), # y = min_value before, but not as convenient
               vjust = 1, hjust = 1, color = "black", size = 3)
    
    msg = paste("[MONOT] - Saving", timestep, "load monotone for", item, "node...")
    logFull(msg)
           plot_path <- file.path(load_monot_dir, paste0(item, "_monotone.png"))
           ggsave(filename = plot_path, plot = p, 
                  width = monotone_width/monotone_resolution, height = monotone_height/monotone_resolution,
                  dpi = monotone_resolution)
           msg = paste("[MONOT] - The", timestep, "load monotone for", item, "has been saved!")
           logFull(msg)
  }
}
