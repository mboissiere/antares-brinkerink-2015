################################################################################
#################################### IMPORTS ###################################

library(antaresViz)

source(".\\src\\logging.R")

source(".\\src\\antaresReadResults_aux\\productionStacksPresets.R")
source(".\\src\\antaresReadResults_aux\\RR_init.R")
source(".\\src\\antaresReadResults_aux\\RR_config.R")
source(".\\src\\antaresReadResults_aux\\RR_utils.R")

setRam(16)
importAntaresData()
initializeOutputFolder(color_palette)

################################################################################
############################## PRODUCTION STACKS ###############################

if (save_production_stacks) {
  
}
