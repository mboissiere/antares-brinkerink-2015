library(dplyr)
library(tidyr)
library(antaresEditObject)

# source(".\\src\\2060\\CapacityProratas.R")
source(".\\src\\2060\\antaresCreateStudy_2060_aux.R")

# source("parameters.R")
# source(".\\src\\antaresCreateStudy_aux\\saveObjects.R")

# generators_scenarios_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/generators_scenarios_properties_tbl.rds")

## PARAMETERS

mc_years = 10
unit_commitment = "accurate"
# simulation_mode = "Adequacy" # i mean, dtf on a pas couts marginaux
simulation_mode = "Economy"
# nodes <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")
generate_CSP = FALSE
# if_generators_properties_tbl <- get2060ScenarioTable("S1")

createAntaresStudyFromIfScenario <- function(study_name, scenario_number) {
  
  nodes <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")
  
  # Création de l'étude
  createStudy(
    path = file.path("antares", "examples", "studies", 
                     fsep = .Platform$file.sep),
    study_name = study_name,
    antares_version = "8.6.0"
  )
  
  # Pour faire une estimation de la durée totale
  total_start_time <- Sys.time()
  
  msg = paste("[MAIN] - Creating", study_name, "study...")
  logMain(msg)
  msg = paste("[MAIN] - Simulating If scenario~:", scenario_number, ".\n")
  logMain(msg)
  
  ##### déjà dans main.R ackshually
  # # Bon allez je laisse ça (saveObjects)
  # output_folder <- initializeOutputFolderStudy(study_name)
  # study_folder <- file.path(output_folder, "Antares input - Study data")
  
  ### UPDATING SETTINGS ###
  
  updateGeneralSettings(
    mode = simulation_mode,
    horizon = 2060,
    nbyears = mc_years,
    simulation.start = 1,
    simulation.end = 365,
    january.1st = "Thursday",
    first.month.in.year = "january",
    first.weekday = "Monday",
    #leapyear = FALSE, # Techniquement faux pour 2060, mais relou de s'y pencher (faudrait faire TS > 8760)
    leapyear = TRUE, # Espérons que les chroniques de 8760 restent acceptées..
    year.by.year = TRUE,
    generate = c("thermal"),
    nbtimeseriesthermal = mc_years, # est-ce obligé ?
  )
  updateOptimizationSettings(
    renewable.generation.modelling = "aggregated",
    unit.commitment.mode = unit_commitment
  )
  updateOutputSettings(
    synthesis = TRUE
  )
  updateOptimizationSettings(
    include.exportmps = "true"
  )
  
  msg = paste("[MAIN] - Simulation mode :", simulation_mode)
  logMain(msg)
  msg = paste("[MAIN] - Unit commitment mode :", unit_commitment)
  logMain(msg)
  msg = paste("[MAIN] - Number of MC years :", mc_years)
  logMain(msg)
  msg = paste("[MAIN] - Generation of CSP :", generate_CSP)
  logMain(msg)
  
  ################################## SCENARIO IMPORT #################################
  
  if_generators_properties_tbl <- get2060ScenarioTable(scenario_number)
  
  ################################# AREA CREATION ################################
  
  
  # LE COUT DE LA DEFAILLANCE !!! on va le supposer comme avant hein
  msg = "[MAIN] - Adding nodes...\n"
  logMain(msg)
  start_time <- Sys.time()
  # source(".\\src\\antaresCreateStudy_aux\\addNodes.R")
  addNodesToAntares()
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding nodes! (run time : ", duration,"s).\n")
  logMain(msg)
  
  ############################### DISTRICT CREATION ##############################
  
  addDistrictsTo2060(nodes)
  
  ################################## LOAD IMPORT #################################
  # Ah ! Plus compliqué !
  if (scenario_number == "S1") {
    load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/true 2060/S1_2060_load_tbl.rds")
  } else if (scenario_number == "S2") {
    load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/true 2060/S2_2060_load_tbl.rds")
  } else if (scenario_number == "S3") {
    load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/true 2060/S3_2060_load_tbl.rds")
  } else if (scenario_number == "S4") {
    load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/true 2060/S4_2060_load_tbl.rds")
  }
  
  for (node in nodes) {
    # Ce serait bien de faire depuis Ninja, et de print un warning "not found"
    load_ts <- load_tbl[[node]]
    msg = paste("[LOAD] - Adding", node, "load data...")
    logFull(msg)
    tryCatch({
      writeInputTS(
        data = load_ts,
        type = "load",
        area = node
      )
    }, error = function(e) {
      msg = paste("[WARN] - Could not add load data to", node, "node, skipping...")
      logError(msg)
    }
    )
  }
  
  ################################################################################
  ################################# THERMAL IMPORT ###############################
  
  # source(".\\src\\aggregateAndCluster.R")
  library(data.table)
  
  daily_zeros <- matrix(0, 365)
  daily_zeros_datatable <- as.data.table(daily_zeros)
  daily_ones <- matrix(1, 365)
  daily_ones_datatable <- as.data.table(daily_ones)
  
  hourly_zeros <- matrix(0, 8760)
  hourly_zeros_datatable <- as.data.table(hourly_zeros)
  hourly_ones <- matrix(1, 8760)
  hourly_ones_datatable <- as.data.table(hourly_ones)
  
  msg = "[MAIN] - Fetching thermal data..."
  logMain(msg)
  start_time <- Sys.time()
  
  thermal_if_scenario_tbl <- readRDS(".\\src\\2060\\thermal_if_operational_tbl.rds") %>%
    filter(scenario == scenario_number)
  
  for (k in 1:nrow(thermal_if_scenario_tbl)) {
    generator_row <- thermal_if_scenario_tbl[k,]
    
    generator_name <- generator_row$generator_name
    node <- generator_row$node
    antares_cluster_type <- generator_row$antares_cluster_type
    capacity_2060 <- generator_row$capacity_2060
    nb_units <- generator_row$nb_units
    min_stable_power <- generator_row$min_stable_power
    start_cost <- generator_row$start_cost
    variable_cost <- generator_row$variable_cost
    
    co2_emission_t <- generator_row$co2_emission_t
    list_pollutants = list("co2"= co2_emission_t)
    
    po_rate <- generator_row$po_rate
    po_rate_matrix <- matrix(po_rate, 365)
    po_rate_datatable <- as.data.table(po_rate_matrix)
    
    po_duration <- generator_row$po_duration
    po_duration_matrix <- matrix(po_duration, 365)
    po_duration_datatable <- as.data.table(po_duration_matrix)
    
    prepro_df <- data.frame(
      fo_duration = daily_ones_datatable,
      po_duration = po_duration_datatable,
      fo_rate = daily_zeros_datatable,
      po_rate = po_rate_datatable,
      npo_min = daily_zeros_datatable,
      npo_max = daily_zeros_datatable
    )
    
    default_modulation <- data.frame(
      mrg_cost_mod = hourly_ones_datatable,
      market_bid_mod = hourly_ones_datatable,
      capacity_mod = hourly_ones_datatable,
      min_gen_mod = hourly_zeros_datatable
    )
    
    tryCatch({
      createCluster(
        area = node,
        cluster_name = generator_name,
        group = antares_cluster_type,
        unitcount = as.integer(nb_units),
        nominalcapacity = capacity_2060,
        min_stable_power = min_stable_power, # Point d'attention : ça s'écrit avec des tirets dans le .ini
        list_pollutants = list_pollutants,
        prepro_data = prepro_df,
        prepro_modulation = default_modulation,
        marginal_cost = variable_cost,
        startup_cost = start_cost,
        market_bid_cost = variable_cost,
        add_prefix = FALSE,
        overwrite = TRUE
      )
      msg = paste("[THERMAL] - Adding", generator_name, "generator to", node,"node...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[WARN] - Failed to add", generator_name, "generator to", node,"node, skipping...")
      logError(msg)
    })
  }
  
  # importThermal_file = file.path("src", "antaresCreateStudy_aux", "importThermal.R")
  # source(importThermal_file)
  # 
  # thermal_generators_2060_tbl <- if_generators_properties_tbl %>%
  #   filter(antares_cluster_type %in% c("Gas", "Mixed Fuel", "Hard Coal", "Nuclear", "Other"))
  # 
  # 
  # thermal_properties_2060_tbl <- getThermalPropertiesTable(thermal_generators_2060_tbl,
  #                                                     year_is_2015 = FALSE)
  # # print(thermal_properties_2060_tbl, n = 500)
  # 
  # 
  # if (AGGREGATE_THERMAL) {
  #   msg = "[THERMAL] - Aggregating identical generators..."
  #   logFull(msg)
  #   thermal_properties_2060_tbl <- aggregateEquivalentGenerators(thermal_properties_2060_tbl)
  # }
  # if (CLUSTER_THERMAL) {
  #   msg = paste0("[THERMAL] - Running ", NB_CLUSTERS_THERMAL, "-clustering algorithm on generators...")
  #   logFull(msg)
  #   thermal_properties_2060_tbl <- clusteringForGenerators(thermal_properties_2060_tbl, NB_CLUSTERS_THERMAL)
  #   msg = paste0("[THERMAL] - Done running ", NB_CLUSTERS_THERMAL, "-clustering algorithm on generators!\n")
  #   logFull(msg)
  # }
  # addThermalToAntares(thermal_properties_2060_tbl)
  
  msg = "[THERMAL] - Generating timeseries for maintenance of thermal generators..."
  logFull(msg)
  
  antares_solver_path <- ".\\antares\\AntaresWeb\\antares_solver\\antares-8.8-solver.exe"
  updateGeneralSettings(generate = "thermal",
                        refreshtimeseries = "thermal")
  updateInputSettings(import = c("thermal"))
  runTsGenerator(
    path_solver = antares_solver_path,
    show_output_on_console = TRUE
  )
  
  msg = "[THERMAL] - Done generating maintenance timeseries!"
  logFull(msg)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "mins"), 2)
  msg = paste0("[MAIN] - Done adding thermal data! (run time : ", duration,"min).\n")
  logMain(msg)
  
  ##############################################################################
  ##################### LIGNES FORMA DEL GRAPHE COMPLET ########################
  
  msg = "[MAIN] - Adding lines between areas...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  addLines_file = file.path("src", "antaresCreateStudy_aux", "addLines.R")
  source(addLines_file)
  makeMinimalGlobalGrid(nodes)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding lines! (run time : ", duration,"s).\n")
  logMain(msg)
  
  ################################################################################
  ################################# SOLAR IMPORT #################################
  
  if (generate_CSP) {
    msg = "[MAIN] - Fetching solar (PV + CSP) data...\n"  # Ptet il faudrait modéliser le CSP en stockage...
    # ne serait-ce que pour l'observer sur la courbe en une autre couleur, au lieu de.. bah.. juste tout mix quoi
    logMain(msg)
    start_time <- Sys.time()
    
    pv_agg_tbl <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, pv_cf_ts_tbl) %>%
      select(-datetime)
    
    csp_agg_tbl <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, csp_cf_ts_tbl) %>%
      select(-datetime)
    
    for (node in nodes) {
      # Check if node exists in either tibble
      pv_exists <- node %in% colnames(pv_agg_tbl)
      csp_exists <- node %in% colnames(csp_agg_tbl)
      
      # Only process if the node exists in either PV or CSP data
      if (pv_exists || csp_exists) {
        # Get PV and CSP data, using zero-filled vectors if one is missing
        pv_ts <- if (pv_exists) pv_agg_tbl[[node]] else rep(0, nrow(pv_agg_tbl))
        csp_ts <- if (csp_exists) csp_agg_tbl[[node]] else rep(0, nrow(csp_agg_tbl))
        
        # Sum PV and CSP time series
        solar_ts <- pv_ts + csp_ts
        
        # Write and log the data
        tryCatch({
          writeInputTS(
            data = solar_ts,
            type = "solar",
            area = node
          )
          msg = paste("[SOLAR] - Adding", node, "aggregated solar data...")
          # msg = paste("[SOLAR] - Successfully added aggregated PV + CSP data for", node)
          logFull(msg)
        }, error = function(e) {
          # msg = paste("[WARN] - Failed to add solar data for", node)
          msg = paste("[WARN] - Failed to add solar data for", node, "for unknown reasons.")
          logError(msg)
        })
        
      } else {
        # Log the missing node if absent in both tibbles
        # msg = paste("[WARN] - Skipped adding data for", node, "(no data found in PV or CSP).")
        msg = paste("[WARN] - Skipped adding solar data for", node, "(no generators found in PLEXOS).")
        logError(msg)
      }
    }
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 2)
    msg = paste0("[MAIN] - Done adding solar data! (run time : ", duration,"s).\n")
    logMain(msg)
  } else {
    msg = "[MAIN] - Fetching PV data...\n"
    logMain(msg)
    start_time <- Sys.time()
    
    pv_agg_ts <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, pv_cf_ts_tbl) %>%
      select(-datetime)
    
    for (node in nodes) {
      pv_ts <- pv_agg_ts[[node]]
      tryCatch({
        writeInputTS(
          data = pv_ts,
          type = "solar",
          area = node
        )
        msg = paste("[PV] - Adding", node, "aggregated PV data...")
        logFull(msg)
      }, error = function(e) {
        msg = paste("[WARN] - Skipped adding PV data for", node, "(no generators found in PLEXOS).")
        logError(msg)
      }
      
      )
    }
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 2)
    msg = paste0("[MAIN] - Done adding PV data! (run time : ", duration,"s).\n")
    logMain(msg)
  }
  
  
  
  ################################################################################
  ################################## PV IMPORT #################################
  
  # cf above : CSP should be done seperately actually
  
  ################################## WIND IMPORT #################################
  
  msg = "[MAIN] - Fetching wind data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  wind_agg_ts <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, wind_cf_ts_tbl) %>%
    select(-datetime)
  
  for (node in nodes) {
    wind_ts <- wind_agg_ts[[node]]
    tryCatch({
      writeInputTS(
        data = wind_ts,
        type = "wind",
        area = node
      )
      msg = paste("[WIND] - Adding", node, "aggregated wind data...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[WARN] - Skipped adding wind data for", node, "(no generators found in PLEXOS).")
      logError(msg)
    }
    
    )
  }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding wind data! (run time : ", duration,"s).\n")
  logMain(msg)
  
  
  
  ################################################################################
  ################################-= HYDRO IMPORT =-##############################
  
  if (GENERATE_HYDRO) {
    # importHydro_file = file.path("src", "antaresCreateStudy_aux", "importHydro.R")
    # source(importHydro_file)
    add2060HydroToAntares(if_generators_properties_tbl)
    # Oh dip, and should I start caring about these fast/accurate modes ?
  }
  
  
  ################################################################################
  ## RAPPEL : IL FAUDRA RAJOUTER LE CSP (et la conso)
  
  # AAAAH VU QUE PAR NATURE JE FAIS TOUS NOEUDS... PAS POSSIBLE DE TEST RAPIDEMENT......;
  # obligé de le run en parallèle de mon mémoire oooh nooon...
  # (bon mais c'est une pratique idiote que j'ai fait enft qd mm)
  
  
  # if (GENERATE_LOAD) {
  #   msg = "[MAIN] - Adding load data...\n"
  #   logMain(msg)
  #   start_time <- Sys.time()
  #   
  #   importLoad_file = file.path("src", "antaresCreateStudy_aux", "importLoad.R",
  #                               fsep = .Platform$file.sep)
  #   source(importLoad_file)
  #   addLoadToNodes(NODES)
  #   
  #   end_time <- Sys.time()
  #   duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  #   msg = paste0("[MAIN] - Done adding load data! (run time : ", duration,"s).\n")
  #   logMain(msg)
  # }
  total_end_time <- Sys.time()
  duration <- round(difftime(total_end_time, total_start_time, units = "mins"), 2)
  msg = paste0("[MAIN] - Finished setting up Antares study! (run time : ", duration,"min).\n \n")
  logMain(msg)
  
  ##
}

################################################################################

# ptet tout ce bazar c'est genre. mieux de l'isoler. fin jsp. entre if et deane y a diff.

# en vrai faire from scratch. parce que y a plein de conneries qui change. l'année 2060. c'est pas bissextile
# AH PUTAIN DU COUP MES PROFILS 2015-INSPIRED ILS SONT TEUBES. MERDE.
# NON C OK MDRR JEUDIII LETSGOOO
