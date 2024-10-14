source("parameters.R")
source(".\\src\\antaresReadResults_aux\\RR_init.R")
source(".\\src\\antaresReadResults_aux\\RR_utils.R")
# source(".\\src\\antaresReadResults_aux\\RR_config.R")


continental_data <- getContinentalAntaresData("hourly")
continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)

