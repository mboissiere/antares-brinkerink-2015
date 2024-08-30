library(dplyr)
library(tidyr)
library(ggplot2)

source(".\\src\\antaresReadResults_aux\\colorPalettes.R")

saveLoadMonotone <- function(output_dir,
                             mode, # "global", "continental", "national" or "regional"
                             unit,
                             timestep = "hourly"
) {
  
  antares_data <- getAntaresDataByMode(timestep, mode)
  # Argh c'est relou les modes en vraiiii
  antares_tbl <- as_tibble(antares_data)
  
  convertAntaresMWhToUnit(antares_data, unit)
  
  folder_name <- graphs_folder_names_by_mode[[mode]]
  
  load_monot_dir <- file.path(global_dir, folder_name, "Load monotones")
  
  if (!dir.exists(load_monot_dir)) {
    dir.create(load_monot_dir, recursive = TRUE)
  }
  
  data_lst <- data_to_iterate_by_mode[[mode]]
  
  antares_tbl <- antares_tbl %>%
    filter(area %in% data_lst)
  # Argh c'est relou les modes en vraiiii x2
  # là ça changeait entre area et district.......
  
  # bon time to faire un truc d'énorme schlagos
  # (finalement j'ai coupé le truc à la racine, dans getAntaresData)
  
  antares_tbl_sorted <- antares_tbl[order(-antares_tbl$LOAD), ] %>%
    select(timeId, time, LOAD, ENERGY_SOURCE_COLUMNS)
  
  antares_tbl_succint <- adaptAntaresVariables(antares_tbl_sorted)
  
  antares_tbl_long <- antares_tbl_succint %>%
    select(time, LOAD, RENAMED_ENERGY_SOURCE_COLUMNS) %>%
    pivot_longer(cols = RENAMED_ENERGY_SOURCE_COLUMNS, names_to = "energy_source", values_to = "production")
  
  antares_tbl_long$energy_source <- factor(antares_tbl_long$energy_source, levels = rev(RENAMED_ENERGY_SOURCE_COLUMNS))
  

  antares_tbl_long <- antares_tbl_long %>%
    mutate(percent_time = (row_number() - 1) / (n() - 1) * 100)
  
  max_value <- max(antares_tbl_long$LOAD)
  min_value <- min(antares_tbl_long$LOAD)
  
  max_index <- 1
  min_index <- 100
  
  for (item in data_lst) {
    p <- ggplot(antares_tbl_long, aes(x = percent_time)) +
      geom_area(aes(y = production, fill = energy_source), position = "stack") +
      geom_step(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +
      scale_fill_manual(values = renamedProdStackWithBatteries_lst) +
      labs(x = "% of time", y = paste0("Production (", unit, ")"), fill = paste(item, "energy mix")) +
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
  
  
  
  msg = "[MAIN] - Done saving global load monotone!" 
  logMain(msg)
}


# saveGlobalLoadMonotone <- function(output_dir,
#                                    timestep = "hourly"
# ) {
#   msg = "[MAIN] - Preparing to save global load monotone..."
#   logMain(msg)
#   
#   global_data <- getGlobalAntaresData(timestep)
#   global_tbl <- as_tibble(global_data)
#   
#   global_dir <- file.path(output_dir, "Graphs", "1 - Global-level graphs")
#   
#   load_monot_dir <- file.path(global_dir, "Load monotones")
#   
#   if (!dir.exists(load_monot_dir)) {
#     dir.create(load_monot_dir, recursive = TRUE)
#   }
#   
#   world <- getDistricts(select = "world", regexpSelect = FALSE)
#   #print(continents)
#   
#   # unit = "GWh"
#   
#   glob_tbl <- global_tbl %>%
#     filter(district == "world")
#   
#   glob_tbl_sorted <- glob_tbl[order(-glob_tbl$LOAD), ] %>%
#     select(timeId, time, LOAD, sources)
#   
#   glob_tbl_succint <- adaptAntaresVariables(glob_tbl_sorted)
#   
#   glob_tbl_long <- glob_tbl_succint %>%
#     select(time, LOAD, sources_new) %>%
#     pivot_longer(cols = sources_new, names_to = "energy_source", values_to = "production")
#   
#   glob_tbl_long$energy_source <- factor(glob_tbl_long$energy_source, levels = rev(sources_new))
#   
#   
#   # Calculate the percentage of time
#   glob_tbl_long <- glob_tbl_long %>%
#     mutate(percent_time = (row_number() - 1) / (n() - 1) * 100)
#   # Ah but this is incorrect because it uses long and so it's like ??? Uh??
#   
#   # # A tibble: 148,512 x 5
#   # time                   LOAD energy_source production percent_time
#   # <dttm>                <dbl> <fct>              <dbl>        <dbl>
#   #   1 2015-01-08 13:00:00 3152131 NUCLEAR           369183     0       
#   # 2 2015-01-08 13:00:00 3152131 WIND               66367     0.000673
#   # 3 2015-01-08 13:00:00 3152131 SOLAR              52667     0.00135 
#   # 4 2015-01-08 13:00:00 3152131 GEOTHERMAL         13178     0.00202 
#   # 5 2015-01-08 13:00:00 3152131 HYDRO             551312     0.00269 
#   # 6 2015-01-08 13:00:00 3152131 BIO AND WASTE     107908     0.00337 
#   # 7 2015-01-08 13:00:00 3152131 GAS               468406     0.00404 
#   # 8 2015-01-08 13:00:00 3152131 COAL             1449232     0.00471 
#   # 9 2015-01-08 13:00:00 3152131 OIL                63354     0.00539 
#   # 10 2015-01-08 13:00:00 3152131 OTHER               6903     0.00606 
#   
#   # print(glob_tbl_sorted)
#   # print(glob_tbl_long)
#   
#   # Assuming glob_tbl_sorted is already calculated as before
#   max_value <- max(glob_tbl_long$LOAD)
#   min_value <- min(glob_tbl_long$LOAD)
#   
#   # Indexes for maximum and minimum positions
#   max_index <- 1  # Since the data is sorted in descending order
#   min_index <- 100 #I mean maybe coz we have percentages ?
#   # Very experimental stuff here
#   
#   p <- ggplot(glob_tbl_long, aes(x = percent_time)) +
#     # geom_bar(aes(y = production, fill = energy_source), stat = "identity") +
#     geom_area(aes(y = production, fill = energy_source), position = "stack") +  # Stacked area for energy sources
#     #geom_line(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +
#     geom_step(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +  # Load duration curve as a step function
#     scale_fill_manual(values = renamedProdStackWithBatteries_lst) +
#     labs(x = "Percentage of Time (%)", y = "Production (MWh)", fill = "world energy mix") +
#     # bcp de choses ici qui dépendent de unit, ce serait bien de le streamline...
#     theme_minimal() +
#     theme(
#       legend.position = "right",
#       legend.text = element_text(size = 8), # Legend text size
#       legend.title = element_text(size = 10), # Legend title size
#       legend.key.size = unit(0.4, "cm"), # Size of the legend keys
#       legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
#       legend.margin = margin(0, 0, 0, 0), # Margin around the legend
#       legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box
#       
#       axis.title.x = element_text(size = 10), # X-axis title size
#       axis.title.y = element_text(size = 10), # Y-axis title size
#       
#       axis.text.x = element_text(size = 8), # X-axis labels size
#       axis.text.y = element_text(size = 8)  # Y-axis labels size
#     ) +
#     # Add annotations for the maximum and minimum values
#     annotate("text", x = max_index, y = max_value, label = paste("Peak:", round(max_value, 2)), 
#              vjust = -1, hjust = 0, color = "black", size = 3) +  # Adjust vjust/hjust as needed
#     annotate("text", x = min_index, y = max_value, label = paste("Base:", round(min_value, 2)), # y = min_value before, but not as convenient
#              vjust = 1, hjust = 1, color = "black", size = 3)
#   
#   # One thing is odd. In the load monotone, the peak is at 315..., but in the daily stack,
#   # value doesn't seem to be at 3.1
#   # maybe I would have to get an hourly graph to truly truly verify it. It's not like it's completely stupid.
#   # But this whole "get the daily but divide by 24" might create some averaging shenanigans and confusion.
#   
#   plot_path <- file.path(load_monot_dir, "world_monotone.png")
#   ggsave(filename = plot_path, plot = p, 
#          width = width_pixels/resolution_dpi, height = height_pixels/resolution_dpi,
#          dpi = resolution_dpi)
#   
#   msg = "[MAIN] - Done saving global load monotone!" 
#   logMain(msg)
# }