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
simulation_mode = "Economy"
# nodes <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")
generate_CSP = TRUE
renewable_modelling = "clusters"

createAntaresStudyFromIfScenario <- function(study_name, scenario_number) {
  
  nodes <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")
  
  # Création de l'étude
  createStudy(
    path = file.path("antares", "examples", "studies", 
                     fsep = .Platform$file.sep),
    study_name = study_name,
    antares_version = "8.6.0"
  )
  
  total_start_time <- Sys.time()
  
  msg = paste("[MAIN] - Creating", study_name, "study...")
  logMain(msg)
  msg = paste("[MAIN] - Simulating If scenario~:", scenario_number, ".\n")
  logMain(msg)
  
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
    leapyear = TRUE,
    year.by.year = TRUE,
    generate = c("thermal"),
    nbtimeseriesthermal = mc_years,
  )
  updateOptimizationSettings(
    renewable.generation.modelling = renewable_modelling,
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
  
  msg = "[MAIN] - Adding world node...\n"
  logMain(msg)
  start_time <- Sys.time()
  # addNodesToAntares()
  createArea(
    name = "World",
    nodalOptimization = nodalOptimizationOptions(average_unsupplied_energy_cost = 200)
    # Hypothesis on VoLL, completely arbitrary but we won't look at costs, we just need it to be high.
  )
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding world node! (run time : ", duration,"s).\n")
  logMain(msg)
  
  ############################### DISTRICT CREATION ##############################
  
  # addDistrictsTo2060(nodes)
  
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
  
  world_load_tbl <- load_tbl %>%
    mutate(World = rowSums(across(all_of(nodes)))) %>%
    select(timeId, year, month, day, hour, # optionnels en vrai
           World)
  
  load_ts <- world_load_tbl[["World"]]
  
  tryCatch({
    writeInputTS(
      data = load_ts,
      type = "load",
      area = "World"
    )
  }, error = function(e) {
    msg = paste("[WARN] - Could not add load data to", node, "node, skipping...")
    logError(msg)
  }
  )
  
  # for (node in nodes) {
  #   load_ts <- load_tbl[[node]]
  #   msg = paste("[LOAD] - Adding", node, "load data...")
  #   logFull(msg)
  #   tryCatch({
  #     writeInputTS(
  #       data = load_ts,
  #       type = "load",
  #       area = node
  #     )
  #   }, error = function(e) {
  #     msg = paste("[WARN] - Could not add load data to", node, "node, skipping...")
  #     logError(msg)
  #   }
  #   )
  # }
  
  ################################################################################
  ################################# THERMAL IMPORT ###############################
  
  # library(data.table)
  # 
  # daily_zeros <- matrix(0, 365)
  # daily_zeros_datatable <- as.data.table(daily_zeros)
  # daily_ones <- matrix(1, 365)
  # daily_ones_datatable <- as.data.table(daily_ones)
  # 
  # hourly_zeros <- matrix(0, 8760)
  # hourly_zeros_datatable <- as.data.table(hourly_zeros)
  # hourly_ones <- matrix(1, 8760)
  # hourly_ones_datatable <- as.data.table(hourly_ones)
  
  msg = "[MAIN] - Fetching thermal data..."
  logMain(msg)
  start_time <- Sys.time()
  
  # thermal_if_scenario_tbl <- readRDS(".\\src\\2060\\thermal_if_operational_tbl.rds") %>%
  #   filter(scenario == scenario_number)
  
  thermal_if_scenario_tbl <- readRDS(".\\src\\2060\\oneNode\\thermal_all_scenarios_tbl.rds") %>%
    filter(scenario == scenario_number)
  
  for (k in 1:nrow(thermal_if_scenario_tbl)) {
    generator_row <- thermal_if_scenario_tbl[k,]
    
    generator_name <- generator_row$if_technology_type
    # node <- generator_row$node
    antares_cluster_type <- generator_row$antares_cluster_type
    capacity_per_unit <- generator_row$capacity_per_unit
    nb_units <- generator_row$nb_units
    min_stable_power <- generator_row$min_stable_power
    start_cost <- generator_row$start_cost
    variable_cost <- generator_row$variable_cost
    
    co2_emission_t <- generator_row$co2_emission_t
    list_pollutants = list("co2"= co2_emission_t)
    
    # po_rate <- generator_row$po_rate
    # po_rate_matrix <- matrix(po_rate, 365)
    # po_rate_datatable <- as.data.table(po_rate_matrix)
    # 
    # po_duration <- generator_row$po_duration
    # po_duration_matrix <- matrix(po_duration, 365)
    # po_duration_datatable <- as.data.table(po_duration_matrix)
    # 
    # prepro_df <- data.frame(
    #   fo_duration = daily_ones_datatable,
    #   po_duration = po_duration_datatable,
    #   fo_rate = daily_zeros_datatable,
    #   po_rate = po_rate_datatable,
    #   npo_min = daily_zeros_datatable,
    #   npo_max = daily_zeros_datatable
    # )
    # 
    # default_modulation <- data.frame(
    #   mrg_cost_mod = hourly_ones_datatable,
    #   market_bid_mod = hourly_ones_datatable,
    #   capacity_mod = hourly_ones_datatable,
    #   min_gen_mod = hourly_zeros_datatable
    # )
    
    tryCatch({
      createCluster(
        area = "World",
        cluster_name = generator_name,
        group = antares_cluster_type,
        unitcount = as.integer(nb_units),
        nominalcapacity = capacity_per_unit,
        min_stable_power = min_stable_power, # Point d'attention : ça s'écrit avec des tirets dans le .ini
        list_pollutants = list_pollutants,
        # prepro_data = prepro_df,
        # prepro_modulation = default_modulation,
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
  
  # msg = "[THERMAL] - Generating timeseries for maintenance of thermal generators..."
  # logFull(msg)
  # 
  # antares_solver_path <- ".\\antares\\AntaresWeb\\antares_solver\\antares-8.8-solver.exe"
  # updateGeneralSettings(generate = "thermal",
  #                       refreshtimeseries = "thermal")
  # updateInputSettings(import = c("thermal"))
  # runTsGenerator(
  #   path_solver = antares_solver_path,
  #   show_output_on_console = TRUE
  # )
  # 
  # msg = "[THERMAL] - Done generating maintenance timeseries!"
  # logFull(msg)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "mins"), 2)
  msg = paste0("[MAIN] - Done adding thermal data! (run time : ", duration,"min).\n")
  logMain(msg)
  
  # ##############################################################################
  # ##################### LIGNES FORMA DEL GRAPHE COMPLET ########################
  # 
  # msg = "[MAIN] - Adding lines between areas...\n"
  # logMain(msg)
  # start_time <- Sys.time()
  # 
  # addLines_file = file.path("src", "antaresCreateStudy_aux", "addLines.R")
  # source(addLines_file)
  # makeMinimalGlobalGrid(nodes)
  # 
  # end_time <- Sys.time()
  # duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  # msg = paste0("[MAIN] - Done adding lines! (run time : ", duration,"s).\n")
  # logMain(msg)
  
  ##############################################################################
  ################################## WIND IMPORT ###############################
  
  msg = "[MAIN] - Fetching wind data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  wind_agg_ts <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, wind_cf_ts_tbl) %>%
    select(-datetime)
  
  for (node in nodes) {
    wind_ts <- wind_agg_ts[[node]]
    tryCatch({
      createClusterRES(
        area = node,
        cluster_name = paste0(node, "_", "wind"),
        group = "Wind Onshore",
        time_series = wind_ts,
        add_prefix = FALSE,
        overwrite = FALSE,
        ts_interpretation = "power-generation"
      )
      msg = paste("[WIND] - Adding", node, "wind data to Wind Onshore cluster...")
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
  ################################## PV IMPORT #################################
  
  msg = "[MAIN] - Fetching PV data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  pv_agg_ts <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, pv_cf_ts_tbl) %>%
    select(-datetime)
  
  for (node in nodes) {
    pv_ts <- pv_agg_ts[[node]]
    tryCatch({
      createClusterRES(
        area = node,
        cluster_name = paste0(node, "_", "pv"),
        group = "Solar PV",
        time_series = pv_ts,
        add_prefix = FALSE,
        overwrite = FALSE,
        ts_interpretation = "power-generation"
      )
      msg = paste("[PV] - Adding", node, "PV data to Solar PV cluster...")
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
  
  ################################################################################
  ################################## CSP IMPORT #################################
  
  msg = "[MAIN] - Fetching CSP data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  csp_agg_ts <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, csp_cf_ts_tbl) %>%
    select(-datetime)
  
  for (node in nodes) {
    csp_ts <- csp_agg_ts[[node]]
    tryCatch({
      createClusterRES(
        area = node,
        cluster_name = paste0(node, "_", "csp"),
        group = "Solar Thermal",
        time_series = csp_ts,
        add_prefix = FALSE,
        overwrite = FALSE,
        ts_interpretation = "power-generation"
      )
      msg = paste("[PV] - Adding", node, "CSP data to Solar Thermal cluster...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[WARN] - Skipped adding CSP data for", node, "(no generators found in PLEXOS).")
      logError(msg)
    }
    
    )
  }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding CSP data! (run time : ", duration,"s).\n")
  logMain(msg)
  
  
  ################################################################################
  ################################-= HYDRO IMPORT =-##############################
  
  # Et l'hydro si je fais un noeud ? Est-ce que je somme les turbinages mensuels pour dire "oui Deane a servi"
  # ou bien je prends capacité nominale totale * 8760 pour avoir le stock en MWh (...not sure if engagé)
  # et je fais une heuristique reservoir management
  
  if (GENERATE_HYDRO) {
    add2060HydroToAntares(if_generators_properties_tbl)
  }
  
  total_end_time <- Sys.time()
  duration <- round(difftime(total_end_time, total_start_time, units = "mins"), 2)
  msg = paste0("[MAIN] - Finished setting up Antares study! (run time : ", duration,"min).\n \n")
  logMain(msg)
  
}
