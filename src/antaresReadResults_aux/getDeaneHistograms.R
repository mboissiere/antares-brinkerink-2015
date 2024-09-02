#####################
## GENERATION

# ah oui y a ça psk jsuis un schlag et je le fais localement
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
    dir.create(genr_histo_dir)
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

###############################
### EMISSIONS

saveContinentalEmissionHistograms <- function(output_dir,
                                              timestep = "annual"
) {
  
  
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