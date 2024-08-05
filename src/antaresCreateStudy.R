################################################################################

## Création d'une nouvelle étude
study_name <- generateName(study_basename)

# Pour faire une estimation de la durée totale
total_start_time <- Sys.time()

createStudy(
  path = base_path,
  study_name = study_name,
  antares_version = antares_version
)


setupLogging()

study_path = file.path(base_path, study_name,
                       fsep = .Platform$file.sep)

msg = paste("[MAIN] - Creating", study_name, "study...\n")
logMain(msg)
msg = paste("[MAIN] - Unit commitment mode :", toupper(UNIT_COMMITMENT_MODE))
logMain(msg)

updateAllSettings()
# En vrai là je pourrais mettre des petits prints genre "added machin"
# Au vu des messages d'erreur ça a l'air d'être "thermal" le problème

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
################################## LOAD IMPORT #################################

if (GENERATE_LOAD) {
  msg = "[MAIN] - Adding load data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  importLoad_file = file.path("src", "data", "importLoad.R",
                              fsep = .Platform$file.sep)
  source(importLoad_file)
  addLoadToNodes(NODES)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding load data! (run time : ", duration,"s).\n")
  logMain(msg)
}

################################################################################
################################ GENERATOR IMPORT ##############################

# Nota bene : remember that this is how we did it.
# Else, only relying on txtToRDS is opaque

# msg = "[MAIN] - Gathering generator data from PLEXOS..."
# logMain(msg)
# start_time <- Sys.time()
# preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R",
#                                         fsep = .Platform$file.sep)
# source(preprocessPlexosData_module)
# 
# generators_tbl <- getGeneratorsFromNodes(NODES)
# generators_tbl <- filterFor2015(generators_tbl)
# generators_tbl <- addGeneralFuelInfo(generators_tbl)
# 
# end_time <- Sys.time()
# duration <- round(difftime(end_time, start_time, units = "secs"), 2)
# msg = paste0("[MAIN] - Done gathering generator data! (run time : ", duration,"s).\n")
# logMain(msg)

generators_file = ".\\src\\objects\\full_2015_generators_tbl.rds"
generators_tbl <- readRDS(generators_file)

## Oooh okay I see what's going on. We should filter it over countries now.
# For example if we have three points, but then don't alter generators_tbl
# until the thermal clusters, then it'll try to import stuff from all around the world.

generators_tbl <- generators_tbl %>%
  filter(node %in% NODES)

# This might cause confusion over how we worked with wind_aggregated before.
# Now we jsut import wind_aggregated and don't do anything over it
# whereas bfeore we had left_joins with only appropriate nodes to save time ?
# Perhaps we could go even further in filters ?
# Perhaps this is, how you say, enculage de mouches ?

################################################################################
################################## WIND IMPORT #################################

if (GENERATE_WIND) {
  msg = "[MAIN] - Fetching wind data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  if (RENEWABLE_GENERATION_MODELLING == "aggregated") {
    importWind_file = file.path("src", "data", "importWind.R",
                                fsep = .Platform$file.sep)
    source(importWind_file)
    addAggregatedWind(NODES, generators_tbl)
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
  
  if (RENEWABLE_GENERATION_MODELLING == "aggregated") {
    importSolarPV_file = file.path("src", "data", "importSolarPV.R",
                                   fsep = .Platform$file.sep)
    source(importSolarPV_file)
    addAggregatedSolarPV(NODES, generators_tbl)
  }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding solar data! (run time : ", duration,"s).\n")
  logMain(msg)
}

################################################################################
################################-= HYDRO IMPORT =-##############################

if (GENERATE_HYDRO) {
  importHydro_file = file.path("src", "data", "importHydro.R")
  source(importHydro_file)
  addHydroStorageToAntares(NODES)
  # Oh dip, and should I start caring about these fast/accurate modes ?
}

################################################################################
################################# THERMAL IMPORT ###############################

if (GENERATE_THERMAL) {
  msg = "[MAIN] - Fetching thermal data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  importThermal_file = file.path("src", "data", "importThermal.R")
  source(importThermal_file)
  #print(generators_tbl)
  #print(THERMAL_TYPES)
  thermal_generators_tbl <- filterClusters(generators_tbl, THERMAL_TYPES)
  #print(thermal_generators_tbl)
  thermal_generators_tbl <- getThermalPropertiesTable(thermal_generators_tbl)
  #print(thermal_generators_tbl)
  addThermalToAntares(thermal_generators_tbl)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "mins"), 2)
  msg = paste0("[MAIN] - Done adding thermal data! (run time : ", duration,"min).\n")
  logMain(msg)
}

################################################################################
################################# LINKING AREAS ################################

if (GENERATE_LINES) {
  msg = "[MAIN] - Adding lines between areas...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  addLines_file = file.path("src", "data", "addLines.R")
  source(addLines_file)
  addLinesToAntares(NODES, INCLUDE_ZERO_NTC_LINES)
  
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