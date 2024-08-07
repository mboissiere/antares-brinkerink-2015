# Chargement des packages nécessaires
# library(antaresRead)
library(antaresProcessing)
library(antaresViz)

source("parameters.R")

# Ouais faut vraiment rendre ça plus propre

# Pour faire du transfert de simulations plus simplement en format compressé :
# https://rdrr.io/cran/antaresRead/f/vignettes/antaresH5.Rmd


if (!CREATE_STUDY) {
  study_name = IMPORT_STUDY_NAME
  study_path = file.path("input", "antares_presets", study_name,
                         fsep = .Platform$file.sep)
  msg = paste("[MAIN] - Reading simulations of pre-existing", study_name, "study...")
  # jsp pourquoi mais ça le print genre 3 fois
  logMain(msg)
}
if (!LAUNCH_SIMULATION) {
  simulation_name = IMPORT_SIMULATION_NAME
} else {
  simulation_name = -1
}
setSimulationPath(study_path, simulation_name)

if (simulation_name == -1) {
  msg = "[MAIN] - Opening latest simulation..."
  # ça aussi
  logMain(msg)
  } else {
    msg = paste("[MAIN] - Opening", simulation_name, "simulation...")
    logMain(msg)
  }

# Error in readAntares(areas = "all", links = "all", clusters = "all", mcYears = "all",  : 
#                        You want to load more than 10Go of data,
#                      if you want you can modify antaresRead rules of RAM control with setRam()
#Set maximum ram to used to 50 Go
setRam(16)
# If there's a way to read RAM on PC thatd be goated



# if (!LAUNCH_SIMULATION) { # hm, même si on a launch la simulation il faut bien faire ça non ??
#   study_name = IMPORT_STUDY_NAME
#   study_path = file.path("input", "antares_presets", study_name,
#                      fsep = .Platform$file.sep)
#   msg = paste("[MAIN] - Reading simulations of pre-existing", study_name, "study...")
#   logMain(msg)
#   
#   simulation_name = IMPORT_SIMULATION_NAME
#   setSimulationPath(study_path, simulation_name)
#   if (simulation_name == -1) {
#     msg = "[MAIN] - Opening latest simulation..."
#     logMain(msg)
#   } else {
#     msg = paste("[MAIN] - Opening", simulation_name, "simulation...")
#     logMain(msg)
#   }
# }
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
                      links = "all",
                      # clusters = "all", # pretty long, make an "import clusters" function.
                      # a good thing would also be to make districts for deane world
                      mcYears = "all",
                      # timeStep = c("hourly", "daily", "weekly", "monthly", "annual"), J'ARRIVE PAS A AVOIR REGLAGE
                      select = c("SOLAR", "WIND", 
                                 "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "OIL", 
                                 "LOAD", 
                                 "H. STOR", 
                                 "BALANCE", 
                                 "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4"),
                      timeStep = PLOT_TIMESTEP # ça c'est un paramètre qui serait bien dans parameters ça
                      # Ah euh, les imports et les exports quand même !!
)

# Créer un alias pour la stack de production
setProdStackAlias(
  name = "customStack",
  variables = alist(
    NUCLEAR = NUCLEAR,
    WIND = WIND,
    SOLAR = SOLAR,
    GEOTHERMAL = `MISC. DTG`,
    # Nota bene : dans les graphes finaux de Deane, en toute logique le CSP est dans solaire
    # enfin je crois il faudrait lui demander demander
    HYDRO = `H. STOR`,
    `BIO AND WASTE` = `MIX. FUEL`,
    GAS = GAS,
    COAL = COAL,
    OIL = OIL,
    OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    EXCHANGES = -BALANCE
  ),
  colors = c("yellow", "turquoise", "orange", "blue", "darkgreen",
             "red", "darkred", "darkslategray", "springgreen", "lavender",
             "grey"),
  lines = alist(
    LOAD = LOAD,
    TOTAL_PRODUCTION =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`
    # est-ce que les psp injection des batteries machin faut le mettre ? ou c'est du double comptage ?
  ),
  lineColors = c("black", "violetred")#"green")
)

# Comme graphes au total je pense qu'il faudrait faire :
# - stack de production
# - injection/soutirage des différentes formes de stockage
# - défaillances/spillage
# - émissions de CO2
# - échanges

prodStack(
  x = mydata,
  stack = "customStack",
  areas = "all",
  #links = "all",
  dateRange = c(start_date, end_date),
  #timeStep = c("hourly", "daily", "weekly", "monthly", "annual"),
  #timestep = "weekly",
  #main = "Production horaire par mode de production",
  unit = "MWh"
)


initializeOutputFolder <- function()
  output_dir = paste0("./output/results_", study_name, "--", simulation_name)
  # folder_dir <- paste0("./logs/logs_", format(Sys.time(), "%Y-%m-%d"))
  if (!dir.exists(output_dir)) {
  dir.create(output_dir)
  }
  
  # long term, this should probably end up in main/util
# and there should be like a h5 copy of study and simulation
# but so far, we want mostly screenshots soooooo

### let's make a function that saves a bunch of PNGs !
# savePlotAsPng(plot, file = "Rplot.png", width = 600, height = 480, ...)
# 
# plot	
# A plot generated with one of the functions of this package.
# 
# ## Not run: 
# mydata <- readAntares()
# myplot <- plot(mydata, variable = "MRG. PRICE", type = "density")
# savePlotAsPng(myplot, file = "myplot.png")
# 

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
