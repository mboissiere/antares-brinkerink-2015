## Script principal regroupant le coeur du processus ##
## Les objets sont typiquement déjà définis dans les fichiers auxilliaires

# Charger les packages
source("requirements.R")
# ptet plutôt faire des :
# createStudyrequirements, etc comme RR_init et RR_config
# et faire une fonction dans utils qui sait installer
# ça reste un peu mon rêve secret de faire un code qui s'exécute à partir 
# d'un Excel de configuration façon TiTAN...
# ou bien un libreoffice/framacalc si on aime le logiciel libre en vrai :)

source("architecture.R")

# Ce serait bien de faire un truc qui permet de modifier une étude.
# peut etre createStudy, et launchSimulation devient genre edit...Study jsp
# mais là je suis freiné de devoir touuut recréer alors que je veux juste changer
# des hurdle costs, pour voir si le spillage reste en europe et en le soustrayant
# on retrouve bien deane

# approche TiTANesque aussi de faire une copie des choses et de travailler dessus...
# sachant que je pourrais vouloir lancer un run et changer le code en parallèle...

# Importer des fonctions et variables auxilliaires créées dans d'autres scripts
antaresFunctions_file = file.path("src", "antaresFunctions.R",
                          fsep = .Platform$file.sep)

source(antaresFunctions_file)
# Est-ce qu'on regroupe aussi les noms de modules dans les paramètres ?
# Est-ce qu'on sépare paramètres, faisant un dossier paramètres ? eh
addNodes_file = file.path("src", "antaresCreateStudy_aux", "addNodes.R",
                          fsep = .Platform$file.sep)
source(addNodes_file)
# Warning ! The bug that struggles to add nodes sometimes is there again!
# Maybe make a program that restarts everytime a node isn't added ??

logging_module = file.path("src", "logging.R",
                           fsep = .Platform$file.sep)
source(logging_module)
# Nota bene: pb de robustesse, veut absolument solarpv meme quand desactivé
# peut etre que bug dans aggregated venait d'un select anticipé et le groupby
# pouvait fusionner deux productions exactement identiques (mais ça expliquerait pas hausse...)


# c'est environ ici où l'on met le nom du study je pense
setupLogging(study_basename)
# Ptet mettre des logs aussi genre pour séparer createStudy, readResults...
# Le mettre dans main permet de faire un truc uniforme à tous les dossiers.

setRam(16)

# Ok je suis paumé actuellement mais la suite c'est :
# faire un run clusters qui fait un parcours dans Ninja et lance une exception quand y a un pb,
# et lancer ce run au plus vite. comme ça je vois les trucs qui n'y sont pas.

# source("parameters.R")

msg = paste("[MAIN] - Initializing output folder...")
logMain(msg)
source(".\\src\\antaresCreateStudy_aux\\saveObjects.R")
output_folder <- initializeOutputFolderStudy(study_name)
study_folder <- file.path(output_folder, STUDY_DATA_FOLDER_NAME)

# if (EXPORT_TO_OUTPUT_FOLDER) {
#   output_dir <- paste0("./output/", generateName("run"))
#   if (!dir.exists(output_dir)) {
#     dir.create(output_dir)
#   }
# }
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
# Sah quel plaisir for it to run so smoothly now.
# Still gotta implement hydro, however.

# NEXT STEP FOR HYDRO :
# (pendant que j'envoie des sommes de capacité à nicolas chef oui chef)

# implémenter les objets Generator avec _Hyd_ en prenant les facteurs de charge mensuels
# en en faisant des TS horaires
# en faisant * max capacité * units
# et en mettant tout ça dans Run of River
# (not gonna lie, les autres propriétés, je sais pas ce qu'on en fait)

# MDRR C'EST PAS INDIVIDUEL PAR CONTRE c'est juste on va aggregate tous les RoR ensemble
# enfin j'ai l'impression
# à redemander avant à Nicolas
# génial

# et, les objets Battery de type PHS
# bah en vrai y a pas midi à 14h en terme de nombre de propriétés
# ce qui est pas clair dans ma tête à la rigueur c'est diff entre
# injection, soutirage, stock, efficacité
# (et surtout c'est pas redondant ? genre injection = stock * efficacité nn ?)
# AH NON SI OK J'AI je crois
# capacité c'est énorme c'est la maxi taille du réservoir genre 34800
# injection c'est oulah ça peut pas non plus fournir infini MW dans le réseau à un instant t
# et du coup c'est le max power qui ici est à 182
# il faut plutôt faire d'ailleurs un objet par units parce que y a pas de "unités"
# dans antares batteries

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

