## GLOBAL

saveGlobalProductionStack <- function(output_dir,
                                      timestep = "daily",
                                      start_date = "2015-01-01",
                                      end_date = "2015-12-31",
                                      unit = "TWh",
                                      stack_palette = "productionStackWithBatteryContributions"
) {
  global_data <- getGlobalAntaresData(timestep)
  
  global_dir <- file.path(output_dir, "Graphs", "1 - Global-level graphs")
  
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(global_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }
  
  # global_unit = "TWh"
  
  stack_plot <- prodStack(
    x = global_data,
    stack = stack_palette,
    areas = "world",
    dateRange = c(start_date, end_date),
    timeStep = timestep,
    main = paste(timestep, "2015 production stack for the world in", unit),
    unit = unit,
    interactive = FALSE
  )
  
  png_path = file.path(prod_stack_dir, "world.png")
  savePlotAsPng(stack_plot, file = png_path,
                width = prodstack_height,
                height = prodstack_width)
  
}



####

saveContinentalProductionStacks <- function(output_dir,
                                            timestep = "daily",
                                            start_date = "2015-01-01",
                                            end_date = "2015-12-31",
                                            unit = "GWh",
                                            stack_palette = "productionStackWithBatteryContributions"
                                            # pour le colorblind check, faire un "colorblindify" pour aperçus
) {
  
  
  continental_data <- getContinentalAntaresData(timestep)
  
  continental_dir <- file.path(output_dir, "Graphs", "2 - Continental-level graphs")
  
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(continental_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }
  
  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
  
  for (cont in continents) {
    stack_plot <- prodStack(
      x = continental_data,
      stack = stack_palette,
      areas = cont,
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      main = paste(timestep, "2015 production stack for", cont, "in", unit),
      unit = unit,
      interactive = FALSE
    )
    msg = paste("[STACK] - Saving production stack for", cont, "continent...")
    logFull(msg)
    png_path = file.path(prod_stack_dir, paste0(cont, ".png"))
    savePlotAsPng(stack_plot, file = png_path,
                  width = prodstack_height,
                  height = prodstack_width
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
                                         unit = "MWh", 
                                         stack_palette = "productionStackWithBatteryContributions"
) {
  national_data <- getNationalAntaresData(timestep)
  
  
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
  
  
  for (ctry in countries) {
    stack_plot <- prodStack(
      x = national_data,
      stack = stack_palette,
      areas = ctry,
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      main = paste(timestep, "2015 production stack for", ctry, "in", unit),
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


saveRegionalProductionStacks <- function(output_dir,
                                         timestep = "daily",
                                         start_date = "2015-01-01",
                                         end_date = "2015-12-31",
                                         unit = "MWh",
                                         stack_palette = "productionStackWithBatteryContributions"
) {
  regional_data <- getRegionalAntaresData(timestep)
  
  regional_dir <- file.path(output_dir, "Graphs", "4 - Regional-level graphs")
  
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(regional_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }
  
  regions <- getAreas(select = REGIONS, regexpSelect = FALSE)
  
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
      main = paste(timestep, "2015 production stack for", regn, "in", unit),
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

