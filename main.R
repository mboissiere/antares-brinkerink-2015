## Script principal regroupant le coeur du processus ##
## Les objets sont typiquement déjà définis dans les fichiers auxilliaires

# Charger les packages
library(antaresRead)
library(antaresEditObject)

# Demander d'ailleurs si on peut virer "antares" du Gitignore
# pour démocratiser AntaresWeb (mais vu que c'est Nicolas qui me l'a filé...)

# Importer des fonctions et variables auxilliaires créées dans d'autres scripts
source(".\\src\\antaresFunctions.R")
# Est-ce qu'on regroupe aussi les noms de modules dans les paramètres ?
# Est-ce qu'on sépare paramètres, faisant un dossier paramètres ? eh
addNodes_file = file.path("src", "data", "addNodes.R",
                          fsep = .Platform$file.sep)
source(addNodes_file)

logging_file = file.path("src", "logging.R",
                         fsep = .Platform$file.sep)
source(logging_file)

source("parameters.R")


## Création d'une nouvelle étude
study_name <- generateName(study_basename)

createStudy(
  path = base_path,
  study_name = study_name,
  antares_version = antares_version
)


setupLogging()
# Oh, est-ce que ça serait pas banger de faire un petit "package" comme à KTH
# genre adieu le dossier logs et je fais un "output" avec à la fois les
# résultats de l'étude produite, et les logs, et d'éventuelles simulation etc.
# ça permet de ne plus avoir une désynchronisation entre étude et log
# (qui peut rendre résultats difficiles à montrer pendant réunions...)

study_path = file.path(base_path, study_name,
                       fsep = .Platform$file.sep)

msg = paste("[MAIN] - Creating", study_name, "study...")
logMain(msg)


# NB : pour l'instant ça MARCHE PAS.
# et wtf il s'est remis en Clusters par défaut.
# par défaut j'ai l'impression il prend le précédent réglage, mais du coup si jamais
# avant on avait du Clusters, hop ça zappe les TS aggregated.
# En fait si AHAH ça le sauvegarde mais ça le cache. Marrant.
updateAllSettings()
# Au vu des messages d'erreur ça a l'air d'être "thermal" le problème

################################################################################

msg = "[MAIN] - Adding nodes...\n"
logMain(msg)
start_time <- Sys.time()

addNodesToAntares(NODES)

end_time <- Sys.time()
# peut-être faire un "time" function dans utils
duration <- round(difftime(end_time, start_time, units = "secs"), 2)
cat("\n")
# Un peu funky les retours à la ligne, faire en sorte qu'ils rendent bien
# à la fois dans full et dans main
msg = paste0("[MAIN] - Done adding nodes! (run time : ", duration,"s).")
logMain(msg)

################################################################################

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
  cat("\n")
  msg = paste0("[MAIN] - Done adding load data! (run time : ", duration,"s).")
  logMain(msg)
}

################################################################################

msg = "[MAIN] - Gathering generator data from PLEXOS...\n"
logMain(msg)
start_time <- Sys.time()
preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R",
                                        fsep = .Platform$file.sep)
source(preprocessPlexosData_module)

generators_tbl <- getGeneratorsFromNodes(NODES)
generators_tbl <- filterFor2015(generators_tbl)
generators_tbl <- addGeneralFuelInfo(generators_tbl)

end_time <- Sys.time()
duration <- round(difftime(end_time, start_time, units = "secs"), 2)
cat("\n")
msg = paste0("[MAIN] - Done gathering generator data! (run time : ", duration,"s).")
logMain(msg)

################################################################################

if (GENERATE_WIND) {
  msg = "[MAIN] - Adding wind data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  if (RENEWABLE_GENERATION_MODELLING == "aggregated") {
    importWind_file = file.path("src", "data", "importWind.R",
                                fsep = .Platform$file.sep)
    source(importWind_module)
    addAggregatedWind(nodes, generators_tbl)
  }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  cat("\n")
  msg = paste0("[MAIN] - Done adding wind data! (run time : ", duration,"s).")
  logMain(msg)
}

################################################################################

if (GENERATE_SOLAR_PV) {
  msg = "[MAIN] - Adding solar PV data...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  if (RENEWABLE_GENERATION_MODELLING == "aggregated") {
    importSolarPV_file = file.path("src", "data", "importSolarPV.R",
                                     fsep = .Platform$file.sep)
    source(importSolarPV_file)
    addAggregatedSolarPV(nodes, generators_tbl, log_verbose, console_verbose, fullLog_file, errorsLog_file)
    message = paste(Sys.time(), "- [MAIN] Added solar PV !")
    log_message(message, fullLog_file, console_verbose)
  }
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  cat("\n")
  msg = paste0("[MAIN] - Done adding solar PV data! (run time : ", duration,"s).")
  logMain(msg)
}

thermal_types = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel")

if (GENERATE_THERMAL) {
  importThermal_module = file.path("src", "data", "importThermal.R")
  source(importThermal_module)
  thermal_generators_tbl <- filterClusters(generators_tbl, thermal_types)
  thermal_generators_tbl <- getThermalPropertiesTable(thermal_generators_tbl)
  addThermalToAntares(thermal_generators_tbl, log_verbose, console_verbose, fullLog_file, errorsLog_file)
  message = paste(Sys.time(), "- [MAIN] Done adding thermal clusters !")
  log_message(message, fullLog_file, console_verbose)
}


if (GENERATE_LINES) {
  addLines_module = file.path("src", "data", "addLines.R")
    source(addLines_module)
    addLinesToAntares(nodes, INCLUDE_ZERO_NTC_LINES, log_verbose, console_verbose, fullLog_file, errorsLog_file)
    message = paste(Sys.time(), "- [MAIN] Done adding lines !")
    log_message(message, fullLog_file, console_verbose)
}




if (ADD_VOLL) {
  addVoLL_module = file.path("src", "data", "addVoLL.R")
  source(addVoLL_module)
  addVoLLToAntares(nodes, study_path, study_name, log_verbose, console_verbose, fullLog_file, errorsLog_file)
  message = paste(Sys.time(), "- [MAIN] Done adding VoLL !")
  log_message(message, fullLog_file, console_verbose)
}

# La suite : lancer une simulation et la visionner
# Sachant que le visionnage peut être un truc bien à faire dans un second temps
# Ce qu'il faut faire en fait c'est réussir à stocker genre des presets 
# (dossiers studies tout prêts dans inputs ?)
# et prévoir de lancer des simulations, de visionner des résultats dans un second temps
# (des presets de simulation en fait aussi)
# (même pour tester des fonctions Viz de toute façon ce sera mieux)
