#####################
## GENERATION

library(ggplot2)

saveContinentalGenerationHistograms <- function(output_dir,
                                                timestep = "annual"
) {
  
  continental_data <- getContinentalAntaresData(timestep)
  continental_tbl <- as_tibble(continental_data)
  # print(continental_tbl)
  
  folder_name <- graphs_folder_names_by_mode["continental"]
  
  genr_histo_dir <- file.path(output_dir, folder_name, "Generation histograms")
  
  if (!dir.exists(genr_histo_dir)) {
    dir.create(genr_histo_dir, recursive = TRUE)
  }
  # print(genr_histo_dir)
  
  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
  # funny that
  # print(continents)
  
  continental_tbl <- continental_tbl %>%
    # Rename variables
    rename(`Bio and Waste` = `MIX. FUEL`,
           Coal = COAL,
           Gas = GAS,
           Geothermal = `MISC. DTG`,
           Hydro = `H. STOR`,
           Nuclear = NUCLEAR, 
           Oil = OIL,
           Solar = SOLAR,
           Wind = WIND
    ) %>%
    mutate(across(all_of(new_deane_result_variables), ~ . / MWH_IN_TWH)) %>% # convert to TWh
    select(area, new_deane_result_variables)
  
  continental_long_tbl <- continental_tbl %>%
    pivot_longer(cols = all_of(new_deane_result_variables), 
                 names_to = "Technology", 
                 values_to = "Generation") %>%
    mutate(Technology = factor(Technology, levels = new_deane_result_variables))
  
  for (cont in continents) {
    
    cont_tbl <- continental_long_tbl %>%
      filter(area == cont)
    
    p <- ggplot(cont_tbl, aes(x = Technology, y = Generation, fill = Technology)) +
      geom_bar(stat = "identity", position = "dodge", color = "#334D73") +
      
      geom_text(aes(label = round(Generation, 2)), 
                vjust = -0.5, # Adjusts the vertical position of the text
                color = "black", 
                size = 3.5) + # Adjust the size as needed
      
      scale_fill_manual(values = deane_technology_colors) +
      labs(title = paste("Generation comparison", cont, "(TWh)"),
           #x = "Technology",
           y = "TWh") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "none")
    
    msg = paste("[HISTO] - Saving generation histograms for", cont, "continent...")
    logFull(msg)
    png_path = file.path(genr_histo_dir, paste0(cont, "_generation.png"))
    ggsave(filename = png_path, plot = p, 
           width = 2*HEIGHT_720P/DPI_300, height = 2*HEIGHT_720P/DPI_300,
           dpi = DPI_300)
    msg = paste("[HISTO] - Done saving generation histograms for", cont, "continent !")
    logFull(msg)
  }
}

##############################

## WITH DEANE COMPARISON
source(".\\src\\utils.R")

benchmark_generation_values_twh <- tibble(
  area = c("africa", "asia", "europe", "north america", "oceania", "south america"),
  `Bio and Waste` = c(2, 155, 205, 100, 4, 62),
  Coal = c(255, 6547, 930, 1576, 160, 67),
  Gas = c(285, 2746, 576, 1643, 59, 229),
  Geothermal = c(4, 28, 12, 29, 8, 0),
  Hydro = c(124, 1866, 609, 706, 39, 647),
  Nuclear = c(12, 623, 971, 943, 0, 22),
  Oil = c(81, 580, 64, 125, 7, 87),
  Solar = c(3, 94, 110, 38, 6, 2),
  Wind = c(8, 241, 306, 229, 14, 27)
  # Other technologies...
)

plexos_generation_values_twh <- tibble(
  area = c("africa", "asia", "europe", "north america", "oceania", "south america"),
  `Bio and Waste` = c(2, 138, 203, 100, 4, 60),
  Coal = c(255, 6551, 921, 1578, 161, 67),
  Gas = c(341, 2595, 675, 1634, 60, 222),
  Geothermal = c(4, 28, 11, 29, 8, 0),
  Hydro = c(120, 1869, 610, 706, 39, 646),
  Nuclear = c(12, 623, 971, 944, 0, 22),
  Oil = c(39, 497, 57, 124, 9, 59),
  Solar = c(3, 94, 109, 38, 6, 2),
  Wind = c(8, 240, 305, 229, 14, 27)
  # Other technologies...
)

# print(deane_generation_values_twh)

saveGenerationDeaneComparison <- function(output_dir,
                                          timestep = "annual",
                                          benchmark_values = benchmark_generation_values_twh,
                                          plexos_values = plexos_generation_values_twh
) {
  
  # Get the observed data
  continental_data <- getContinentalAntaresData(timestep)
  continental_tbl <- as_tibble(continental_data)
  
  folder_name <- graphs_folder_names_by_mode["continental"]
  genr_histo_dir <- file.path(output_dir, folder_name, "Generation histograms")
  
  if (!dir.exists(genr_histo_dir)) {
    dir.create(genr_histo_dir, recursive = TRUE)
  }
  
  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
  
  # Rename variables in observed data and calculate values
  continental_tbl <- continental_tbl %>%
    rename(`Bio and Waste` = `MIX. FUEL`,
           Coal = COAL,
           Gas = GAS,
           Geothermal = `MISC. DTG`,
           Hydro = `H. STOR`,
           Nuclear = NUCLEAR, 
           Oil = OIL,
           Solar = SOLAR,
           Wind = WIND
    ) %>%
    mutate(across(all_of(new_deane_result_variables), ~ . / MWH_IN_TWH)) %>%
    select(area, new_deane_result_variables)
  
  # Reshape the observed data into long format
  antares_long_tbl <- continental_tbl %>%
    pivot_longer(cols = all_of(new_deane_result_variables), 
                 names_to = "Technology", 
                 values_to = "Generation") %>%
    mutate(Type = "TWh Antares")
  
  # Reshape the theoretical data into long format
  benchmark_long_tbl <- benchmark_values %>%
    pivot_longer(cols = all_of(new_deane_result_variables), 
                 names_to = "Technology", 
                 values_to = "Generation") %>%
    mutate(Type = "TWh Benchmark")
  
  plexos_long_tbl <- plexos_values %>%
    pivot_longer(cols = all_of(new_deane_result_variables), 
                 names_to = "Technology", 
                 values_to = "Generation") %>%
    mutate(Type = "TWh PLEXOS")
  
  
  # # Combine observed and theoretical data
  # combined_long_tbl <- bind_rows(observed_long_tbl, theoretical_long_tbl)
  
  # Adjust the order of bars by modifying the 'Type' factor levels
  combined_long_tbl <- bind_rows(benchmark_long_tbl, plexos_long_tbl, antares_long_tbl) %>%
    mutate(Type = factor(Type, levels = c("TWh Benchmark", "TWh PLEXOS", "TWh Antares")))
  
  # Plot generation histograms for each continent
  for (cont in continents) {
    
    cont_tbl <- combined_long_tbl %>%
      filter(area == cont)
    
    p <- ggplot(cont_tbl, aes(x = Technology, y = Generation, fill = Type)) +
      geom_bar(stat = "identity", position = "dodge", color = "black") +
      
      # Round the values displayed in the captions
      geom_text(aes(label = round(Generation, 0)), 
                vjust = -0.5, 
                color = "black", 
                size = 3, 
                position = position_dodge(width = 0.9))+
      
      scale_fill_manual(values = c("TWh Benchmark" = "#117C10", "TWh Antares" = "#00B2FF", "TWh PLEXOS" = "#334D73")) +
      labs(title = paste("Generation comparison", capitalize_words(cont), "(TWh)"),
           y = "TWh",
           x = "",
           fill = "Type") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            panel.grid.major.x = element_blank(),  # Remove vertical grid lines
            legend.position = "bottom",  # Position the legend at the bottom
            legend.direction = "horizontal")  # Make the legend horizontal
    
    msg = paste("[DEANE] - Saving generation comparisons for", cont, "continent...")
    logFull(msg)
    png_path = file.path(genr_histo_dir, paste0(cont, "_generation_comparison.png"))
    ggsave(filename = png_path, plot = p, 
           width = 4*HEIGHT_720P/DPI_300, height = 2*HEIGHT_720P/DPI_300,
           dpi = DPI_300)
    msg = paste("[DEANE] - Done saving generation comparisons for", cont, "continent!")
    logFull(msg)
  }
}

#########
# A ECHELLE MONDE MTN

# Je pourrais accoler benchmark aussi en vrai..

benchmark_world_generation_values_twh <- tibble(
  area = c("Global", "Asia", "North America", "Europe", "South America", "Africa", "Oceania"),
  total_generation_twh = c(24267, 12880, 5389, 3873, 1143, 774, 297)
)

deane_world_generation_values_twh <- tibble(
  area = c("Global", "Asia", "North America", "Europe", "South America", "Africa", "Oceania"),
  total_generation_twh = c(24092, 12636, 5386, 3874, 1111, 784, 301)
)


saveWorldGenerationDeaneComparison <- function(output_dir,
                                          timestep = "annual",
                                          benchmark_values = benchmark_world_generation_values_twh,
                                          plexos_values = deane_world_generation_values_twh
) {
  
  # Get the observed data
  continental_data <- getContinentalAntaresData(timestep)
  continental_tbl <- as_tibble(continental_data)
  
  # print(continental_tbl)
  
  global_data <- getGlobalAntaresData(timestep)
  global_tbl <- as_tibble(global_data)
  
  # print(global_tbl)
  
  global_and_continents_tbl <- bind_rows(global_tbl, continental_tbl)
  # print(global_and_continents_tbl)
  
  folder_name <- graphs_folder_names_by_mode["global"]
  genr_histo_dir <- file.path(output_dir, folder_name, "Generation histograms")
  
  if (!dir.exists(genr_histo_dir)) {
    dir.create(genr_histo_dir, recursive = TRUE)
  }
  
  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
  
  # Rename variables in observed data and calculate values
  global_and_continents_tbl <- global_and_continents_tbl %>%
    # rename(`Bio and Waste` = `MIX. FUEL`,
    #        Coal = COAL,
    #        Gas = GAS,
    #        Geothermal = `MISC. DTG`,
    #        Hydro = `H. STOR`,
    #        Nuclear = NUCLEAR, 
    #        Oil = OIL,
    #        Solar = SOLAR,
    #        Wind = WIND
    # ) %>%
    mutate(total_generation =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL 
           + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
           total_generation_twh = total_generation / MWH_IN_TWH) %>%
    select(area, total_generation_twh)
  
  # print(global_and_continents_tbl)
  
  global_and_continents_tbl <- global_and_continents_tbl %>%
    mutate(area = recode(area, 
                         "world" = "Global", 
                         "africa" = "Africa", 
                         "asia" = "Asia", 
                         "europe" = "Europe", 
                         "north america" = "North America", 
                         "oceania" = "Oceania", 
                         "south america" = "South America")) %>%
    arrange(desc(total_generation_twh))
  
  # print(global_and_continents_tbl)
  
  # Reshape the theoretical data into long format
  benchmark_long_tbl <- benchmark_values %>%
    pivot_longer(cols = total_generation_twh, 
                 names_to = "All Technologies", 
                 values_to = "Generation") %>%
    mutate(Type = "TWh Benchmark")
  
  # Reshape the theoretical data into long format
  plexos_long_tbl <- plexos_values %>%
    pivot_longer(cols = total_generation_twh, 
                 names_to = "All Technologies", 
                 values_to = "Generation") %>%
    mutate(Type = "TWh PLEXOS")
  
  # Reshape the observed data into long format
  antares_long_tbl <- global_and_continents_tbl %>%
    pivot_longer(cols = total_generation_twh, 
                 names_to = "All Technologies", 
                 values_to = "Generation") %>%
    mutate(Type = "TWh Antares")
  
  # # Combine observed and theoretical data
  # combined_long_tbl <- bind_rows(observed_long_tbl, theoretical_long_tbl)
  
  # Adjust the order of bars by modifying the 'Type' factor levels
  combined_long_tbl <- bind_rows(benchmark_long_tbl, plexos_long_tbl, antares_long_tbl) %>%
    mutate(Type = factor(Type, levels = c("TWh Benchmark", "TWh PLEXOS", "TWh Antares")))
  
  # print(combined_long_tbl)
  
  # Plot generation histograms for each continent
  
  # # Reorder 'area' based on the 'Generation' values in descending order
  # Needs forcats package
  # combined_long_tbl <- combined_long_tbl %>%
  #   mutate(area = fct_reorder(area, Generation, .desc = TRUE))
  
  # Reorder 'area' based on 'Generation' in descending order without using forcats
  combined_long_tbl <- combined_long_tbl %>%
    mutate(area = factor(area, levels = unique(area[order(-Generation)])))
  
    
    p <- ggplot(combined_long_tbl, aes(x = area, y = Generation, fill = Type)) +
      geom_bar(stat = "identity", position = "dodge", color = "black") +
      
      # Round the values displayed in the captions
      geom_text(aes(label = round(Generation, 0)), 
                vjust = -0.5, 
                color = "black", 
                size = 3, 
                position = position_dodge(width = 0.9))+
      
      scale_fill_manual(values = c("TWh Benchmark" = "#117C10", "TWh PLEXOS" = "#334D73", "TWh Antares" = "#00B2FF")) +
      labs(title = "Generation comparison (TWh)",
           y = "TWh",
           x = "",
           fill = "Type") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            panel.grid.major.x = element_blank(),  # Remove vertical grid lines
            legend.position = "bottom",  # Position the legend at the bottom
            legend.direction = "horizontal")  # Make the legend horizontal
    
    msg = "[DEANE] - Saving generation comparisons for the world..."
    logFull(msg)
    png_path = file.path(genr_histo_dir, "world_generation_comparison.png")
    ggsave(filename = png_path, plot = p, 
           width = 4*HEIGHT_720P/DPI_300, height = 2*HEIGHT_720P/DPI_300,
           dpi = DPI_300)
    msg = "[DEANE] - Done saving generation comparisons for the world!"
    logFull(msg)
  }


###############################
### EMISSIONS

saveContinentalEmissionHistograms <- function(output_dir,
                                              timestep = "annual"
) {
  
  timestep = "annual"
  continental_data <- getContinentalAntaresData(timestep)
  continental_tbl <- as_tibble(continental_data) %>%
    select(area, timeId, time, COAL, GAS, OIL)
  
  continental_long_tbl <- continental_tbl %>%
    pivot_longer(cols = c("COAL", "GAS", "OIL"), 
                 names_to = "fuel_column", 
                 values_to = "production")
  
  pollution_tbl <- continental_long_tbl %>%
    left_join(emissions_tbl, by = c("area" = "continent", "fuel_column"))
  
  
  pollution_tbl <- pollution_tbl %>%
    mutate(pollution = production * production_rate,
           pollution_percentage = pollution / 100, # Still really weird...
           pollution_megatons = pollution_percentage / TONS_IN_MEGATON)
  
  pollution_tbl <- pollution_tbl %>%
    group_by(area, timeId, time, fuel_column) %>%
    summarise(pollution_megatons = sum(pollution_megatons, na.rm = TRUE), .groups = 'drop')
  
  pollution_tbl <- pollution_tbl %>%
    bind_rows(
      pollution_tbl %>%
        group_by(area, timeId, time) %>%
        summarise(fuel_column = "Total", pollution_megatons = sum(pollution_megatons, na.rm = TRUE), .groups = 'drop')
    ) %>%
    arrange(area,
            timeId, time, 
            factor(fuel_column, levels = c("COAL", "GAS", "OIL", "Total"))) %>%
    select(area, fuel_column, pollution_megatons)
  
  # print(pollution_tbl)
  
  continental_dir <- file.path(output_dir, "Graphs", "2 - Continental-level graphs")
  
  emis_histo_dir <- file.path(continental_dir, "Emissions histograms")
  
  if (!dir.exists(emis_histo_dir)) {
    dir.create(emis_histo_dir, recursive = TRUE)
  }
  
  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
  
  pollution_tbl <- pollution_tbl %>%
    mutate(fuel_column = factor(fuel_column, levels = c("Total", "OIL", "GAS", "COAL")))
  
  
  for (cont in continents) {
    
    cont_data <- pollution_tbl %>%
      filter(area == cont)
    
    p <- ggplot(cont_data, aes(x = fuel_column, y = pollution_megatons, fill = fuel_column)) +
      geom_bar(stat = "identity", color = "black") +
      geom_text(aes(label = round(pollution_megatons, 1)), 
                vjust = -0.5, size = 3.5, color = "black") +  # Add text labels above bars
      scale_fill_manual(values = c("Total" = "black", "OIL" = "darkslategray", "GAS" = "red", "COAL" = "darkred")) +
      labs(title = paste("Pollution by Fuel Type in", cont),
           x = "Fuel Type",
           y = "Pollution (Megatons)") +
      theme_minimal() +
      theme(legend.position = "none")
    
    msg = paste("[OUTPUT] - Saving emissions histograms for", cont, "continent...")
    logFull(msg)
    png_path = file.path(emis_histo_dir, paste0(cont, "_emissions.png"))
    ggsave(filename = png_path, plot = p, 
           width = 2*HEIGHT_720P/DPI_300, height = 2*HEIGHT_720P/DPI_300,
           dpi = DPI_300)
    msg = paste("[OUTPUT] - Done saving emissions histograms for", cont, "continent !")
    logFull(msg)
  }
}

##############################

## WITH DEANE COMPARISON

source(".\\src\\antaresReadResults_aux\\getPollutionByFuel.R")

benchmark_emissions_values_MtCO2 <- tibble(
  area = c("africa", "asia", "europe", "north america", "oceania", "south america"),
  Total = c(497, 8976, 1303, 2263, 197, 265),
  Oil = c(87, 552, 55, 95, 5, 79),
  Gas = c(134, 1578, 285, 692, 31, 113),
  Coal = c(276, 6766, 962, 1476, 161, 73)
)

plexos_emissions_values_MtCO2 <- tibble(
  area = c("africa", "asia", "europe", "north america", "oceania", "south america"),
  Total = c(478, 8734, 1337, 2260, 200, 235),
  Oil = c(42, 474, 49, 95, 7, 53),
  Gas = c(160, 1490, 335, 688, 32, 109),
  Coal = c(276, 6770, 953, 1477, 161, 73)
)

# scale_fill_manual(values = c("Antares" = "#FFB800", "PLEXOS" = "#336F73"))

# print(deane_emissions_values_MtCO2)
# And what if I did... per capita
# because these are hard to interpret with population differences....

benchmark_emissions_values_MtCO2 <- benchmark_emissions_values_MtCO2 %>%
  pivot_longer(cols = c("Coal", "Gas", "Oil", "Total"), 
               names_to = "fuel", 
               values_to = "pollution_megatons")

plexos_emissions_values_MtCO2 <- plexos_emissions_values_MtCO2 %>%
  pivot_longer(cols = c("Coal", "Gas", "Oil", "Total"), 
               names_to = "fuel", 
               values_to = "pollution_megatons")

# print(deane_emissions_values_MtCO2)

saveEmissionsDeaneComparison <- function(output_dir,
                                         timestep = "annual",
                                         benchmark_values = benchmark_emissions_values_MtCO2,
                                         plexos_values = plexos_emissions_values_MtCO2
) {
  
  # timestep = "annual"
  # continental_data <- getContinentalAntaresData(timestep)
  # continental_tbl <- as_tibble(continental_data) %>%
  #   # This is your best opportunity to rename, I think. "Total", "Oil", ...
  #   select(area, timeId, time, COAL, GAS, OIL)
  msg = "[DEANE] - Computing continental CO2 emissions in Antares study..."
  logFull(msg)
  continent_pollution_tbl <- getContinentalPollution()
  msg = "[DEANE] - Done computing continental CO2 emissions!"
  logFull(msg)
  
  continent_pollution_Mtons_tbl <- continent_pollution_tbl %>%
    mutate(pollution_megatons = pollution_tons / TONS_IN_MEGATON) %>%
    select(area, fuel, pollution_megatons)
  
  # print(continent_pollution_Mtons_tbl)
  
  # Combine with theoretical data
  antares_long_tbl <- continent_pollution_Mtons_tbl %>%
    select(area, fuel, pollution_megatons) %>%
    mutate(Type = "CO2 Antares")
  
  benchmark_long_tbl <- benchmark_values %>%
    mutate(Type = "CO2 Benchmark")
  
  plexos_long_tbl <- plexos_values %>%
    # pivot_longer(cols = c("Coal", "Gas", "Oil", "Total"), 
    #              names_to = "fuel", 
    #              values_to = "pollution_megatons") %>%
    ## that was before, now pivot_longer is already in the theoretical thing.
    ## i mean, unless we wanna change that.
    mutate(Type = "CO2 PLEXOS")
  
  combined_long_tbl <- bind_rows(benchmark_long_tbl, plexos_long_tbl, antares_long_tbl) %>%
    mutate(fuel = factor(fuel, levels = c("Total", "Oil", "Gas", "Coal")),
           Type = factor(Type, levels = c("CO2 Benchmark", "CO2 PLEXOS", "CO2 Antares"))
    )
  
  folder_name <- graphs_folder_names_by_mode["continental"]
  genr_histo_dir <- file.path(output_dir, folder_name, "Emissions histograms")
  
  if (!dir.exists(genr_histo_dir)) {
    dir.create(genr_histo_dir, recursive = TRUE)
  }
  
  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
  
  for (cont in continents) {
    
    cont_data <- combined_long_tbl %>%
      filter(area == cont)
    
    p <- ggplot(cont_data, aes(x = fuel, y = pollution_megatons, fill = Type)) +
      geom_bar(stat = "identity", position = "dodge", color = "black") +
      geom_text(aes(label = round(pollution_megatons, 0)), 
                vjust = -0.5, size = 3, color = "black", 
                position = position_dodge(width = 0.9)) +
      scale_fill_manual(values = c("CO2 Benchmark" = "#B93333", "CO2 PLEXOS" = "#336F73", "CO2 Antares" = "#FFB800")) +
      labs(title = paste("Emissions comparison", capitalize_words(cont), "(CO2)"),
           y = "MTon",
           x = "",
           fill = "Type") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            panel.grid.major.x = element_blank(),  # Remove vertical grid lines
            legend.position = "bottom",  # Position the legend at the bottom
            legend.direction = "horizontal")  # Make the legend horizontal
    
    msg = paste("[DEANE] - Saving emissions comparisons for", cont, "continent...")
    logFull(msg)
    png_path = file.path(genr_histo_dir, paste0(cont, "_emissions_comparison.png"))
    ggsave(filename = png_path, plot = p, 
           width = 2*HEIGHT_720P/DPI_300, height = 2*HEIGHT_720P/DPI_300,
           dpi = DPI_300)
    msg = paste("[DEANE] - Done saving emissions comparisons for", cont, "continent!")
    logFull(msg)
  }
}

### world time babey

benchmark_world_emission_values_twh <- tibble(
  area = c("Global", "Asia", "North America", "Europe", "Africa", "South America", "Oceania"),
  total_emissions_mtco2 = c(13421, 8896, 2263, 1302, 497, 265, 197)
)

plexos_world_emission_values_twh <- tibble(
  area = c("Global", "Asia", "North America", "Europe", "Africa", "South America", "Oceania"),
  total_emissions_mtco2 = c(13244, 8734, 2260, 1337, 478, 235, 200)
)


saveWorldEmissionsDeaneComparison <- function(output_dir,
                                               timestep = "annual",
                                               benchmark_values = benchmark_world_emission_values_twh,
                                               plexos_values = plexos_world_emission_values_twh
) {
  
  msg = "[DEANE] - Computing world CO2 emissions in Antares study..."
  logFull(msg)
  world_pollution_tbl <- getGlobalPollution()
  msg = "[DEANE] - Done computing world CO2 emissions!"
  logFull(msg)
  
  
  # columns "area" and "pollution_tons"
  
  folder_name <- graphs_folder_names_by_mode["global"]
  emis_histo_dir <- file.path(output_dir, folder_name, "Emissions histograms")
  
  antares_pollution_tbl <- world_pollution_tbl %>%
    mutate(total_emissions_mtco2 = pollution_tons / TONS_IN_MEGATON) %>%
    select(area, total_emissions_mtco2)
  
  # Combine with theoretical data
  
  antares_long_tbl <- antares_pollution_tbl %>%
    select(area, total_emissions_mtco2) %>%
    mutate(Type = "CO2 Antares")
  
  benchmark_long_tbl <- benchmark_values %>%
    mutate(Type = "CO2 Benchmark")
  
  plexos_long_tbl <- plexos_values %>%
    mutate(Type = "CO2 PLEXOS")
  
  combined_long_tbl <- bind_rows(benchmark_long_tbl, plexos_long_tbl, antares_long_tbl) %>%
    mutate(Type = factor(Type, levels = c("CO2 Benchmark", "CO2 PLEXOS", "CO2 Antares")))
  
  
  print(combined_long_tbl)
  
  if (!dir.exists(emis_histo_dir)) {
    dir.create(emis_histo_dir, recursive = TRUE)
  }
  
  # continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
  
  # Reorder 'area' based on 'Generation' in descending order without using forcats
  combined_long_tbl <- combined_long_tbl %>%
    mutate(area = factor(area, levels = unique(area[order(-total_emissions_mtco2)])))
  
  
  p <- ggplot(combined_long_tbl, aes(x = area, y = total_emissions_mtco2, fill = Type)) +
    geom_bar(stat = "identity", position = "dodge", color = "black") +
    
    # Round the values displayed in the captions
    geom_text(aes(label = round(total_emissions_mtco2, 0)), 
              vjust = -0.5, 
              color = "black", 
              size = 3, 
              position = position_dodge(width = 0.9))+
    
    # "CO2 Antares" = "#FFB800", "CO2 PLEXOS" = "#336F73"
    scale_fill_manual(values = c("CO2 Benchmark" = "#B93333", "CO2 PLEXOS" = "#336F73", "CO2 Antares" = "#FFB800")) +
    labs(title = "Emissions comparison (CO2)",
         y = "Mton",
         x = "",
         fill = "Type") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          panel.grid.major.x = element_blank(),  # Remove vertical grid lines
          legend.position = "bottom",  # Position the legend at the bottom
          legend.direction = "horizontal")  # Make the legend horizontal
  
  
  msg = "[DEANE] - Saving emissions comparisons for the world..."
  logFull(msg)
  png_path = file.path(emis_histo_dir, "world_emissions_comparison.png")
  ggsave(filename = png_path, plot = p, 
         width = 4*HEIGHT_720P/DPI_300, height = 2*HEIGHT_720P/DPI_300,
         dpi = DPI_300)
  msg = "[DEANE] - Done saving emissions comparisons for the world!"
  logFull(msg)
}

######
# New method just dropped pour calculer pollution

# Nicolas : "Ce qu'il est possible de faire (car tu n'auras pas d'évolution d'Antares avant la fin de ton stage)
# c'est de sortir les données annuelles de production par centrale 
# ("cluster" dans la terminologie Antares) et les multiplier par le bon coefficient d'émission."

# readAntaresClusters("all", selected = "production", timeStep = "annual", showProgress = TRUE)
# readClusterDesc()