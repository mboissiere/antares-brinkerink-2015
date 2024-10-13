################################################################################
#################################### IMPORTS ###################################

library(antaresViz)

source(".\\src\\logging.R")
# IMPORTANT !!! LOGS ARENT ACTUALLY BEING SAVED RN
# there are no logs from after 25/08 despite testing through 30/08
# I guess non-study-creating runs aren't important enough... We should fix this.

source(".\\src\\antaresReadResults_aux\\colorPalettes.R")
source(".\\src\\antaresReadResults_aux\\RR_init.R")
source(".\\src\\antaresReadResults_aux\\RR_config.R")
source(".\\src\\antaresReadResults_aux\\RR_utils.R")
source(".\\src\\antaresReadResults_aux\\getAntaresData.R")

# ERREUR CRUCIALE :
# la création d'objets et entre autres d'output folder est dans saveObjects que j'ai foutu dans createStudy je crois
# donc, l'output folder ne se crée pas si on a uniquement configuré un readResults parce que
# la simu a déjà existé ailleurs..
# EDIT : à peu près fix mais y a quand même un Graphs séparé alors que ça devrait être
# une dichotomie Study data / Simulations data

setRam(16)

study_info <- importAntaresData()
study_name <- study_info["study_name"]
simulation_name <- study_info["simulation_name"]

output_dir <- initializeOutputFolderSimulation(study_name, simulation_name, color_palette)


################################################################################
############################### DEANE HISTOGRAMS ###############################

# if (save_deane_histograms) {
#   
#   source(".\\src\\antaresReadResults_aux\\getDeaneHistograms.R")
#   
#   msg = "[MAIN] - Preparing to save continental generation histograms..."
#   logMain(msg)
#   start_time <- Sys.time()
#   
#   saveContinentalGenerationHistograms(output_dir)
#   
#   end_time <- Sys.time()
#   duration <- round(difftime(end_time, start_time, units = "secs"), 2)
#   msg = paste("[MAIN] - Done saving continental generation histograms! (run time :", duration,"s).\n")
#   logMain(msg)
#   
#   msg = "[MAIN] - Preparing to save continental emissions histograms..."
#   logMain(msg)
#   start_time <- Sys.time()
#   
#   saveContinentalEmissionHistograms(output_dir)
#   
#   end_time <- Sys.time()
#   duration <- round(difftime(end_time, start_time, units = "secs"), 2)
#   msg = paste("[MAIN] - Done saving continental emissions histograms! (run time :", duration,"s).\n")
#   logMain(msg)
#   
# }

if (save_deane_comparisons) {
  
  source(".\\src\\antaresReadResults_aux\\getDeaneHistograms.R")
  
  msg = "[MAIN] - Preparing to compare generation values with Deane..."
  logMain(msg)
  start_time <- Sys.time()
  
  saveGenerationDeaneComparison(output_dir)
  saveWorldGenerationDeaneComparison(output_dir)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste("[MAIN] - Done comparing generation values with Deane! (run time :", duration,"s).\n")
  logMain(msg)
  
  msg = "[MAIN] - Preparing to compare emissions values with Deane..."
  logMain(msg)
  start_time <- Sys.time()
  
  saveEmissionsDeaneComparison(output_dir)
  saveWorldEmissionsDeaneComparison(output_dir)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste("[MAIN] - Done comparing emissions values with Deane! (run time :", duration,"s).\n")
  logMain(msg)
  
}

################################################################################
############################## IMPORT/EXPORT RANK ##############################

if (save_import_export) {
  
  source(".\\src\\antaresReadResults_aux\\getImportExport.R")
  
  msg = "[MAIN] - Preparing to save import/export ranking of countries..."
  logMain(msg)
  start_time <- Sys.time()
  
  saveImportExportRanking(output_dir)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste("[MAIN] - Import/export ranking of countries has been saved ! (run time :", duration,"s).\n")
  logMain(msg)
  
}

################################################################################
############################## PRODUCTION STACKS ###############################

# Note : "Other/Wav/Sto" which i should understand, often seem to be modelled as free thermal.
# so maybe it should be on top of Geothermal in the stack actually..

source(".\\src\\antaresReadResults_aux\\getProductionStacks.R") # hm
# Remember : faut faire daily, et hourly !
if (save_daily_production_stacks) {
  
  # Mettre ici le log, timer, main, afin de pouvoir écrire "daily/hourly"
  saveAllProductionStacks(output_dir, "daily", "2015-01-01", "2015-12-31", color_palette)
  
}

if (save_hourly_production_stacks) {
  
  saveAllProductionStacks(output_dir, "hourly", "2015-01-01", "2015-01-08", color_palette)
  saveAllProductionStacks(output_dir, "hourly", "2015-07-01", "2015-07-08", color_palette)
  
}


################################################################################
################################ LOAD MONOTONES ################################

# imma try something
MODES = c("global", "continental", "national", "regional")


if (save_load_monotones) {
  
  source(".\\src\\antaresReadResults_aux\\getLoadMonotones.R")
  # Maybe the paths could too be in config or init !
  
  for (mode in MODES) {
    if (boolean_parameter_by_mode[[mode]]) {
      msg = paste("[MAIN] - Preparing to save", mode, "load monotones...")
      logMain(msg)
      start_time <- Sys.time()
      
      unit <- preferred_unit_by_mode[[mode]]
      saveLoadMonotone(output_dir, mode, unit) 
      
      end_time <- Sys.time()
      duration <- round(difftime(end_time, start_time, units = "mins"), 2)
      msg = paste("[MAIN] - Done saving", mode, "load monotones! (run time :", duration,"min).\n")
      logMain(msg)
    }
    
  }
  
}

# Une recommendation possiblement intéressante de GPT : faire du calcul parallèle
# pour pouvoir aller plus vite

# # Use parallel processing to save multiple plots concurrently
# cl <- makeCluster(detectCores() - 1) # Use one less than available cores
# clusterExport(cl, varlist = c("antares_tbl", "load_monot_dir", "monotone_width", 
#                               "monotone_height", "monotone_resolution", "unit", 
#                               "max_value", "min_value", "max_index", "min_index", 
#                               "renamedProdStackWithBatteries_lst", "data_lst"))
# 
# parLapply(cl, data_lst, function(item) { ...

# detectCores()
# [1] 8
# (!!)
