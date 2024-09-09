source("architecture.R")

deane_all_nodes_name <- "deane_all_nodes_lst.rds"
deane_all_nodes_path <- file.path(OBJECTS_PATH, deane_all_nodes_name)
if (REGENERATE_OBJECTS | !file.exists(deane_all_nodes_path)) {
  source(addNodes_module)
  deane_all_nodes_lst <- getAllNodes()
  saveRDS(object = deane_all_nodes_lst,
          file = deane_all_nodes_path)
}


base_generator_name = "base_generators_tbl.rds"
if (REGENERATE_OBJECTS | !file.exists(file.path(OBJECTS_PATH, base_generator_name))) {
  source(preprocessPlexosData_module)
  base_generators_tbl <- getGeneratorsFromNodes(deane_all_nodes_lst)
  print(base_generators_tbl)
}