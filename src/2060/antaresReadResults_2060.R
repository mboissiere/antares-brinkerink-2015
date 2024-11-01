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


if (GENERATE_2060_CSP & THERMAL_BELOW) {
  stack_palette = "eCO2MixFusionStack_noStorage_withCSP_thermalBelow"
  monotone_palette = eCO2MixFusion_noStorage_withCSP_thermalBelow_lst
} else if (GENERATE_2060_CSP & !THERMAL_BELOW) {
  stack_palette = "eCO2MixFusionStack_noStorage_withCSP"
  monotone_palette = eCO2MixFusion_noStorage_withCSP_lst
} else {
  stack_palette = "eCO2MixFusionStack_noStorage_noOther"
  monotone_palette = eCO2MixFusion_noStorage_lst
}
output_dir <- initializeOutputFolderSimulation(study_name, simulation_name, stack_palette)

start_date_year = "2060-01-01" # 2026 en attendant de fix psk leap_year pas sûr si ça marche
end_date_year = "2060-12-31"

start_date_winter_week = "2060-07-19"
end_date_winter_week = "2060-07-25"
start_date_summer_week = "2060-05-03"
end_date_summer_week = "2060-05-09"

HEIGHT_HD <- 1080


# tbl <- as_tibble(readAntares("world", timeStep = "weekly"))
# tbl <- tbl %>% mutate(NET_LOAD = LOAD - `SOLAR PV` - `SOLAR CONCRT.` - `WIND ONSHORE`)
# print("Worst week :")
# tbl %>% filter(NET_LOAD == max(tbl %>% filter(timeId != 53 & timeId != 1) %>% pull(NET_LOAD)))
# print("Best week :")
# tbl %>% filter(NET_LOAD == min(tbl %>% filter(timeId != 53 & timeId != 1) %>% pull(NET_LOAD)))

# start_date_winter_week = "2060-08-02" # colloquially le winter hein
# end_date_winter_week = "2060-08-08"
# start_date_summer_week = "2060-04-05"
# end_date_summer_week = "2060-04-11"

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

# En fait si pour déterminer min et max !
# tbl <- as_tibble(readAntares("world", timeStep = "weekly"))
# Importing areas
# |===================================================================================================================================================================| 100%
# > tbl
# # A tibble: 53 x 324
# area  timeId time      `OV. COST`  `OP. COST` `OP. COST_std` `OP. COST_min` `OP. COST_max` `MRG. PRICE` `MRG. PRICE_std` `MRG. PRICE_min` `MRG. PRICE_max` `CO2 EMIS.`
# <fct>  <int> <fct>          <dbl>       <dbl>          <int>          <dbl>          <dbl>        <dbl>            <int>            <dbl>            <dbl>       <int>
#   1 world      1 2060-w01 13328145123 13328145123              0    13328145123    13328145123         29.2                0             29.2             29.2   485428185
# 2 world      2 2060-w02 27110980004 27110980004              0    27110980004    27110980004         42.6                0             42.6             42.6   902243507
# 3 world      3 2060-w03 27679794977 27679794977              0    27679794977    27679794977         47.2                0             47.2             47.2   909924088
# 4 world      4 2060-w04 28005068928 28005068928              0    28005068928    28005068928         47.0                0             47.0             47.0   919235318
# 5 world      5 2060-w05 25692696371 25692696371              0    25692696371    25692696371         45.6                0             45.6             45.6   881607546
# 6 world      6 2060-w06 25605626616 25605626616              0    25605626616    25605626616         36.7                0             36.7             36.7   888013838
# 7 world      7 2060-w07 23963258374 23963258374              0    23963258374    23963258374         30.8                0             30.8             30.8   858654344
# 8 world      8 2060-w08 24730641213 24730641213              0    24730641213    24730641213         32.0                0             32.0             32.0   874507332
# 9 world      9 2060-w09 24478844667 24478844667              0    24478844667    24478844667         29.5                0             29.5             29.5   878616257
# 10 world     10 2060-w10 24248905670 24248905670              0    24248905670    24248905670         30.4                0             30.4             30.4   864449765
# # i 43 more rows
# # i 311 more variables: `CO2 EMIS._std` <int>, `CO2 EMIS._min` <int>, `CO2 EMIS._max` <int>, `NH3 EMIS.` <int>, `NH3 EMIS._std` <int>, `NH3 EMIS._min` <int>,
# #   `NH3 EMIS._max` <int>, `SO2 EMIS.` <int>, `SO2 EMIS._std` <int>, `SO2 EMIS._min` <int>, `SO2 EMIS._max` <int>, `NOX EMIS.` <int>, `NOX EMIS._std` <int>,
# #   `NOX EMIS._min` <int>, `NOX EMIS._max` <int>, `PM2_5 EMIS.` <int>, `PM2_5 EMIS._std` <int>, `PM2_5 EMIS._min` <int>, `PM2_5 EMIS._max` <int>, `PM5 EMIS.` <int>,
# #   `PM5 EMIS._std` <int>, `PM5 EMIS._min` <int>, `PM5 EMIS._max` <int>, `PM10 EMIS.` <int>, `PM10 EMIS._std` <int>, `PM10 EMIS._min` <int>, `PM10 EMIS._max` <int>,
# #   `NMVOC EMIS.` <int>, `NMVOC EMIS._std` <int>, `NMVOC EMIS._min` <int>, `NMVOC EMIS._max` <int>, `OP1 EMIS.` <int>, `OP1 EMIS._std` <int>, `OP1 EMIS._min` <int>,
# #   `OP1 EMIS._max` <int>, `OP2 EMIS.` <int>, `OP2 EMIS._std` <int>, `OP2 EMIS._min` <int>, `OP2 EMIS._max` <int>, `OP3 EMIS.` <int>, `OP3 EMIS._std` <int>, ...
# # i Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
# > max(tbl %>% pull(LOAD))
# [1] 1794327844
# > tbl %>% filter(LOAD == max(tbl %>% pull(LOAD)))
# # A tibble: 1 x 324
# area  timeId time      `OV. COST`  `OP. COST` `OP. COST_std` `OP. COST_min` `OP. COST_max` `MRG. PRICE` `MRG. PRICE_std` `MRG. PRICE_min` `MRG. PRICE_max` `CO2 EMIS.`
# <fct>  <int> <fct>          <dbl>       <dbl>          <int>          <dbl>          <dbl>        <dbl>            <int>            <dbl>            <dbl>       <int>
#   1 world     30 2060-w30 33268738241 33268738241              0    33268738241    33268738241         52.8                0             52.8             52.8   975691886
# # i 311 more variables: `CO2 EMIS._std` <int>, `CO2 EMIS._min` <int>, `CO2 EMIS._max` <int>, `NH3 EMIS.` <int>, `NH3 EMIS._std` <int>, `NH3 EMIS._min` <int>,
# #   `NH3 EMIS._max` <int>, `SO2 EMIS.` <int>, `SO2 EMIS._std` <int>, `SO2 EMIS._min` <int>, `SO2 EMIS._max` <int>, `NOX EMIS.` <int>, `NOX EMIS._std` <int>,
# #   `NOX EMIS._min` <int>, `NOX EMIS._max` <int>, `PM2_5 EMIS.` <int>, `PM2_5 EMIS._std` <int>, `PM2_5 EMIS._min` <int>, `PM2_5 EMIS._max` <int>, `PM5 EMIS.` <int>,
# #   `PM5 EMIS._std` <int>, `PM5 EMIS._min` <int>, `PM5 EMIS._max` <int>, `PM10 EMIS.` <int>, `PM10 EMIS._std` <int>, `PM10 EMIS._min` <int>, `PM10 EMIS._max` <int>,
# #   `NMVOC EMIS.` <int>, `NMVOC EMIS._std` <int>, `NMVOC EMIS._min` <int>, `NMVOC EMIS._max` <int>, `OP1 EMIS.` <int>, `OP1 EMIS._std` <int>, `OP1 EMIS._min` <int>,
# #   `OP1 EMIS._max` <int>, `OP2 EMIS.` <int>, `OP2 EMIS._std` <int>, `OP2 EMIS._min` <int>, `OP2 EMIS._max` <int>, `OP3 EMIS.` <int>, `OP3 EMIS._std` <int>,
# #   `OP3 EMIS._min` <int>, `OP3 EMIS._max` <int>, `OP4 EMIS.` <int>, `OP4 EMIS._std` <int>, `OP4 EMIS._min` <int>, `OP4 EMIS._max` <int>, `OP5 EMIS.` <int>, ...
# # i Use `colnames()` to see all variable names
# > tbl %>% filter(LOAD == min(tbl %>% pull(LOAD)))
# # A tibble: 1 x 324
# area  timeId time      `OV. COST`  `OP. COST` `OP. COST_std` `OP. COST_min` `OP. COST_max` `MRG. PRICE` `MRG. PRICE_std` `MRG. PRICE_min` `MRG. PRICE_max` `CO2 EMIS.`
# <fct>  <int> <fct>          <dbl>       <dbl>          <int>          <dbl>          <dbl>        <dbl>            <int>            <dbl>            <dbl>       <int>
#   1 world     53 2060-w53 10426035258 10426035258              0    10426035258    10426035258         30.7                0             30.7             30.7   370705100
# # i 311 more variables: `CO2 EMIS._std` <int>, `CO2 EMIS._min` <int>, `CO2 EMIS._max` <int>, `NH3 EMIS.` <int>, `NH3 EMIS._std` <int>, `NH3 EMIS._min` <int>,
# #   `NH3 EMIS._max` <int>, `SO2 EMIS.` <int>, `SO2 EMIS._std` <int>, `SO2 EMIS._min` <int>, `SO2 EMIS._max` <int>, `NOX EMIS.` <int>, `NOX EMIS._std` <int>,
# #   `NOX EMIS._min` <int>, `NOX EMIS._max` <int>, `PM2_5 EMIS.` <int>, `PM2_5 EMIS._std` <int>, `PM2_5 EMIS._min` <int>, `PM2_5 EMIS._max` <int>, `PM5 EMIS.` <int>,
# #   `PM5 EMIS._std` <int>, `PM5 EMIS._min` <int>, `PM5 EMIS._max` <int>, `PM10 EMIS.` <int>, `PM10 EMIS._std` <int>, `PM10 EMIS._min` <int>, `PM10 EMIS._max` <int>,
# #   `NMVOC EMIS.` <int>, `NMVOC EMIS._std` <int>, `NMVOC EMIS._min` <int>, `NMVOC EMIS._max` <int>, `OP1 EMIS.` <int>, `OP1 EMIS._std` <int>, `OP1 EMIS._min` <int>,
# #   `OP1 EMIS._max` <int>, `OP2 EMIS.` <int>, `OP2 EMIS._std` <int>, `OP2 EMIS._min` <int>, `OP2 EMIS._max` <int>, `OP3 EMIS.` <int>, `OP3 EMIS._std` <int>,
# #   `OP3 EMIS._min` <int>, `OP3 EMIS._max` <int>, `OP4 EMIS.` <int>, `OP4 EMIS._std` <int>, `OP4 EMIS._min` <int>, `OP4 EMIS._max` <int>, `OP5 EMIS.` <int>, ...
# # i Use `colnames()` to see all variable names


##Counting unsupplied hours
# tbl <- as_tibble(readAntares("world", timeStep = "hourly"))
# unsupplied_hours_tbl <- tbl %>% filter(`UNSP. ENRG` != 0)
# unsupplied_hours_tbl
# spillage_hours_tbl <- tbl %>% filter(`SPIL. ENRG` != 0)
# spillage_hours_tbl
# En S1 : 8389 h
# En S2 : 7441 h
# En S3 : 0 h
# En S4 : 8139 h



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

#### NEW GRAPH : CO2 EMISSIONS

if (save_co2_emissions) {
  # scenario_number <- IF_SCENARIO
  
  ts_height <- HEIGHT_HD
  ts_width <- 1.4 * HEIGHT_HD
  
  
  # IMPORT_STUDY_NAME = 
  # IMPORT_SIMULATION_NAME = 
  
  # IMPORT_STUDY_NAME = "If S3 Economy v3 (Deane load)"
  # IMPORT_SIMULATION_NAME = "20241031-1357eco-S3_defaillance50k"
  
  # IMPORT_STUDY_NAME = "If S4 Economy v3 (Deane load)"
  # IMPORT_SIMULATION_NAME = "20241031-1357eco-S4_defaillance50k"

  
  msg = "[MAIN] - Preparing to save CO2 emissions plot..."
  logMain(msg)
  start_time <- Sys.time()
  
  s1_study_name = "If S1 Economy v3 (Deane load)"
  s1_study_path = file.path("input", "antares_presets", s1_study_name,
                            fsep = .Platform$file.sep)
  s1_simulation_name = "20241031-1357eco-S1_defaillance50k"
  setSimulationPath(s1_study_path, s1_simulation_name)
  
  s1_data <- readAntares(areas = "world", timeStep = "daily")
  
  s2_study_name = "If S2 Economy v3 (Deane load)"
  s2_study_path = file.path("input", "antares_presets", s2_study_name,
                            fsep = .Platform$file.sep)
  s2_simulation_name = "20241031-1357eco-S2_defaillance50k"
  setSimulationPath(s2_study_path, s2_simulation_name)
  
  s2_data <- readAntares(areas = "world", timeStep = "daily")
  
  # global_data <- getGlobalAntaresData("daily", FALSE)
  # print(global_data)
  
  # BON C'EST HYPER NUL JE FERAIS MIEUX D'UTILISER GGPLOT2 DIRECTEMENT
  # MEME SI C'EST UN PEU TARD POUR CA LA SAYER
  ts_plot <- tsPlot(
    x = list(s1_data, s2_data), # global_data,
    # refStudy = NULL,
    # table = NULL,
    variable = "CO2 EMIS.",
    elements = "world",
    # variable2Axe = NULL,
    mcYear = "average",
    # type = c("ts", "barplot", "monotone", "density", "cdf", "heatmap"),
    type = "ts",
    dateRange = c(start_date_year, end_date_year),
    # typeConfInt = FALSE,
    # confInt = 0,
    # minValue = NULL,
    maxValue = 145000000,
    # aggregate = c("none", "mean", "sum", "mean by variable", "sum by variable"),
    compare = "variable",
    # compareOpts = list(),
    interactive = FALSE,
    colors = c("black", "red"),
    main = paste("CO2 emissions of", scenario_number, "scenario in 2060"),
    # ylab = NULL,
    # legend = TRUE,
    # legendItemsPerRow = 5,
    # colorScaleOpts = colorScaleOptions(20),
    # width = ts_width,
    # height = ts_height,
    # xyCompare = c("union", "intersect"),
    # h5requestFiltering = deprecated(),
    # highlight = FALSE,
    # stepPlot = FALSE,
    # drawPoints = FALSE,
    # secondAxis = FALSE,
    # timeSteph5 = deprecated(),
    # mcYearh5 = deprecated(),
    # tablesh5 = deprecated(),
    # language = "en",
    # hidden = NULL,
    # ...
  )
  
  co2_ts_dir <- file.path(output_dir, "CO2 emissions timeseries")
  
  if (!dir.exists(co2_ts_dir)) {
    dir.create(co2_ts_dir)
  }
  
  png_path = file.path(co2_ts_dir, paste0("world", ".png"))
  savePlotAsPng(ts_plot, file = png_path,
                width = ts_width,
                height = ts_height
  )
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste("[MAIN] - CO2 emissions plot has been saved ! (run time :", duration,"s).\n")
  logMain(msg)
}

