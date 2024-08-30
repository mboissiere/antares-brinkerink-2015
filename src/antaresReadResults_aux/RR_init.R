library(antaresProcessing)
source("parameters.R")

importAntaresData <- function() {
  if (!CREATE_STUDY) {
    study_name = IMPORT_STUDY_NAME
    study_path = file.path("input", "antares_presets", study_name,
                           fsep = .Platform$file.sep)
    msg = paste("[MAIN] - Reading simulations of pre-existing", study_name, "study...")
    logMain(msg)
  }
  if (!LAUNCH_SIMULATION) {
    simulation_name = IMPORT_SIMULATION_NAME
  } else {
    simulation_name = -1
  }
  setSimulationPath(study_path, simulation_name)
  
  if (simulation_name == -1) {
    msg = "[MAIN] - Opening latest simulation..."
    logMain(msg)
  } else {
    msg = paste("[MAIN] - Opening", simulation_name, "simulation...")
    logMain(msg)
  }
}

################

initializeOutputFolder <- function(color_palette = "productionStackWithBatteryContributions"
) {
  output_dir = paste0("./output/results_", 
                      study_name, 
                      "-sim-",
                      simulation_name,
                      "-palette-",
                      color_palette
  )
  
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  graphs_dir <- file.path(output_dir, "Graphs")
  if (!dir.exists(graphs_dir)) {
    dir.create(graphs_dir)
  }
  
  datasheets_dir <- file.path(output_dir, "Datasheets (EMPTY)")
  if (!dir.exists(datasheets_dir)) {
    dir.create(datasheets_dir)
  }
  
  rawdata_dir <- file.path(output_dir, "Raw data (EMPTY)")
  if (!dir.exists(rawdata_dir)) {
    dir.create(rawdata_dir)
  }
  
  # Graphs
  
  global_dir <- file.path(graphs_dir, "1 - Global-level graphs")
  if (!dir.exists(global_dir)) {
    dir.create(global_dir)
  }
  
  continental_dir <- file.path(graphs_dir, "2 - Continental-level graphs")
  if (!dir.exists(continental_dir)) {
    dir.create(continental_dir)
  }
  
  national_dir <- file.path(graphs_dir, "3 - National-level graphs")
  if (!dir.exists(national_dir)) {
    dir.create(national_dir)
  }
  
  
  regional_dir <- file.path(graphs_dir, "4 - Regional-level graphs")
  if (!dir.exists(regional_dir)) {
    dir.create(regional_dir)
  }
  
  return(output_dir)
}