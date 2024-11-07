################################################################################

## Création d'une nouvelle étude
if (INCLUDE_DATE_IN_STUDY) {
  study_name <- generateName(study_basename)
} else {
  study_name <- study_basename
}




# Pour faire une estimation de la durée totale
total_start_time <- Sys.time()


msg = paste("[MAIN] - Creating", study_name, "study...\n")
logMain(msg)

createStudy(
  path = base_path,
  study_name = study_name,
  antares_version = antares_version
)

study_path = file.path(base_path, study_name,
                       fsep = .Platform$file.sep)


# msg = paste("[MAIN] - Initializing output folder...")
# logMain(msg)
# source(".\\src\\antaresCreateStudy_aux\\saveObjects.R")
output_folder <- initializeOutputFolderStudy(study_name)
study_folder <- file.path(output_folder, STUDY_DATA_FOLDER_NAME)
# EN PAUSE, MAIS Y REVENIR PLUS TARD



# et vu que maintenant on a un output folder... ne serait-il pas temps d'y mettre
# les logs ?
# à terme, peut-être un dossier "config" qui regroupera des logging.R, des initialisations de dossier,
# et peut-être même des variables un peu biscornues ??
# NB : chaque nouveau "main" devra recréer un nouveau dossier de logs pour le RUN
# mais ça peut atterrir dans un même dossier study si jamais on ne fait que lancer/lire
# des simulations et que CREATE_STUDY est false
# Un dossier "Antares logs" oh comme c'est alphabétique et entre input et output !
# On pourrait nommer le dossier master "study-" au lieu de "results" mais détail
# D'ailleurs pour une meilleur organisation du dossier output, ne faudrait-il pas mettre
# le datetime avant le nom de l'étude ?

msg = paste("[MAIN] - Unit commitment mode :", toupper(UNIT_COMMITMENT_MODE))
logMain(msg)

updateAllSettings()

source(generateObjects_module)

################################################################################
################################# AREA CREATION ################################

msg = "[MAIN] - Adding nodes...\n"
logMain(msg)
start_time <- Sys.time()

addNodesToAntares(NODES, ADD_VOLL)

end_time <- Sys.time()
duration <- round(difftime(end_time, start_time, units = "secs"), 2)
msg = paste0("[MAIN] - Done adding nodes! (run time : ", duration,"s).\n")
logMain(msg)

################################################################################
############################### DISTRICT CREATION ##############################

if (GENERATE_DISTRICTS) {
  msg = "[MAIN] - Adding districts...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  source(".\\src\\antaresCreateStudy_aux\\createDistricts.R")
  createGlobalDistrict(NODES)
  createDistrictsFromContinents(NODES)
  createDistrictsFromRegionalNodes(NODES)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding districts! (run time : ", duration,"s).\n")
  logMain(msg)
}


################################################################################
################################## LOAD IMPORT #################################

if (GENERATE_LOAD) {
  msg = "[MAIN] - Adding load data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  importLoad_file = file.path("src", "antaresCreateStudy_aux", "importLoad.R",
                              fsep = .Platform$file.sep)
  source(importLoad_file)
  addLoadToNodes(NODES)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding load data! (run time : ", duration,"s).\n")
  logMain(msg)
}

################################################################################
################################## WIND IMPORT #################################

if (GENERATE_WIND) {
  msg = "[MAIN] - Fetching wind data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  importWind_file = file.path("src", "antaresCreateStudy_aux", "importWind.R",
                              fsep = .Platform$file.sep)
  source(importWind_file)
  
  if (RENEWABLE_GENERATION_MODELLING == "aggregated") {
    addAggregatedWind(NODES, generators_tbl)
    if (EXPORT_TO_OUTPUT_FOLDER) {
      msg = "[WIND] - Saving aggregated wind data to output folder..."
      logFull(msg)
      saveAggregatedWindTable(NODES, study_folder)
      msg = "[WIND] - Done saving aggregated wind data to output folder!"
      logFull(msg)
    }
  } else if (RENEWABLE_GENERATION_MODELLING == "clusters") {
    # Il faudrait faire crasher plus tôt si jamais ni l'un ni l'autre ptet
    addWindClusters(NODES)
  }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding wind data! (run time : ", duration,"s).\n")
  logMain(msg)
}

################################################################################
################################## SOLAR IMPORT ################################

if (GENERATE_SOLAR_PV) {
  msg = "[MAIN] - Fetching solar data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  importSolarPV_file = file.path("src", "antaresCreateStudy_aux", "importSolarPV.R",
                                 fsep = .Platform$file.sep)
  source(importSolarPV_file)
  # On pourrait encore fragmenter en import de fonctions pour aggregated et clusters.
  # Histoire de limiter appels mémoire.
  
  if (RENEWABLE_GENERATION_MODELLING == "aggregated") {
    addAggregatedSolar(NODES, generators_tbl, GENERATE_SOLAR_CSP)
  } else if (RENEWABLE_GENERATION_MODELLING == "clusters") {
    # Il faudrait faire crasher plus tôt si jamais ni l'un ni l'autre ptet
    addSolarPVClusters(NODES)
  }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding solar data! (run time : ", duration,"s).\n")
  logMain(msg)
}

# Une idée de test de vérification qui pourrait etre intéressant :
# essayer le mode aggregated, et aussi clusters, et voir si y a des écarts
# sur les tableaux que pond SOLAR et WIND etc

################################################################################
################################-= HYDRO IMPORT =-##############################

if (GENERATE_HYDRO) {
  importHydro_file = file.path("src", "antaresCreateStudy_aux", "importHydro.R")
  source(importHydro_file)
  addHydroStorageToAntares(NODES)
  
}

################################################################################
################################# THERMAL IMPORT ###############################

source(".\\src\\aggregateAndCluster.R")

if (GENERATE_THERMAL) {
  msg = "[MAIN] - Fetching thermal data..."
  logMain(msg)
  start_time <- Sys.time()
  
  importThermal_file = file.path("src", "antaresCreateStudy_aux", "importThermal.R")
  source(importThermal_file)
  
  base_generators_properties_tbl <- readRDS(base_generators_properties_path)
  
  thermal_generators_tbl <- filterClusters(base_generators_properties_tbl, THERMAL_TYPES) %>%
    filter(node %in% NODES)
  
  thermal_generators_tbl <- getThermalPropertiesTable(thermal_generators_tbl)
  
  
  if (AGGREGATE_THERMAL) { # c'est hyper moche comme structure et provisoire mais ouais
    msg = "[THERMAL] - Aggregating identical generators..."
    logFull(msg)
    thermal_generators_tbl <- aggregateEquivalentGenerators(thermal_generators_tbl)
    
  }
  # Pour l'instant, si il y a clusters thermal mais pas aggregate thermal, il y a un bug, par construction
  if (CLUSTER_THERMAL) {
    
    msg = paste0("[THERMAL] - Running ", NB_CLUSTERS_THERMAL, "-clustering algorithm on generators...")
    logFull(msg)
    thermal_generators_tbl <- clusteringForGenerators(thermal_generators_tbl, NB_CLUSTERS_THERMAL)
    msg = paste0("[THERMAL] - Done running ", NB_CLUSTERS_THERMAL, "-clustering algorithm on generators!\n")
    logFull(msg)
    
  }
  
  addThermalToAntares(thermal_generators_tbl)
  
  msg = "[THERMAL] - Generating timeseries for maintenance of thermal generators..."
  logFull(msg)
  activateThermalTS()
  msg = "[THERMAL] - Done generating maintenance timeseries!"
  logFull(msg)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "mins"), 2)
  msg = paste0("[MAIN] - Done adding thermal data! (run time : ", duration,"min).\n")
  logMain(msg)
}

################################################################################
################################# BATTERY IMPORT ###############################

if (GENERATE_BATTERIES) {
  msg = "[MAIN] - Fetching battery data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  importBatteries_file = file.path("src", "antaresCreateStudy_aux", "importBatteries.R")
  source(importBatteries_file)
  full_2015_batteries_tbl <- readRDS(batteries_table_path)
  batteries_tbl <- full_2015_batteries_tbl %>%
    filter(node %in% NODES)
  
  if (AGGREGATE_BATTERIES) {
    msg = "[MAIN] - Aggregating identical batteries..."
    logMain(msg)
    agg_batteries_tbl <- aggregateEquivalentBatteries(batteries_tbl)
    
    if (CLUSTER_BATTERIES) {
      
      msg = paste0("[MAIN] - Running ", NB_CLUSTERS_BATTERIES, "-clustering algorithm on batteries...")
      logMain(msg)
      agg_batteries_tbl <- clusteringForBatteries(agg_batteries_tbl, NB_CLUSTERS_BATTERIES)
      msg = paste0("[MAIN] - Done running ", NB_CLUSTERS_BATTERIES, "-clustering algorithm on batteries!\n")
      logMain(msg)
      
      
    }
    
    addBatteriesToAntaresAggregated(agg_batteries_tbl)
  } else {
    addBatteriesToAntares(batteries_tbl)
  }

  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "mins"), 2)
  msg = paste0("[MAIN] - Done adding battery data! (run time : ", duration,"min).\n")
  logMain(msg)
}

################################################################################
################################### CSP IMPORT #################################



# # Welp, I've laid the groundwork for interesting stuff, but I don't think we're
# # gonna use it right now.
# if (GENERATE_SOLAR_CSP) {
#   msg = "[MAIN] - Fetching solar CSP data...\n"
#   logMain(msg)
#   start_time <- Sys.time()
#   
#   importCSP_file = file.path("src", "data", "importCSP.R")
#   source(importCSP_file)
#   addCSPToAntares(NODES)
#   
#   end_time <- Sys.time()
#   duration <- round(difftime(end_time, start_time, units = "mins"), 2)
#   msg = paste0("[MAIN] - Done adding CSP data! (run time : ", duration,"min).\n")
#   logMain(msg)
# }

################################################################################
################################# LINKING AREAS ################################

if (GENERATE_LINES) {
  msg = "[MAIN] - Adding lines between areas...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  addLines_file = file.path("src", "antaresCreateStudy_aux", "addLines.R")
  source(addLines_file)
  if (GLOBAL_GRID) {
    # makeRandomGlobalGrid(NODES)
    # makeFullGlobalGrid(NODES)
    makeMinimalGlobalGrid(NODES)
  } else {
    addLinesToAntares(NODES, INCLUDE_ZERO_NTC_LINES)
  }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding lines! (run time : ", duration,"s).\n")
  logMain(msg)
}

total_end_time <- Sys.time()
# plutot "study", "simulation" que total mais bon voilà
# ça permettra de dire genre "Europe : approx time 5 mins, World : approx time 30 min"
# ou sur l'aggregated, les clusters etc
duration <- round(difftime(total_end_time, total_start_time, units = "mins"), 2)
# Dans un refactor, on pourrait avoir des thermal_units machin pour que ce soit adapté
# à la taille du truc. Eg Lines peut etre des secondes en europe mais des minutes dans monde.
# Tout est des secondes si peu de noeuds. D'où faire des presets.
msg = paste0("[MAIN] - Finished setting up Antares study! (run time : ", duration,"min).\n \n")
logMain(msg)

################################################################################