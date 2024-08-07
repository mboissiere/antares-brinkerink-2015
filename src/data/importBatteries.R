preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
source(preprocessPlexosData_module)

source(".\\src\\objects\\r_objects.R")

library(tidyr)

# print(full_2015_batteries_tbl)


addBatteriesToAntares <- function(batteries_tbl) {
  
  for (row in 1:nrow(batteries_tbl)) {
    
    node = batteries_tbl$node[row]
    cluster_type = batteries_tbl$cluster_type[row]
    
    units = batteries_tbl$units[row]
    # à partir de là vu qu'il y a pas de "units" je peux faire plusieurs approches
    # que je peux mettre en paramètre.
    # soit : for k in units, créer une batterie que je nomme _k
    # soit, faire max_power x units
    # (et soit, agréger encore plus)
    capacity = batteries_tbl$capacity[row]
    # In supplementary material, it's actually written to be in GWh !
    max_power = batteries_tbl$max_power[row]
    initial_state = batteries_tbl$initial_state[row]
    efficiency = batteries_tbl$efficiency[row]
    
    storage_parameters_list = list("injectionnominalcapacity" = max_power,
                              "withdrawalnominalcapacity" = max_power,
                              "reservoircapacity" = capacity,
                              "efficiency" = efficiency,
                              "initiallevel" = initial_state,
                              "initialleveloptim" = FALSE)
    for (k in 1:units) {
      battery_name = paste0(batteries_tbl$battery_name[row], "_", k)
      tryCatch({
        createClusterST(
          area = node,
          cluster_name = battery_name,
          group = cluster_type,
          storage_parameters = storage_parameters_list,
          # blabla pmax inflows rule curve on n'a rien a priori
          # Nicolas : "Pour les STEP, on les modélise comme des stockages "court-terme" 
          # (donc des STEP closed-loop) avec un rendement de 75% et les données de 
          # puissance et de capa du fichier de Deane."
          # est-ce que ça veut dire qu'on peut ajouter des trucs ? eh je le lis pas comme ça
          add_prefix = FALSE
          )
        msg = paste("[STORAGE] - Adding", battery_name, "battery to", node, "node...")
        logFull(msg)
      }, error = function(e) {
        msg = paste("[WARN] - Failed to add", battery_name, "battery to", node, "node, skipping...")
        # Tiens, possible qu'à des endroit j'ai mis WARN et d'autres THERMAL/etc
        logError(msg)
      })
      
    }
  }
}