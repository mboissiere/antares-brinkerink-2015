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


if (GENERATE_2060_CSP) {
  stack_palette = "eCO2MixFusionStack_noStorage_withCSP"
  monotone_palette = eCO2MixFusion_noStorage_withCSP_lst
} else {
  stack_palette = "eCO2MixFusionStack_noStorage_noOther"
  monotone_palette = eCO2MixFusion_noStorage_lst
}
output_dir <- initializeOutputFolderSimulation(study_name, simulation_name, stack_palette)

start_date_year = "2060-01-01" # 2026 en attendant de fix psk leap_year pas sûr si ça marche
end_date_year = "2060-12-31"
start_date_winter_week = "2060-08-02" # colloquially le winter hein
end_date_winter_week = "2060-08-08"
start_date_summer_week = "2060-04-05"
end_date_summer_week = "2060-04-11"
# Bon euh un truc qui serait cool aussi c'est de regarder non pas c'est quoi juste
# une random semaine été/hiver mais regarder LA PIRE dans le profil load XL S1 S2 etc
# genre hiver le pire des cas et été le plus doux des cas.
# nb on pourrait faire un run avec + de MC years hein.
# ça se fera sûrement pas tout de suite psk excel combiné avec R c'est bad long.

# Mois le plus bas pour S1 : avril (lundi 5 au dimanche 11)
# Mois le plus haut pour S1... août !! (lundi 2 au dimanche 8)

# pour S2 : idem
# pour tout en fait bon bah go hein

# si jamais jveux la refaire sur deane monde (mais bof utile) :
# pic est 08/01/2015 13:00
# bas est 04/10/2015 06:00

# et en vrai ici... osef les batteries hein

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


source(".\\src\\antaresReadResults_aux\\getProductionStacks.R")
if (save_daily_production_stacks) {
  
  saveAllProductionStacks(output_dir, "daily", start_date_year, end_date_year, stack_palette)
  
}

if (save_hourly_production_stacks) {
  
  saveAllProductionStacks(output_dir, "hourly", start_date_winter_week, end_date_winter_week, stack_palette)
  saveAllProductionStacks(output_dir, "hourly", start_date_summer_week, end_date_summer_week, stack_palette)
  
}


################################################################################
################################ LOAD MONOTONES ################################

MODES = c("global", "continental", "national", "regional")


if (save_load_monotones) {
  
  source(".\\src\\antaresReadResults_aux\\getLoadMonotones.R")
  
  for (mode in MODES) {
    if (boolean_parameter_by_mode[[mode]]) {
      msg = paste("[MAIN] - Preparing to save", mode, "load monotones...")
      logMain(msg)
      start_time <- Sys.time()
      
      unit <- preferred_unit_by_mode[[mode]]
      saveLoadMonotone(output_dir, mode, unit, "hourly", monotone_palette) 
      
      end_time <- Sys.time()
      duration <- round(difftime(end_time, start_time, units = "mins"), 2)
      msg = paste("[MAIN] - Done saving", mode, "load monotones! (run time :", duration,"min).\n")
      logMain(msg)
    }
    
  }
  
}
