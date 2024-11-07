# source(".\\src\\featuresTest2.R")

# Objets en snake_case, fonctions en camelCase

GENERATE_2060 = FALSE
GENERATE_2060_CSP = TRUE
WORLD_NODE = TRUE
IF_STUDY_NAME = "If S4 Economy v3 (Castillo load)"
IF_SCENARIO = "S1"
LOAD_PROFILES = "Castillo" # can be "Castillo" or "Deane"

READ_2060 = TRUE
THERMAL_BELOW = TRUE
save_co2_emissions = FALSE

IMPORT_STUDY_NAME = "If S1 Economy v3 (Deane load)"
IMPORT_SIMULATION_NAME = "20241031-1357eco-S1_defaillance50k"

# IMPORT_STUDY_NAME = "If S2 Economy v3 (Deane load)"
# IMPORT_SIMULATION_NAME = "20241031-1357eco-S2_defaillance50k"
# 
# IMPORT_STUDY_NAME = "If S3 Economy v3 (Deane load)"
# IMPORT_SIMULATION_NAME = "20241031-1357eco-S3_defaillance50k"

# IMPORT_STUDY_NAME = "If S4 Economy v3 (Deane load)"
# IMPORT_SIMULATION_NAME = "20241031-1357eco-S4_defaillance50k"


# Nom servant de base pour la classification de l'étude
study_basename <- "WorldT20B5_globGrid vf2"
# "World20T5B w hurdle costs"
INCLUDE_DATE_IN_STUDY = FALSE

RENEWABLE_GENERATION_MODELLING = "aggregated" # "aggregated" ou "clusters"

CREATE_STUDY = FALSE
LAUNCH_SIMULATION_NAME = "acc_test"
INCLUDE_DATE_IN_SIMULATION = FALSE
LAUNCH_SIMULATION = FALSE

READ_RESULTS = FALSE

PLOT_TIMESTEP = "hourly" # Pas sûr qu'il soit bien intégré actuellement, faut aller dans les fonctions

EXPORT_TO_OUTPUT_FOLDER = FALSE
INCLUDE_HURDLE_COSTS = FALSE
HURDLE_COST = 0.1
UNIFORM_VOLL = FALSE

INFINITE_NTC = TRUE
GLOBAL_GRID = TRUE

deane_all_nodes_lst <- readRDS(".\\src\\objects\\deane_all_nodes_lst.rds")
deane_europe_nodes_lst <- readRDS(".\\src\\objects\\deane_europe_nodes_lst.rds")
# africa_nodes_lst <- readRDS(".\\src\\objects\\africa_nodes_lst.rds")
# asia_nodes_lst <- readRDS(".\\src\\objects\\asia_nodes_lst.rds")
# north_america_nodes_lst <- readRDS(".\\src\\objects\\north_america_nodes_lst.rds")
# south_america_nodes_lst <- readRDS(".\\src\\objects\\south_america_nodes_lst.rds")
# oceania_nodes_lst <- readRDS(".\\src\\objects\\oceania_nodes_lst.rds")

# NODES = "eu-ita"
# NODES = deane_europe_nodes_lst
NODES = deane_all_nodes_lst
# NODES = c("EU-CHE", "EU-DEU", "EU-FRA")
# NODES = c("eu-che", "eu-deu", "eu-fra")
# NODES = c("eu-fra", "eu-gbr", "eu-deu", "eu-ita", "eu-esp", "af-mar", "af-dza", "af-tun")

# NODES = tolower(c("EU-FRA", "EU-GBR", "EU-BEL", "EU-LUX", "EU-DEU", "EU-CHE", "EU-ITA", "EU-ESP",
# "SA-ARG", "SA-CHL", "SA-URY", "SA-PRY",
# "AF-ZAF", "AF-NAM", "AF-BWA", "AF-ZWE", "AF-MOZ", "AF-SWZ", "AF-LSO"))
# un bon échantillon de test pour maintenance rate, mais pour réajuster les histogrammes


EXPORT_MPS = TRUE
REGENERATE_OBJECTS = FALSE # if true, will recreate all R objects.
# if false, will check if they exist, and only recreate them if they don't.
# bug actuel : il regénère les objects genre 3 fois. j'ai 3 fois le "oui euh found duplicates"


# NB : toutes les fonctions qui ré-appellent "NODES" en misant dessus / sans faire
# jsp une intersection avec le jeu de données ou quoi, sont pas si robustes.
# en effet si on a envie de faire tourner deux sessions R en même temps, on peut overwrite
# et causer des erreurs, eg un run NA suivi d'un run World et qui puise des noeuds qui existent pas,
# ce qui lancent des erreurs
# (peut-être que pour ça on peut bosser sur des copies de variables,
# et une fois que le run est lancé c'est pas touche ?)

save_daily_production_stacks = TRUE
save_hourly_production_stacks = FALSE 
divide_stacks_by_hours = FALSE

save_load_monotones = FALSE


save_import_export = FALSE

# save_deane_histograms = FALSE # deprecated jcrois
save_deane_comparisons = FALSE 

save_global_graphs = TRUE
save_continental_graphs = FALSE
save_national_graphs = FALSE
save_regional_graphs = FALSE
save_co2_emissions = TRUE


UNIT_COMMITMENT_MODE = "accurate" # "fast" or "accurate"

GENERATE_LOAD = TRUE

GENERATE_WIND = TRUE

GENERATE_SOLAR_PV = TRUE

GENERATE_SOLAR_CSP = FALSE

GENERATE_LINES = TRUE
GENERATE_THERMAL = TRUE

GENERATE_HYDRO = TRUE
GENERATE_BATTERIES = TRUE


GENERATE_DISTRICTS = TRUE
THERMAL_TYPES = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel", "Oil", 
                  "Other", "Other 2", "Other 3", "Other 4")
AGGREGATE_THERMAL = TRUE
CLUSTER_THERMAL = TRUE
NB_CLUSTERS_THERMAL = 20

CLUSTER_NAME_LIMIT = 60

AGGREGATE_BATTERIES = TRUE

CLUSTER_BATTERIES = TRUE
NB_CLUSTERS_BATTERIES = 5

ADD_VOLL = TRUE
INCLUDE_ZERO_NTC_LINES = TRUE

PRINT_FULL_LOG_TO_CONSOLE = TRUE
DEFAULT_SCALING_FACTOR = 20


simulation_mode = "Economy" # "Adequacy", "Economy" ou "Draft"
horizon = 2015 # entier, année d'étude
nb_MCyears = 10 # entier, nombre d'années Monte-Carlo
