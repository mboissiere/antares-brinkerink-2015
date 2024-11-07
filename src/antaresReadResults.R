################################################################################
#################################### IMPORTS ###################################

library(antaresViz)

source(".\\src\\logging.R")


source(".\\src\\antaresReadResults_aux\\colorPalettes.R")
source(".\\src\\antaresReadResults_aux\\RR_init.R")
source(".\\src\\antaresReadResults_aux\\RR_config.R")
source(".\\src\\antaresReadResults_aux\\RR_utils.R")
source(".\\src\\antaresReadResults_aux\\getAntaresData.R")



setRam(16)

study_info <- importAntaresData()
study_name <- study_info["study_name"]
simulation_name <- study_info["simulation_name"]

output_dir <- initializeOutputFolderSimulation(study_name, simulation_name, color_palette)


################################################################################
############################### DEANE HISTOGRAMS ###############################

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
  
  saveAllProductionStacks(output_dir, "hourly", "2015-01-05", "2015-01-11", color_palette)
  saveAllProductionStacks(output_dir, "hourly", "2015-07-06", "2015-07-12", color_palette)
  
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