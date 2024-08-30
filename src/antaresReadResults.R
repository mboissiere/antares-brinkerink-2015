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
importAntaresData()
output_dir <- initializeOutputFolder(color_palette)

################################################################################
############################## PRODUCTION STACKS ###############################

if (save_production_stacks) {
  
  source(".\\src\\antaresReadResults_aux\\getProductionStacks.R")
  
  if (save_global_graphs) {
    msg = "[MAIN] - Preparing to save global production stack..."
    logMain(msg)
    start_time <- Sys.time()
    
    saveGlobalProductionStack(output_dir) # à voir si la config je la fais ici ou pas
    # Ah et c'est vrai que normalement faudrait que je fasse des warnings etc..
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 2)
    msg = paste0("[MAIN] - Done saving global production stack! (run time : ", duration,"s).\n")
    # Et en fait c'est ptet pas là qu'il faudrait mettre le main, sinon incohérence avec les autres trucs où l'on précise timestep et date etc
    logMain(msg)
  }
  
  if (save_continental_graphs) {
    msg = "[MAIN] - Preparing to save continental production stacks..."
    logMain(msg)
    start_time <- Sys.time()
    
    saveContinentalProductionStack(output_dir)
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 2)
    msg = paste0("[MAIN] - Done saving continental production stacks! (run time : ", duration,"s).\n")
    logMain(msg)
  }
  
  if (save_national_graphs) {
    msg = "[MAIN] - Preparing to save national production stacks..."
    logMain(msg)
    start_time <- Sys.time()
    
    saveNationalProductionStacks(output_dir)
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "mins"), 2)
    msg = paste0("[MAIN] - Done saving national production stacks! (run time : ", duration,"min).\n")
    logMain(msg)
  }
  
  if (save_regional_graphs) {
    msg = "[MAIN] - Preparing to save regional production stacks..."
    logMain(msg)
    start_time <- Sys.time()
    
    saveRegionalProductionStacks(output_dir)
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "mins"), 2)
    msg = paste0("[MAIN] - Done saving regional production stacks! (run time : ", duration,"min).\n")
    logMain(msg)
  }
  
}
