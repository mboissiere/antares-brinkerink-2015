preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
source(preprocessPlexosData_module)

source(".\\src\\objects\\r_objects.R")

library(tidyr)

# print(full_2015_batteries_tbl)

library("data.table")

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
    
    max_power = batteries_tbl$max_power[row]
    initial_state = batteries_tbl$initial_state[row]
    efficiency = batteries_tbl$efficiency[row]
    # storage_parameters_list = list("injectionnominalcapacity" = max_power,
    #                           "withdrawalnominalcapacity" = max_power,
    #                           "reservoircapacity" = capacity,
    #                           "efficiency" = efficiency,
    #                           "initiallevel" = initial_state,
    #                           "initialleveloptim" = FALSE)
    storage_parameters_list <- storage_values_default()
    storage_parameters_list$injectionnominalcapacity <- max_power
    storage_parameters_list$withdrawalnominalcapacity <- max_power
    # Petit piège : "injection" c'est pompage parce que c'est du POV de
    # la batterie
    storage_parameters_list$reservoircapacity <- capacity
    storage_parameters_list$efficiency <- efficiency/100
    storage_parameters_list$initiallevel <- initial_state/100
    storage_parameters_list$initialleveloptim <- FALSE
    
    
    #storage_parameters <- as.data.table(storage_parameters_list)
    
    for (k in 1:units) {
      battery_name = paste0(batteries_tbl$battery_name[row], "_", k)
      
      # print(node)
      # print(battery_name)
      # print(cluster_type)
      # print(storage_parameters_list)
      # print(as.matrix(storage_parameters_list))
      # print(as.data.table(as.matrix(storage_parameters_list)))
      
      tryCatch({
        # suppressWarnings(as.data.table(matrix_data)) # c'est dangereux, 
        # mais je vois pas comment enlever ces warnings étranges autrement
        createClusterST(
          area = node,
          #cluster_name = battery_name,
          cluster_name = battery_name,
          group = cluster_type,
          storage_parameters = storage_parameters_list,
          
          PMAX_injection = hourly_ones_datatable,
          PMAX_withdrawal = hourly_ones_datatable,
          inflows = hourly_zeros_datatable,
          lower_rule_curve = hourly_zeros_datatable,
          upper_rule_curve = hourly_ones_datatable,
          # hell yeah c'était ça et ça a marché
          overwrite = TRUE,
          
          # là le warning x being coerced from class: matrix to data.table
          # est réellement mystérieux parce que y a mm pas de matrices ici
          
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
      # Pour plus de robustesse faudrait mettre le try catch "no batteery at all" en principe mais fleeeeeemme
    }
  }
}
# 
# Group: 'Other 2' is not a valid name recognized by Antares, you should be using one of: PSP_open, PSP_closed, Pondage, Battery, Other1, Other2, Other3, Other4, Other5
# 17: No cluster description available.
# 18: In createClusterST(area = node, cluster_name = battery_name,  ... :
#                          Group: 'PSP Closed' is not a valid name recognized by Antares, you should be using one of: PSP_open, PSP_closed, Pondage, Battery, Other1, Other2, Other3, Other4, Other5
#                        19: No cluster description available.
#                        
# bruh décidez vous mdr

# Et failed to add les batteries Battery aussi zut

# le warning c'est No cluster description available.
# peut-être que c'est une histoire de limite de caractères ? typiquement mon CSV a exporté en FRA_PHS_SuperBissortePu393
# à vvérifier sur antares web en vrai mais eh
# nop c'est pas ça, manuellement c'est ok