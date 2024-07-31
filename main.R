## Script principal regroupant le coeur du processus ##
## Les objets sont typiquement déjà définis dans les fichiers auxilliaires

# Charger les packages
library(antaresRead)
library(antaresEditObject)

# Demander d'ailleurs si on peut virer "antares" du Gitignore
# pour démocratiser AntaresWeb (mais vu que c'est Nicolas qui me l'a filé...)

# Importer des fonctions et variables auxilliaires créées dans d'autres scripts
antaresFunctions_file = file.path("src", "antaresFunctions.R",
                          fsep = .Platform$file.sep)
source(antaresFunctions_file)
# Est-ce qu'on regroupe aussi les noms de modules dans les paramètres ?
# Est-ce qu'on sépare paramètres, faisant un dossier paramètres ? eh
addNodes_file = file.path("src", "data", "addNodes.R",
                          fsep = .Platform$file.sep)
source(addNodes_file)

logging_file = file.path("src", "logging.R",
                         fsep = .Platform$file.sep)
source(logging_file)

source("parameters.R")

################################################################################
################################# CREATE STUDY #################################

if (CREATE_STUDY) {
  antaresCreateStudy_file = file.path("src", "antaresCreateStudy.R",
                                      fsep = .Platform$file.sep)
  source(antaresCreateStudy_file)
}

################################################################################
############################### LAUNCH SIMULATION ##############################

if (LAUNCH_SIMULATION) {
  antaresLaunchSimulation_file = file.path("src", "antaresLaunchSimulation.R",
                                      fsep = .Platform$file.sep)
  source(antaresLaunchSimulation_file)
}

################################################################################
################################## READ RESULTS ################################

if (READ_RESULTS) {
  antaresReadResults_file = file.path("src", "antaresReadResults.R",
                                           fsep = .Platform$file.sep)
  source(antaresReadResults_file)
}

################################################################################
# Commentaires variés

# Ca existe de stocker des objets R qqpart ?
# Ca peut diminuer le temps de fetch renewables.ninja, surtout quand on a peu de points.
# Mais, c'est peut-être plus risqué en un sens, je sais pas.
# Dans input un dossier "Robjects" ou quoi ça pourrait le faire.

# D'après stackoverflow :
#   You can use saveRDS and readRDS functions:
#     
#     library(tibble)
#   test <- tibble(a= list(c(1,2), c(3,4)))
#   saveRDS(test, "c:/test.rds")
#   test_2 <- readRDS("c:/test.rds"))
# identical(test, test_2)
# In the readr package there are read_rds and write_rds functions, which even allow compression to be set.


# if (ADD_VOLL) {
#   addVoLL_module = file.path("src", "data", "addVoLL.R")
#   source(addVoLL_module)
#   addVoLLToAntares(nodes, study_path, study_name, log_verbose, console_verbose, fullLog_file, errorsLog_file)
#   message = paste(Sys.time(), "- [MAIN] Done adding VoLL !")
#   log_message(message, fullLog_file, console_verbose)
# }

# La suite : lancer une simulation et la visionner
# Sachant que le visionnage peut être un truc bien à faire dans un second temps
# Ce qu'il faut faire en fait c'est réussir à stocker genre des presets 
# (dossiers studies tout prêts dans inputs ?)
# et prévoir de lancer des simulations, de visionner des résultats dans un second temps
# (des presets de simulation en fait aussi)
# (même pour tester des fonctions Viz de toute façon ce sera mieux)
