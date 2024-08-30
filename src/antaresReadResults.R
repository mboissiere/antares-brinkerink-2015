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

output_dir <- initializeOutputFolder(study_name, simulation_name, color_palette)

################################################################################
############################## PRODUCTION STACKS ###############################

if (save_production_stacks) {
  source(".\\src\\antaresReadResults_aux\\getProductionStacks.R")
  saveAllProductionStacks(output_dir)
  
  # Remember : faut faire daily, et hourly !
}


################################################################################
################################ LOAD MONOTONES ################################

# imma try something
MODES = c("global", "continental", "national", "regional")


if (save_load_monotones) {
  
  source(".\\src\\antaresReadResults_aux\\getLoadMonotones.R")
  
  for (mode in MODES) {
    if (boolean_parameter_by_mode[[mode]]) {
      msg = paste("[MAIN] - Preparing to save", mode, "load monotone...")
      logMain(msg)
      start_time <- Sys.time()
      
      unit <- preferred_unit_by_mode[[mode]]
      saveLoadMonotone(output_dir, mode, unit) 
      
      end_time <- Sys.time()
      duration <- round(difftime(end_time, start_time, units = "mins"), 2)
      msg = paste("[MAIN] - Done saving", mode, " load monotone! (run time :", duration,"min).\n")
      logMain(msg)
    }
    
  }
  
}
