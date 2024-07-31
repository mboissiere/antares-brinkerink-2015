preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
source(preprocessPlexosData_module)


getVoLLTable <- function() {
  voll_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Regions" & property == "VoLL") %>%
    select(child_object, value) %>%
    rename(
      continent = child_object,
      voll = value
    )
  return(voll_tbl)
}

# voll_tbl <- getVoLLTable()
# print(voll_tbl)

getVoLLTableFromNodes <- function(nodes) {
  nodes_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
    filter(class == "Node" & name %in% nodes) %>%
    select(name, category) %>%
    rename(
      node = name,
      continent = category
    )
  
  all_voll_tbl <- getVoLLTable()
  
  nodes_tbl <- nodes_tbl %>%
    left_join(all_voll_tbl, by = "continent")
  return(nodes_tbl)
}

# nodes = c("EU-FRA", "AF-MAR", "AS-JPN-CE")
# voll_tbl <- getVoLLTableFromNodes(nodes)
# print(voll_tbl)

addVoLLToAntares <- function(nodes,
                             study_path,
                             study_name,
                             log_verbose, # ça aussi...
                             console_verbose,
                             fullLog_file,
                             errorsLog_file
) {
  # print(study_path)
  # cat(paste("Study path :", study_path,"\n"))
  # # print("Test : overwriting to see if it helps")
  # # study_path <- gsub("/", "\\\\\\", study_path) # ptdr pk il faut 4 slashs pour écrire 1 slash là
  # # peut etre plus simple de faire un \\ directement avec study_name
  # antares_study_path = file.path("antares", "examples", "studies", study_name,
  #                                fsep = "\\\\"
  #                                #fsep = .Platform$file.sep
  #                                )
  # # Nop ça n'a pas du tout aidé
  # cat(paste("Study path :", antares_study_path))
  antares_study_path <- study_path
  cat(paste("Study path :", study_path,"\n"))
  setSimulationPath(path = antares_study_path, simulation = "input")
  
  voll_tbl <- getVoLLTableFromNodes(nodes)
  for (row in 1:nrow(voll_tbl)) {
    area_name = voll_tbl$node[row]
    area_voll = voll_tbl$voll[row]
    tryCatch({
      #NB : savoir ce que ça veut dire chacune de ces variables
      # psk pour l'instant c'est pas clair
      nodal_optimization_options = nodalOptimizationOptions(non_dispatchable_power = FALSE, 
                                                            dispatchable_hydro_power = FALSE,
                                                            other_dispatchable_power = FALSE,
                                                            spread_unsupplied_energy_cost = area_voll,
                                                            spread_spilled_energy_cost = 0,
                                                            average_unsupplied_energy_cost = area_voll,
                                                            average_spilled_energy_cost = 0
                                                            )
      editArea(node, 
               nodalOptimization = nodal_optimization_options,
               opts = antaresRead::simOptions()
               )
      if (log_verbose) {
        message = paste(Sys.time(),"- [VoLL] Adding value of lost load to", area_name, "node...\n")
        log_message(message, fullLog_file, console_verbose)
      }
    }, error = function(e) {
      if (log_verbose) {
        message = paste(Sys.time(),"- [WARN] Failed to add value of lost load to", area_name, "node, skipping...\n")
        log_message(message, fullLog_file, console_verbose)
        log_message(message, errorsLog_file, FALSE)
      }
    })
  }
  }
  

# editArea("de",  nodalOptimization = list("spilledenergycost" = list(fr = 30)), opts = antaresRead::simOptions())