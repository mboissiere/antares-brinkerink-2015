source(".\\src\\data\\preprocessPlexosData.R")
source(".\\src\\data\\preprocessNinjaData.R")
source(".\\src\\data\\addNodes.R")
# source(".\\src\\data\\importWind.R")
# source(".\\src\\data\\importSolar.R")

# On pourrait également sauvegarder ici les properties tables
# au lieu de repasser à chaque fois par GetWindPropertiesTable etc
# parce que pour l'aggregated ok mais pour les clusters ? ça peut aller plus vite
# également par rapport à refaire le pivot_wider à chaque fois etc

nodes_file = ".\\src\\objects\\all_deane_nodes_lst.rds"
generators_file = ".\\src\\objects\\full_2015_generators_tbl.rds"
# avoir full ninja et aggregated ninja selon si clusters ou agg

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

if (!file.exists(solar_clusters_file)) {
  solar_ninja_tbl <- getTableFromNinja(PV_DATA_PATH)
  saveRDS(solar_ninja_tbl, file = solar_clusters_file)
}

solar_clusters <- readRDS(solar_clusters_file)
print(solar_clusters)

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