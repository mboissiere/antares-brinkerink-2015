# Chargement des packages nécessaires
# library(antaresRead)
library(antaresProcessing)
library(antaresViz)

# Ouais faut vraiment rendre ça plus propre
if (!LAUNCH_SIMULATION) {
  study_name = IMPORT_STUDY_NAME
  study_path = file.path("input", "antares_presets", study_name,
                     fsep = .Platform$file.sep)
  msg = paste("[MAIN] - Reading simulations of pre-existing", study_name, "study...")
  logMain(msg)
  
  simulation_name = IMPORT_SIMULATION_NAME
  setSimulationPath(study_path, simulation_name)
  if (simulation_name == -1) {
    msg = "[MAIN] - Opening latest simulation..."
    logMain(msg)
  } else {
    msg = paste("[MAIN] - Opening", simulation_name, "simulation...")
    logMain(msg)
  }
}
# A cleaner thing to do would be to pass the study name as argument of a function
# and to do the LAUNCH_SIMULATION check in main.

# Définir le chemin vers le dossier de l'étude Antares
# chemin_etude <- file.path("antares", "examples", "studies", study_name,
#                           fsep = .Platform$file.sep)
# 
# simulation <- -1
# 
# setSimulationPath(chemin_etude, simulation)

# Définir la plage de dates
start_date <- "2015-01-01"
end_date <- "2015-12-31"

# Charger les données de production au pas horaire pour toutes les zones
mydata <- readAntares(areas = "all",
                      # links = "all",
                      # clusters = "all",
                      mcYears = "all",
                      # timeStep = c("hourly", "daily", "weekly", "monthly", "annual"), J'ARRIVE PAS A AVOIR REGLAGE
                      select = c("SOLAR", "WIND", "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "LOAD"),
                      timeStep = "weekly"
                      # Ah euh, les imports et les exports quand même !!
)

# Créer un alias pour la stack de production
setProdStackAlias(
  name = "customStack",
  variables = alist(
    NUCLEAR = NUCLEAR,
    WIND = WIND,
    SOLAR = SOLAR,
    GAS = GAS,
    COAL = COAL,
    `MIX. FUEL` = `MIX. FUEL`
  ),
  colors = c("yellow", "turquoise", "orange", "red", "brown", "darkgreen"),
  lines = alist(
    LOAD = LOAD,
    TOTAL_PRODUCTION =  NUCLEAR + WIND + SOLAR + GAS + COAL + `MIX. FUEL`
  ),
  lineColors = c("black", "royalblue")
)

prodStack(
  x = mydata,
  stack = "customStack",
  areas = "all",
  dateRange = c(start_date, end_date),
  #timeStep = c("hourly", "daily", "weekly", "monthly", "annual"),
  #timestep = "weekly",
  #main = "Production horaire par mode de production",
  unit = "MWh"
)

# savePlotAsPng(plot, file = "Rplot.png", width = 600, height = 480, ...)

# # Lire les résultats de la simulation
# sim_results <- readAntares(
#   areas = "all",
#   links = "all",
#   clusters = "all",
#   mcYears = "all"
# )
# 
# # Afficher les résultats
# print(sim_results)

# Todo : AntaresViz

################################################################################

# # Chargement des packages nécessaires
# library(antaresRead)
# library(antaresProcessing)
# library(antaresViz)
# 
# # Définir le chemin vers le dossier de l'étude Antares
# # Dans l'idéal, faire ça dans la foulée dans que base_path et study_name sont encore en mémoire.
# # Ou alors, faire un truc qui les sauvegarde pour pouvoir les revisionner plus tard.
# chemin_etude <- file.path("antares", "examples", "studies", "Etude_sur_R_Monde__2024_07_26_19_22_38")
# # chemin_etude <- file.path("antares", "examples", "internal_studies", "9747b056-32ec-4a3f-a23e-e5c965594eec")
# simulation <- -1
# 
# setSimulationPath(chemin_etude, simulation)
# print(simOptions())
# # Antares project 'Etude_sur_R_Monde__2024_07_26_19_22_38' (C:/Users/boissieremat/Documents/GitHub/antares-brinkerink-2015/antares/examples/studies/Etude_sur_R_Monde__2024_07_26_19_22_38)
# # Simulation 'NA'
# # Mode Economy
# # 
# # Content:
# #   - synthesis: TRUE
# # - year by year: FALSE
# # - MC Scenarios: FALSE
# # - Number of areas: 42
# # - Number of districts: 0
# # - Number of links: 76
# # - Number of Monte-Carlo years: 0
# # si c'est vrai c'est très grave (year by year pas activé, alors qu'aurait du etre lu
# # au moment d'initialiser la simulation !!)
# 
# #  Je me rappelle d'un autre truc aussi. Il a fallu cocher la case manuellemenet
# # pour générer des TS thermiques et dire à antares "j'en ai pas".
# # et... est-ce que ça s'automatise sur R, le déclenchement de ça ? parce que je galère à trouver.
# # ah, en fouillant le generaldata.ini, on dirait que c'est generate = thermal.
# # reste à le mettre dans updateSettings.
# 
# # Définir la plage de dates
# start_date <- "2015-01-01"
# end_date <- "2015-12-31"
# 
# # Charger les données de production au pas horaire pour toutes les zones
# mydata <- readAntares(areas = "all",
#                       # links = "all",
#                       # clusters = "all",
#                       mcYears = "all",
#                       # timeStep = c("hourly", "daily", "weekly", "monthly", "annual"), J'ARRIVE PAS A AVOIR REGLAGE
#                       select = c("SOLAR", "WIND", "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "LOAD"),
#                       timeStep = "weekly"
# )
# #) # timeStep = "hourly",
# 
# # Prochaine étape le graphe avec une carte imo
# 
# #https://rdrr.io/github/rte-antares-rpackage/antaresViz/man/prodStack.html
# 
# # Créer un alias pour la stack de production
# setProdStackAlias(
#   name = "customStack",
#   variables = alist(
#     NUCLEAR = NUCLEAR,
#     WIND = WIND,
#     SOLAR = SOLAR,
#     GAS = GAS,
#     COAL = COAL,
#     `MIX. FUEL` = `MIX. FUEL`
#   ),
#   colors = c("yellow", "turquoise", "orange", "red", "brown", "darkgreen"),
#   lines = alist(
#     LOAD = LOAD,
#     TOTAL_PRODUCTION =  NUCLEAR + WIND + SOLAR + GAS + COAL + `MIX. FUEL` # Curieux : j'ai un screen avec le bleu en bas
#   ),
#   lineColors = c("black", "royalblue")
# )
# # Ce serait bien d'avoir le load par-dessus pour visualiser défaillance,
# # ainsi qu'imports/exports. Mais pas sûr de comment faire.
# 
# # Visualiser les données avec un empilement directement avec antaresViz
# prodStack(
#   x = mydata,
#   stack = "customStack",
#   areas = "all", 
#   dateRange = c(start_date, end_date),
#   #timeStep = c("hourly", "daily", "weekly", "monthly", "annual"),
#   #timestep = "weekly",
#   #main = "Production horaire par mode de production",
#   unit = "MWh"
# )
