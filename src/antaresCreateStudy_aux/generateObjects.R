source("architecture.R")

deane_all_nodes_name <- "deane_all_nodes_lst.rds"
deane_all_nodes_path <- file.path(OBJECTS_PATH, deane_all_nodes_name)
if (REGENERATE_OBJECTS | !file.exists(deane_all_nodes_path)) {
  source(addNodes_module)
  deane_all_nodes_lst <- getAllNodes()
  # So far, AllNodes isn't tolowered.
  saveRDS(object = deane_all_nodes_lst,
          file = deane_all_nodes_path)
}


base_generators_name = "base_generators_tbl.rds"
base_generators_path <- file.path(OBJECTS_PATH, base_generators_name)
if (REGENERATE_OBJECTS | !file.exists(base_generator_path)) {
  source(preprocessPlexosData_module)
  base_generators_tbl <- getGeneratorsFromNodes(deane_all_nodes_lst)
  base_generators_tbl <- addGeneralFuelInfo(base_generators_tbl)
  base_generators_tbl <- getBaseGeneratorData(base_generators_tbl)
  print(base_generators_tbl, n = 200)
  # print(base_generators_tbl %>% filter(node == "as-jpn-ce" & antares_cluster_type == "Nuclear"))
  saveRDS(object = base_generators_tbl,
          file = base_generators_path)
}