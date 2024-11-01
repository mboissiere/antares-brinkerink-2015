library(antaresProcessing)
source("parameters.R")

importAntaresData <- function(#study_name = IMPORT_STUDY_NAME,
                              #simulation_name = IMPORT_SIMULATION_NAME
  ) {
  # euha aaaha je fais quoi après pour initializer le dossier
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
  sim_info <- c(study_name = study_name,
                simulation_name = simulation_name)
  return(sim_info)
}

################

source(".\\src\\antaresCreateStudy_aux\\saveObjects.R") # un peu ghetto comme architecture là
# on va dire que c'est provisoire..

initializeOutputFolderSimulation <- function(study_name = IMPORT_STUDY_NAME, 
                                   simulation_name = IMPORT_SIMULATION_NAME, 
                                   color_palette = "productionStackWithBatteryContributions"
) {
  if (READ_2060) {
    output_folder_dir <- initializeOutputFolderStudy(study_name)
    # woah mais du coup on le ré-initialise ? nan c'est chaud faut juste que je
    # stocke ça comme variable qqpart fin
    # simus_folder_dir <- file.path(output_folder_dir, SIMUS_DATA_FOLDER_NAME)
    simus_folder_dir <- output_folder_dir
    
    sim_folder_name <- paste0("sim-",
                              simulation_name,
                              "-palette-",
                              color_palette
    )
    sim_folder_name <- truncateString(sim_folder_name, 35)
    sim_dir <- file.path(simus_folder_dir, sim_folder_name)
    
    if (!dir.exists(sim_dir)) {
      dir.create(sim_dir)
    }
  } else {
    output_folder_dir <- initializeOutputFolderStudy(study_name)
    # woah mais du coup on le ré-initialise ? nan c'est chaud faut juste que je
    # stocke ça comme variable qqpart fin
    simus_folder_dir <- file.path(output_folder_dir, SIMUS_DATA_FOLDER_NAME)
    
    sim_folder_name <- paste0("sim-",
                              simulation_name,
                              "-palette-",
                              color_palette
    )
    sim_folder_name <- truncateString(sim_folder_name, 25)
    sim_dir <- file.path(simus_folder_dir, sim_folder_name)
    
    if (!dir.exists(sim_dir)) {
      dir.create(sim_dir)
    }
    
    
    graphs_dir <- file.path(sim_dir, "Graphs")
    if (!dir.exists(graphs_dir)) {
      dir.create(graphs_dir)
    }
    
    datasheets_dir <- file.path(sim_dir, "Datasheets (EMPTY)")
    if (!dir.exists(datasheets_dir)) {
      dir.create(datasheets_dir)
    }
    
    rawdata_dir <- file.path(sim_dir, "Raw data (EMPTY)")
    if (!dir.exists(rawdata_dir)) {
      dir.create(rawdata_dir)
    }
  }
  
  
  # Graphs
  ## mais au final je crois qu'on s'en cogne et qu'on le crée petit à petit
  # dans les fonctions ?
  
  # global_dir <- file.path(graphs_dir, "1 - Global-level graphs")
  # if (!dir.exists(global_dir)) {
  #   dir.create(global_dir)
  # }
  # 
  # continental_dir <- file.path(graphs_dir, "2 - Continental-level graphs")
  # if (!dir.exists(continental_dir)) {
  #   dir.create(continental_dir)
  # }
  # 
  # national_dir <- file.path(graphs_dir, "3 - National-level graphs")
  # if (!dir.exists(national_dir)) {
  #   dir.create(national_dir)
  # }
  # 
  # 
  # regional_dir <- file.path(graphs_dir, "4 - Regional-level graphs")
  # if (!dir.exists(regional_dir)) {
  #   dir.create(regional_dir)
  # }
  
  return(sim_dir)
}