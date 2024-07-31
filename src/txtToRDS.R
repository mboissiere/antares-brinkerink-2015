source(".\\src\\data\\preprocessPlexosData.R")
source(".\\src\\data\\preprocessNinjaData.R")
source(".\\src\\data\\addNodes.R")
# source(".\\src\\data\\importWind.R")
# source(".\\src\\data\\importSolar.R")
# J'ai mm pas la fonction pour importCSP alors que c'est un peu débile
# puisque c'est toujours le même principe mdr oups
# en vrai non ça vient de prepreprocessninja

# ah c'est aggregated pas aggregated bref
# bon le CSP je l'ai pas encore parce que c'est complique c'est des objets storage
# > csp_clusters <- readRDS(csp_clusters_file)
# > print(csp_clusters)
# # A tibble: 8,760 x 0
# # i Use `print(n = ...)` to see more rows
# mais à tout moment ça part

nodes_file = ".\\src\\objects\\all_deane_nodes_lst.rds"
generators_file = ".\\src\\objects\\full_2015_generators_tbl.rds"
# avoir full ninja et aggregated ninja selon si clusters ou agg tsai

wind_clusters_file = ".\\src\\objects\\wind_clusters_ninja_tbl.rds"
solar_clusters_file = ".\\src\\objects\\solar_clusters_ninja_tbl.rds"
csp_clusters_file = ".\\src\\objects\\csp_clusters_ninja_tbl.rds"

wind_aggregated_file = ".\\src\\objects\\wind_aggregated_ninja_tbl.rds"
solar_aggregated_file = ".\\src\\objects\\solar_aggregated_ninja_tbl.rds"
csp_aggregated_file = ".\\src\\objects\\csp_aggregated_ninja_tbl.rds"

# Not the most time costly, but could also import Load data ?
# How could thermal work ? Sadly I think what takes the time is creating
# individual Antares clusters, there's no working around that...

if (!file.exists(nodes_file)) {
  nodes <- getAllNodes()
  saveRDS(nodes, file = nodes_file)
}

nodes <- readRDS(nodes_file)
print(nodes)

if (!file.exists(generators_file)) {
  generators_tbl <- getGeneratorsFromNodes(nodes)
  generators_tbl <- filterFor2015(generators_tbl)
  generators_tbl <- addGeneralFuelInfo(generators_tbl)
  saveRDS(generators_tbl, file = generators_file)
}

generators <- readRDS(generators_file)
print(generators)

if (!file.exists(wind_clusters_file)) {
  wind_ninja_tbl <- getTableFromNinja(WIND_DATA_PATH)
  saveRDS(wind_ninja_tbl, file = wind_clusters_file)
}

wind_clusters <- readRDS(wind_clusters_file)
print(wind_clusters)
# C'est vrai qu'à Deane il faudra remonter trucs usuels (eg what the hell voll)
# mais aussi les coquilles ("hihi j'ai remarqué une mauvaise date là")

# On est quand même sur une masterclass d'économie de temps si je réussis mon coup
# en plus les wind tbl passent en dessous des 100 MB, ça veut dire je peux même
# les push !! que la vie est belle
# manque plus que voir ce que feraient les presets de studies en format h5
if (!file.exists(solar_clusters_file)) {
  solar_ninja_tbl <- getTableFromNinja(PV_DATA_PATH)
  saveRDS(solar_ninja_tbl, file = solar_clusters_file)
}

solar_clusters <- readRDS(solar_clusters_file)
print(solar_clusters)

# if (!file.exists(csp_clusters_file)) {
#   csp_ninja_tbl <- getTableFromNinja(CSP_DATA_PATH)
#   saveRDS(csp_ninja_tbl, file = csp_clusters_file)
# }
# 
# csp_clusters <- readRDS(csp_clusters_file)
# print(csp_clusters)

source(".\\src\\data\\importWind.R")

if (!file.exists(wind_aggregated_file)) {
  # wind_aggregated_tbl <- aggregateGeneratorTimeSeries(generators, WIND_DATA_PATH)
#   Error in `select()`:
#     ! Can't select columns that don't exist.
#   x Column `nominal_capacity` doesn't exist.
# Run `rlang::last_trace()` to see where the error occurred.
  # oups, c'est vrai qu'il faut faire un WindProperties
  
  wind_generators <- getWindPropertiesTable(generators)
  wind_aggregated_tbl <- aggregateGeneratorTimeSeries(wind_generators, WIND_DATA_PATH)
  
  saveRDS(wind_aggregated_tbl, file = wind_aggregated_file)
}

wind_aggregated <- readRDS(wind_aggregated_file)
print(wind_aggregated)

source(".\\src\\data\\importSolarPV.R")


if (!file.exists(solar_aggregated_file)) {
  solar_generators <- getSolarPVPropertiesTable(generators)
  solar_aggregated_tbl <- aggregateGeneratorTimeSeries(solar_generators, PV_DATA_PATH)
  
  saveRDS(solar_aggregated_tbl, file = solar_aggregated_file)
}

solar_aggregated <- readRDS(solar_aggregated_file)
print(solar_aggregated)

# Dans l'idéal, ce serait bien de faire un dossier preprocessing avec genre
# preprocessNinjaData, preprocessPLEXOSdata, txToRDS
# toutes ces fonctions qui... seront inutiles si on crée tous les objets RDS qu'on veut !
# mais, pour plus de transparence pour expliquer comment faire le passage CSV -> tibble,
# ça peut être chouette et pédagogue.
# ... mais pas prioritaire donc je sens que ça va être ciao