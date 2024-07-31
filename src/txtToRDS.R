source(".\\src\\data\\preProcessPlexosData.R")
source(".\\src\\data\\preProcessNinjaData.R")
source(".\\src\\data\\addNodes.R")

nodes_dir = ".\\src\\objects\\all_deane_nodes.rds"
generators_dir = ".\\src\\objects\\full_2015_generators_tbl.rds"
# avoir full ninja et aggregated ninja selon si clusters ou agg tsai
wind_clusters_dir = ".\\src\\objects\\wind_clusters_ninja_tbl.rds"


if (!file.exists(nodes_dir)) {
  nodes <- getAllNodes()
  saveRDS(nodes, file = nodes_dir)
}

nodes <- readRDS(nodes_dir)
print(nodes)

if (!file.exists(generators_dir)) {
  generators_tbl <- getGeneratorsFromNodes(nodes)
  generators_tbl <- filterFor2015(generators_tbl)
  generators_tbl <- addGeneralFuelInfo(generators_tbl)
  saveRDS(generators_tbl, file = generators_dir)
}

generators <- readRDS(generators_dir)
print(generators)

if (!file.exists(wind_clusters_dir)) {
  wind_ninja_tbl <- getTableFromNinja(WIND_DATA_PATH)
  saveRDS(wind_ninja_tbl, file = wind_clusters_dir)
}

wind_clusters <- readRDS(wind_clusters_dir)
print(wind_clusters)
# C'est vrai qu'à Deane il faudra remonter trucs usuels (eg what the hell voll)
# mais aussi les coquilles ("hihi j'ai remarqué une mauvaise date là")

# On est quand même sur une masterclass d'économie de temps si je réussis mon coup
# en plus les wind tbl passent en dessous des 100 MB, ça veut dire je peux même
# les push !! que la vie est belle
# manque plus que voir ce que feraient les presets de studies en format h5

# wind_aggregated_TS <- aggregateGeneratorTimeSeries(wind_generators_tbl, WIND_DATA_PATH)