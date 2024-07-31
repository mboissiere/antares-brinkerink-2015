## Script principal regroupant le coeur du processus ##
## Les objets sont typiquement déjà définis dans les fichiers auxilliaires

# Charger les packages
library(antaresRead)
library(antaresEditObject)
# Limite ça le EditObject pourrait être limité au CreateStudy
# Bon AntaresRead je vois pas comment faire sans mdr
# Penser à faire comme un requirements.txt genre le truc comme dans logging
# si pas packages alors les installer, et dire dans le README "au pire localement"

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

logging_module = file.path("src", "logging.R",
                         fsep = .Platform$file.sep)
source(logging_module)

source("parameters.R")

if (EXPORT_TO_OUTPUT_FOLDER) {
  output_dir <- paste0("./output/", generateName("run"))
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
}
# apparemment le format h5 sert à compresser tout ça ?
# # Convert your study in h5 format
# writeAntaresH5(path = mynewpath)
# 
# # Redefine sim path with h5 file
# opts <- setSimulationPath(path = mynewpath)
# prodStack(x = opts)

################################################################################
################################# CREATE STUDY #################################

if (CREATE_STUDY) {
  antaresCreateStudy_module = file.path("src", "antaresCreateStudy.R",
                                      fsep = .Platform$file.sep)
  source(antaresCreateStudy_module)
}

################################################################################
############################### LAUNCH SIMULATION ##############################

if (LAUNCH_SIMULATION) {
  # Peut-être ici mettre les logs globaux ce qui permettrait de mettre genre
  # starting simulation..
  # ou skipped simulation... skipped reading results... done !
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
