## Script principal regroupant le coeur du processus ##
## Les objets sont typiquement déjà définis dans les fichiers auxilliaires

# Charger les packages
source("requirements.R")

source("architecture.R")


# Importer des fonctions et variables auxilliaires créées dans d'autres scripts
antaresFunctions_file = file.path("src", "antaresFunctions.R",
                          fsep = .Platform$file.sep)

source(antaresFunctions_file)

addNodes_file = file.path("src", "antaresCreateStudy_aux", "addNodes.R",
                          fsep = .Platform$file.sep)
source(addNodes_file)


logging_module = file.path("src", "logging.R",
                           fsep = .Platform$file.sep)
source(logging_module)

if (GENERATE_2060) {
  study_name <- IF_STUDY_NAME
  setupLogging(IF_STUDY_NAME)
} else {
  setupLogging(study_basename)
}

setRam(16)


msg = paste("[MAIN] - Initializing output folder...")
logMain(msg)
source(".\\src\\antaresCreateStudy_aux\\saveObjects.R")
if (!CREATE_STUDY & !GENERATE_2060) {
  study_name <- IMPORT_STUDY_NAME
}
output_folder <- initializeOutputFolderStudy(study_name)
study_folder <- file.path(output_folder, STUDY_DATA_FOLDER_NAME)



################################################################################
################################# CREATE STUDY #################################

if (GENERATE_2060 & WORLD_NODE) {
  # print("yeah")
  antaresCreateStudy2060_module = file.path("src", "2060", "oneNode", "antaresCreateStudy2060_oneNode.R",
                                            fsep = .Platform$file.sep)
  source(antaresCreateStudy2060_module)
  createAntaresStudyFromIfScenario(IF_STUDY_NAME, IF_SCENARIO)
} else if (GENERATE_2060 & !WORLD_NODE) {
  if (!GENERATE_2060_CSP) {
  antaresCreateStudy2060_module = file.path("src", "2060", "antaresCreateStudy_2060.R",
                                            fsep = .Platform$file.sep)
  source(antaresCreateStudy2060_module)
  createAntaresStudyFromIfScenario(IF_STUDY_NAME, IF_SCENARIO)
} else if (GENERATE_2060_CSP) {
  antaresCreateStudy2060_module = file.path("src", "2060", "antaresCreateStudy_2060_wCSP.R",
                                            fsep = .Platform$file.sep)
  source(antaresCreateStudy2060_module)
  createAntaresStudyFromIfScenario(IF_STUDY_NAME, IF_SCENARIO)
}
} else if (CREATE_STUDY) {
    antaresCreateStudy_module = file.path("src", "antaresCreateStudy.R",
                                          fsep = .Platform$file.sep)
    source(antaresCreateStudy_module)
}



################################################################################
############################### LAUNCH SIMULATION ##############################

if (LAUNCH_SIMULATION) {
  antaresLaunchSimulation_module = file.path("src", "antaresLaunchSimulation.R",
                                      fsep = .Platform$file.sep)
  source(antaresLaunchSimulation_module)
}

################################################################################
################################## READ RESULTS ################################

if (READ_RESULTS) {
  
  antaresReadResults_module = file.path("src", "antaresReadResults.R",
                                          fsep = .Platform$file.sep)
  source(antaresReadResults_module)
}

if (READ_2060) {
    antaresReadResults_module = file.path("src", "2060", "antaresReadResults_2060.R",
                                          fsep = .Platform$file.sep)
  source(antaresReadResults_module)
}


