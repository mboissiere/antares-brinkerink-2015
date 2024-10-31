library(dplyr)
library(tidyr)
library(antaresEditObject)

# source(".\\src\\2060\\CapacityProratas.R")
source(".\\src\\2060\\oneNode\\antaresCreateStudy_2060_aux_oneNode.R")

# source("parameters.R")
# source(".\\src\\antaresCreateStudy_aux\\saveObjects.R")

# generators_scenarios_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/generators_scenarios_properties_tbl.rds")

## PARAMETERS

mc_years = 1 # there's no randomness here actually.. not really...
# there could be if we had maintenances, but we don't.
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
  
  # if_generators_properties_tbl <- get2060ScenarioTable(scenario_number)
  source(".\\src\\2060\\oneNode\\newIfScenarioGenerator.R")
  scenario_2060_property_tbl <- getScenarioPropertyTable(scenario_number)
  
  ################################# AREA CREATION ################################
  
  node = "World"
  
  msg = "[MAIN] - Adding world node...\n"
  logMain(msg)
  start_time <- Sys.time()
  # addNodesToAntares()
  createArea(
    name = "World",
    nodalOptimization = nodalOptimizationOptions(average_unsupplied_energy_cost = 200,
                                                 average_spilled_energy_cost = 200),
    overwrite = TRUE
    # Hypothesis on VoLL, completely arbitrary but we won't look at costs, we just need it to be high.
    # Same for spillage if we want to prevent it..
  )
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding world node! (run time : ", duration,"s).\n")
  logMain(msg)
  
  ############################### DISTRICT CREATION ##############################
  
  # addDistrictsTo2060(nodes)
  
  ################################## LOAD IMPORT #################################
  # Ah ! Plus compliqué !
  
  if (LOAD_PROFILES == "Castillo") {
    if (scenario_number == "S1") {
      load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/oneNode/hourly_S1_load_tbl.rds")
    } else if (scenario_number == "S2") {
      load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/oneNode/hourly_S2_load_tbl.rds")
    } else if (scenario_number == "S3") {
      load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/oneNode/hourly_S3_load_tbl.rds")
    } else if (scenario_number == "S4") {
      load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/oneNode/hourly_S4_load_tbl.rds")
    }
    
    # world_load_tbl <- load_tbl %>%
    #   mutate(World = rowSums(across(all_of(nodes)))) %>%
    #   select(timeId, year, month, day, hour, # optionnels en vrai
    #          World)
    
    world_load_ts <- load_tbl %>% pull(World)
  } else if (LOAD_PROFILES == "Deane") {
    load_capacity_ratios_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/oneNode/load_capacity_ratios_tbl.rds")
    scenario_load_capacity_ratio <- load_capacity_ratios_tbl %>%
      filter(scenario == scenario_number) %>%
      pull(load_capacity_ratio)
    
    deane_2015_load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_2015_load_tbl.rds") 
    
    deane_2015_world_ts <- deane_2015_load_tbl %>%
      mutate(World = rowSums(across(all_of(colnames(deane_2015_load_tbl))))) %>%
      pull(World)
    
    world_load_ts <- deane_2015_world_ts * scenario_load_capacity_ratio
  }
  
  
  # load_ts <- world_load_tbl[["World"]]
  
  msg = paste("[LOAD] - Adding", node, "load data...")
  logFull(msg)
  tryCatch({
    writeInputTS(
      data = world_load_ts,
      type = "load",
      area = "World"
    )
    msg = paste("[LOAD] - Successfully added", node, "load data!")
    #   logFull(msg)
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
  
  if_capacity_ratios_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/oneNode/if_capacity_ratios_tbl.rds")
  scenario_2060_capacities_tbl <- if_capacity_ratios_tbl %>%
    filter(scenario == scenario_number) %>%
    select(if_technology_type, total_capacity_2060)
  
  wind_total_capacity <- scenario_2060_capacities_tbl %>%
    filter(if_technology_type == "Wind") %>%
    pull(total_capacity_2060)
  # print(wind_total_capacity)
  
  msg = "[MAIN] - Fetching wind data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  # wind_agg_ts <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, wind_cf_ts_tbl) %>%
  #   select(-datetime)
  
  wind_agg_tbl <- getAggregatedTSFrom2060(nodes, scenario_2060_property_tbl, wind_cf_ts_tbl) %>%
    select(-datetime)
  
  nodes_with_wind <- colnames(wind_agg_tbl)
  
  wind_world_tbl <- wind_agg_tbl %>%
    mutate(World = rowSums(across(all_of(nodes_with_wind))))
  
  wind_ts <- wind_world_tbl %>% pull(World)
  # print(wind_ts)
  
  tryCatch({
    createClusterRES(
      area = "World",
      cluster_name = "wind",
      group = "Wind Onshore",
      time_series = wind_ts,
      add_prefix = FALSE,
      overwrite = FALSE,
      ts_interpretation = "power-generation",
      nominalcapacity = wind_total_capacity,
      unitcount = as.integer(1)
    )
    msg = paste("[WIND] - Adding", node, "wind data to Wind Onshore cluster...")
    logFull(msg)
  }, error = function(e) {
    msg = paste("[WARN] - Skipped adding wind data for", node, "(no generators found in PLEXOS).")
    logError(msg)
  }
  
  )
  
  # for (node in nodes) {
    
    # tryCatch({
    #   createClusterRES(
    #     area = node,
    #     cluster_name = paste0(node, "_", "wind"),
    #     group = "Wind Onshore",
    #     time_series = wind_ts,
    #     add_prefix = FALSE,
    #     overwrite = FALSE,
    #     ts_interpretation = "power-generation"
    #   )
    #   msg = paste("[WIND] - Adding", node, "wind data to Wind Onshore cluster...")
    #   logFull(msg)
    # }, error = function(e) {
    #   msg = paste("[WARN] - Skipped adding wind data for", node, "(no generators found in PLEXOS).")
    #   logError(msg)
    # }
    # 
    # )
  # }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding wind data! (run time : ", duration,"s).\n")
  logMain(msg)
  
  
  ################################################################################
  ################################## PV IMPORT #################################
  
  msg = "[MAIN] - Fetching PV data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  pv_total_capacity <- scenario_2060_capacities_tbl %>%
    filter(if_technology_type == "PV") %>%
    pull(total_capacity_2060)
  
  
  pv_agg_tbl <- getAggregatedTSFrom2060(nodes, scenario_2060_property_tbl, pv_cf_ts_tbl) %>%
    select(-datetime)
  
  nodes_with_pv <- colnames(pv_agg_tbl)
  
  pv_world_tbl <- pv_agg_tbl %>%
    mutate(World = rowSums(across(all_of(nodes_with_pv))))
  
  pv_ts <- pv_world_tbl %>% pull(World)
  # print(pv_ts)
  
  tryCatch({
    createClusterRES(
      area = "World",
      cluster_name = "pv",
      group = "Solar PV",
      time_series = pv_ts,
      add_prefix = FALSE,
      overwrite = FALSE,
      ts_interpretation = "power-generation",
      nominalcapacity = pv_total_capacity,
      unitcount = as.integer(1)
    )
    msg = paste("[PV] - Adding", node, "PV data to Solar PV cluster...")
    logFull(msg)
  }, error = function(e) {
    msg = paste("[WARN] - Skipped adding PV data for", node, "(no generators found in PLEXOS).")
    logError(msg)
  }
  
  )
  
  # pv_agg_ts <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, pv_cf_ts_tbl) %>%
  #   select(-datetime)
  # 
  # for (node in nodes) {
  #   pv_ts <- pv_agg_ts[[node]]
  #   tryCatch({
  #     createClusterRES(
  #       area = node,
  #       cluster_name = paste0(node, "_", "pv"),
  #       group = "Solar PV",
  #       time_series = pv_ts,
  #       add_prefix = FALSE,
  #       overwrite = FALSE,
  #       ts_interpretation = "power-generation"
  #     )
  #     msg = paste("[PV] - Adding", node, "PV data to Solar PV cluster...")
  #     logFull(msg)
  #   }, error = function(e) {
  #     msg = paste("[WARN] - Skipped adding PV data for", node, "(no generators found in PLEXOS).")
  #     logError(msg)
  #   }
  #   
  #   )
  # }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding PV data! (run time : ", duration,"s).\n")
  logMain(msg)
  
  ################################################################################
  ################################## CSP IMPORT #################################
  
  csp_total_capacity <- scenario_2060_capacities_tbl %>%
    filter(if_technology_type == "CSP") %>%
    pull(total_capacity_2060)
  
  msg = "[MAIN] - Fetching CSP data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  csp_cf_ts_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/truecsp_cf_ts_tbl.rds")
  
  csp_agg_tbl <- getAggregatedTSFrom2060(nodes, scenario_2060_property_tbl, csp_cf_ts_tbl) %>%
    select(-datetime)
  
  nodes_with_csp <- colnames(csp_agg_tbl)
  
  csp_world_tbl <- csp_agg_tbl %>%
    mutate(World = rowSums(across(all_of(nodes_with_csp))))
  
  csp_ts <- csp_world_tbl %>% pull(World)
  # print(csp_ts)
  
  tryCatch({
    createClusterRES(
      area = "World",
      cluster_name = "csp",
      group = "Solar Thermal",
      time_series = csp_ts,
      add_prefix = FALSE,
      overwrite = FALSE,
      ts_interpretation = "power-generation",
      nominalcapacity = csp_total_capacity,
      unitcount = as.integer(1)
    )
    msg = paste("[CSP] - Adding", node, "CSP data to Solar Thermal cluster...")
    logFull(msg)
  }, error = function(e) {
    msg = paste("[WARN] - Skipped adding CSP data for", node, "(no generators found in PLEXOS).")
    logError(msg)
  }
  
  )
  
  # csp_agg_ts <- getAggregatedTSFrom2060(nodes, if_generators_properties_tbl, csp_cf_ts_tbl) %>%
  #   select(-datetime)
  # 
  # for (node in nodes) {
  #   csp_ts <- csp_agg_ts[[node]]
  #   tryCatch({
  #     createClusterRES(
  #       area = node,
  #       cluster_name = paste0(node, "_", "csp"),
  #       group = "Solar Thermal",
  #       time_series = csp_ts,
  #       add_prefix = FALSE,
  #       overwrite = FALSE,
  #       ts_interpretation = "power-generation"
  #     )
  #     msg = paste("[PV] - Adding", node, "CSP data to Solar Thermal cluster...")
  #     logFull(msg)
  #   }, error = function(e) {
  #     msg = paste("[WARN] - Skipped adding CSP data for", node, "(no generators found in PLEXOS).")
  #     logError(msg)
  #   }
  #   
  #   )
  # }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding CSP data! (run time : ", duration,"s).\n")
  logMain(msg)
  
  
  ################################################################################
  ################################-= HYDRO IMPORT =-##############################
  
  # Et l'hydro si je fais un noeud ? Est-ce que je somme les turbinages mensuels pour dire "oui Deane a servi"
  # ou bien je prends capacité nominale totale * 8760 pour avoir le stock en MWh (...not sure if engagé)
  # et je fais une heuristique reservoir management
  
  # add2060HydroToAntares(scenario_2060_property_tbl)
  
  msg = paste("[HYDRO] - Fetching", node, "hydro data...")
  logFull(msg)
  hydro_agg_tbl <- getCountryTableFromHydro(scenario_2060_property_tbl)
  
  hydro_world_tbl <- hydro_agg_tbl %>%
    summarize(across(where(is.numeric), sum, na.rm = TRUE))
  
  # print(hydro_world_tbl)
  
  node_info <- hydro_world_tbl[1,]
  
  # node <- node_info$node
  
  hydro_capacity <- node_info$total_nominal_capacity
  max_power_matrix = as.data.table(matrix(c(hydro_capacity, 24, 0, 24), ncol = 4, nrow = 365, byrow = TRUE))
  list_params = list("inter-daily-breakdown" = 2)
  tryCatch({
    writeIniHydro(area = "World",
                  params = list_params
    )
    msg = paste("[HYDRO] - Initializing", node, "hydro parameters...")
    logFull(msg)
  }, error = function(e) {
    msg = paste("[HYDRO] - Couldn't initialize", node, "hydro parameters, skipping...")
    logError(msg)
  })
  tryCatch({
    writeHydroValues(
      area = node,
      type = "maxpower",
      data = max_power_matrix,
      overwrite = TRUE
    )
    msg = paste("[HYDRO] - Adding", node, "max power timeseries...")
    logFull(msg)
  }, error = function(e) {
    msg = paste("[HYDRO] - Couldn't add", node, "max power timeseries, skipping...")
    logError(msg)
  })
  
  monthly_tbl <- node_info %>%
    select(starts_with("M"))
  
  # Extract the values into a simple vector
  monthly_ts <- unlist(monthly_tbl, use.names = FALSE)
  
  daily_ts <- monthly_to_daily(monthly_ts, 2015)
  tryCatch({
    writeInputTS(
      daily_ts,
      type = "hydroSTOR",
      area = node
    )
    msg = paste("[HYDRO] - Adding", node, "hydro profiles...")
    logFull(msg)
  }, error = function(e) {
    msg = paste("[HYDRO] - Couldn't add", node, "hydro profiles, skipping...")
    logError(msg)
  })
  msg = paste("[HYDRO] - Successfully added", node, "hydro data!")
  logFull(msg)
  
  total_end_time <- Sys.time()
  duration <- round(difftime(total_end_time, total_start_time, units = "mins"), 2)
  msg = paste0("[MAIN] - Finished setting up Antares study! (run time : ", duration,"min).\n \n")
  logMain(msg)
  
}
