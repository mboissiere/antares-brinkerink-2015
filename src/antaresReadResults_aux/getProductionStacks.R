## GLOBAL

saveGlobalProductionStack <- function(output_dir,
                                      timestep = "daily",
                                      start_date = "2015-01-01",
                                      end_date = "2015-12-31",
                                      stack_palette = "productionStackWithBatteryContributions",
                                      unit = "TWh",
                                      year = 2060
) {
  if (READ_2060) {
    global_data <- getGlobalAntaresData(timestep, FALSE)
  } else {
    global_data <- getGlobalAntaresData(timestep)
  }
  
  
  if (divide_stacks_by_hours) {
    global_data <- divideAntaresDataByHours(global_data, timestep)
  }
  if (READ_2060) {
    global_dir <- output_dir
  } else {
    global_dir <- file.path(output_dir, "Graphs", "1 - Global-level graphs")
  }
  
  
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(global_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }
  
  # global_unit = "TWh"
  if (divide_stacks_by_hours) {
    unit_legend <- paste0(substr(unit, 1, nchar(unit) - 1), "e")
    # Changes TWh into TWe for the legend lmao
  }
  if (READ_2060) {
    
  
  # mutated_data <- global_data %>%
  #   #filter(area == "europe") %>%
  #   # mutate(PRODUCTION = NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL 
  #   #        + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
  #   #        NEGATIVE = - PSP_closed_injection - Battery_injection - Other1_injection
  #   #        - Other2_injection - Other3_injection - BALANCE -`SPIL. ENRG`)
  #   mutate(PRODUCTION = NUCLEAR + `WIND ONSHORE` + `SOLAR PV` + `SOLAR CONCRT.` + `H. STOR` 
  #          + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `UNSP. ENRG`,
  #          NEGATIVE = -`SPIL. ENRG`)
  # 
  # max_load <- max(mutated_data$LOAD, na.rm = TRUE)
  # max_total_production <- max(mutated_data$TOTAL_PRODUCTION, na.rm = TRUE)
  # 
  # # yMax <- 1.1 * max(max_load, max_total_production)
  # 
  # max_load <- max(mutated_data$LOAD, na.rm = TRUE)
  # max_production <- max(mutated_data$PRODUCTION, na.rm = TRUE)
  # 
  # min_negative <- min(mutated_data$NEGATIVE, na.rm = TRUE)
  # 
  # yMax_cont <- 1.05 * max(max_load, max_production) / 1000000 # it's in TW...
  # yMin_cont <- 1.05 * min_negative / 1000000 # it's in TW...
    y_Max <- 12
  stack_plot <- prodStack(
    x = global_data,
    stack = stack_palette,
    areas = "world",
    dateRange = c(start_date, end_date),
    timeStep = timestep,
    # yMin = yMin_cont,
    yMax = y_Max,
    main = paste("Stack of the", timestep, year, "production for the world in", unit_legend, "from", start_date, "to", end_date),
    unit = unit,
    interactive = FALSE
  )
  } else {
    yMax = 8
    stack_plot <- prodStack(
      x = global_data,
      stack = stack_palette,
      areas = "world",
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      main = paste("Stack of the", timestep, year, "production for the world in", unit_legend, "from", start_date, "to", end_date),
      unit = unit,
      interactive = FALSE
    )
  }
  
  # `Contrib. STEP` = PSP_closed_withdrawal - PSP_closed_injection,
  # `Contrib. Batteries` = Battery_withdrawal - Battery_injection,
  # `Contrib. Thermique` = Other1_withdrawal - Other1_injection,
  # `Contrib. Hydrogene` = Other2_withdrawal - Other2_injection,
  # `Contrib. Air comprime` = Other3_withdrawal - Other3_injection,
  # 
  # `Imports/Exports` = -BALANCE,
  # Defaillance = `UNSP. ENRG`,
  # Ecretement = -`SPIL. ENRG`
  # select(LOAD, PRODUCTION)
  
  # print(europe_max)
  # 
  # max_load <- max(mutated_data$LOAD, na.rm = TRUE)
  # max_total_production <- max(mutated_data$TOTAL_PRODUCTION, na.rm = TRUE)
  # 
  # yMax <- 1.1 * max(max_load, max_total_production)
  
  png_path = file.path(prod_stack_dir, "world.png")
  savePlotAsPng(stack_plot, file = png_path,
                width = prodstack_width,
                height = prodstack_height)
  
}



####

saveContinentalProductionStacks <- function(output_dir,
                                            timestep = "daily",
                                            start_date = "2015-01-01",
                                            end_date = "2015-12-31",
                                            stack_palette = "productionStackWithBatteryContributions",
                                            unit = "GWh",
                                            year = 2060
                                            # pour le colorblind check, faire un "colorblindify" pour aperçus
) {
  
  
  continental_data <- getContinentalAntaresData(timestep)
  
  if (divide_stacks_by_hours) {
    continental_data <- divideAntaresDataByHours(continental_data, timestep)
  }
  
  continental_dir <- file.path(output_dir, "Graphs", "2 - Continental-level graphs")
  
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(continental_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }
  # continents <- getAreas(select = CONTINENTS, regexpSelect = FALSE)
  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
  # It's probably still this way because of setsimPath... urgh
  
  if (divide_stacks_by_hours) {
    unit_legend <- paste0(substr(unit, 1, nchar(unit) - 1), "e")
    # Changes TWh into TWe for the legend lmao
  }
  
  mutated_data <- continental_data %>%
    #filter(area == "europe") %>%
    mutate(PRODUCTION = NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL 
           + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
           NEGATIVE = - PSP_closed_injection - Battery_injection - Other1_injection
           - Other2_injection - Other3_injection - BALANCE -`SPIL. ENRG`)
  
  # `Contrib. STEP` = PSP_closed_withdrawal - PSP_closed_injection,
  # `Contrib. Batteries` = Battery_withdrawal - Battery_injection,
  # `Contrib. Thermique` = Other1_withdrawal - Other1_injection,
  # `Contrib. Hydrogene` = Other2_withdrawal - Other2_injection,
  # `Contrib. Air comprime` = Other3_withdrawal - Other3_injection,
  # 
  # `Imports/Exports` = -BALANCE,
  # Defaillance = `UNSP. ENRG`,
  # Ecretement = -`SPIL. ENRG`
    #select(LOAD, PRODUCTION)
  
  # print(europe_max)
  # 
  # max_load <- max(mutated_data$LOAD, na.rm = TRUE)
  # max_total_production <- max(mutated_data$TOTAL_PRODUCTION, na.rm = TRUE)
  # 
  # yMax <- 1.1 * max(max_load, max_total_production)
  
  for (cont in continents) {
    cont_tbl <- mutated_data %>%
      filter(area == cont)
    
    max_load <- max(cont_tbl$LOAD, na.rm = TRUE)
    max_production <- max(cont_tbl$PRODUCTION, na.rm = TRUE)
    
    min_negative <- min(cont_tbl$NEGATIVE, na.rm = TRUE)
    
    yMax_cont <- 1.05 * max(max_load, max_production) / 1000 # it's in GW...
    yMin_cont <- 1.05 * min_negative / 1000 # it's in GW...
    
    stack_plot <- prodStack(
      x = continental_data,
      stack = stack_palette,
      areas = cont,
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      yMin = yMin_cont,
      yMax = yMax_cont,
      main = paste("Stack for the", timestep, year, "production for", cont, "in", unit_legend, "from", start_date, "to", end_date),
      unit = unit,
      interactive = FALSE
    )
    msg = paste("[STACK] - Saving production stack for", cont, "continent...")
    logFull(msg)
    png_path = file.path(prod_stack_dir, paste0(cont, ".png"))
    savePlotAsPng(stack_plot, file = png_path,
                  width = prodstack_width,
                  height = prodstack_height
    )
    msg = paste("[STACK] - The", timestep, "production stack for", cont, "from", start_date, "to", end_date, "has been saved!")
    logFull(msg)
  }
  
  
}


########


saveNationalProductionStacks <- function(output_dir,
                                         timestep = "daily",
                                         start_date = "2015-01-01",
                                         end_date = "2015-12-31",
                                         stack_palette = "productionStackWithBatteryContributions",
                                         unit = "MWh",
                                         year = 2060
) {
  national_data <- getNationalAntaresData(timestep)
  
  if (divide_stacks_by_hours) {
    national_data <- divideAntaresDataByHours(national_data, timestep)
  }
  
  
  national_dir <- file.path(output_dir, "Graphs", "3 - National-level graphs")
  
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(national_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }
  
  countries <- getAreas(select = COUNTRIES, regexpSelect = FALSE)
  districts <- getDistricts(select = COUNTRIES, regexpSelect = FALSE)
  
  countries <- c(countries, districts)
  countries <- sort(countries) 
  
  # shouldn't be necessary if we saved it in areas, right ?
  # ah, perhaps not. because antaresRead is just reading from setSimPath here.
  # so it doesn't take in account what we did. bit annoying that.
  
  if (divide_stacks_by_hours) {
    unit_legend <- paste0(substr(unit, 1, nchar(unit) - 1), "e")
    # Changes TWh into TWe for the legend lmao
  }
  
  for (ctry in countries) {
    stack_plot <- prodStack(
      x = national_data,
      stack = stack_palette,
      areas = ctry,
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      main = paste("Stack for the", timestep, year, "production for", ctry, "in", unit_legend, "from", start_date, "to", end_date),
      unit = unit,
      interactive = FALSE
    )
    msg = paste("[STACK] - Saving production stack for", ctry, "country...")
    logFull(msg)
    png_path = file.path(prod_stack_dir, paste0(ctry, ".png"))
    savePlotAsPng(stack_plot, file = png_path,
                  width = prodstack_width,
                  height = prodstack_height
    )
    msg = paste("[STACK] - The", timestep, "production stack for", ctry, "from", start_date, "to", end_date, "has been saved!")
    logFull(msg)
  }
  
}

#######

# NB : un bug a été obtenu sur un run où il n'y avait pas de régions (pas d'USA, pas de BRA, etc)
# INFO [2024-09-04 16:15:09] [MAIN] - Preparing to save regional production stacks...
# Error in UseMethod("mutate") : 
#   pas de méthode pour 'mutate' applicable pour un objet de classe "c('antaresDataList', 'antaresData', 'list')"

# Penser à prendre en compte ce cas de figure, donc (ne serait-ce que par une exception)

saveRegionalProductionStacks <- function(output_dir,
                                         timestep = "daily",
                                         start_date = "2015-01-01",
                                         end_date = "2015-12-31",
                                         stack_palette = "productionStackWithBatteryContributions",
                                         unit = "MWh",
                                         year = 2060
) {
  regional_data <- getRegionalAntaresData(timestep)
  
  if (divide_stacks_by_hours) {
    regional_data <- divideAntaresDataByHours(regional_data, timestep)
  }
  
  regional_dir <- file.path(output_dir, "Graphs", "4 - Regional-level graphs")
  
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(regional_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }
  
  regions <- getAreas(select = REGIONS, regexpSelect = FALSE)
  
  if (divide_stacks_by_hours) {
    unit_legend <- paste0(substr(unit, 1, nchar(unit) - 1), "e")
    # Changes TWh into TWe for the legend lmao
  }
  
  for (regn in regions) {
    # se généralise en fait ok à partir du moment où on peut faire un for machin in trucs
    # et pour world, le trucs c'est juste "world". on peut l'appeler "planets" même mdr. earth.
    # après tout, pourquoi pas le généraliser à d'autres planètes bahaha (non)
    stack_plot <- prodStack(
      x = regional_data,
      stack = stack_palette,
      areas = regn,
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      main = paste("Stack for the", timestep, year, "production for", regn, "in", unit_legend, "from", start_date, "to", end_date),
      unit = unit,
      interactive = FALSE
    )
    msg = paste("[STACK] - Saving production stack for", regn, "region...")
    logFull(msg)
    png_path = file.path(prod_stack_dir, paste0(regn, ".png"))
    savePlotAsPng(stack_plot, file = png_path,
                  width = prodstack_width,
                  height = prodstack_height
    )
    msg = paste("[STACK] - The", timestep, "production stack for", regn, "from", start_date, "to", end_date, "has been saved!")
    logFull(msg)
  }
}


##########################################

saveAllProductionStacks <- function(output_dir,
                                    timestep,
                                    start_date,
                                    end_date,
                                    color_palette) {
  # make global config variables like DEFAULT_COLOR_PALETTE...
  if (save_global_graphs) {
    msg = "[MAIN] - Preparing to save global production stack..."
    logMain(msg)
    start_time <- Sys.time()
    
    saveGlobalProductionStack(output_dir, timestep, start_date, end_date, color_palette) # à voir si la config je la fais ici ou pas
    # Ah et c'est vrai que normalement faudrait que je fasse des warnings etc..
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 2)
    msg = paste0("[MAIN] - Done saving global production stack! (run time : ", duration,"s).\n")
    # Et en fait c'est ptet pas là qu'il faudrait mettre le main, sinon incohérence avec les autres trucs où l'on précise timestep et date etc
    logMain(msg)
  }
  
  if (save_continental_graphs) {
    msg = "[MAIN] - Preparing to save continental production stacks..."
    logMain(msg)
    start_time <- Sys.time()
    
    saveContinentalProductionStacks(output_dir, timestep, start_date, end_date, color_palette)
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 2)
    msg = paste0("[MAIN] - Done saving continental production stacks! (run time : ", duration,"s).\n")
    logMain(msg)
  }
  
  if (save_national_graphs) {
    msg = "[MAIN] - Preparing to save national production stacks..."
    logMain(msg)
    start_time <- Sys.time()
    
    saveNationalProductionStacks(output_dir, timestep, start_date, end_date, color_palette)
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "mins"), 2)
    msg = paste0("[MAIN] - Done saving national production stacks! (run time : ", duration,"min).\n")
    logMain(msg)
  }
  
  if (save_regional_graphs) {
    msg = "[MAIN] - Preparing to save regional production stacks..."
    logMain(msg)
    start_time <- Sys.time()
    
    saveRegionalProductionStacks(output_dir, timestep, start_date, end_date, color_palette)
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "mins"), 2)
    msg = paste0("[MAIN] - Done saving regional production stacks! (run time : ", duration,"min).\n")
    logMain(msg)
  }
}

