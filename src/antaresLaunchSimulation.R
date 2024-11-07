# Ok, let's test how it's like to import a study
if (!CREATE_STUDY) {
  preset_name = IMPORT_STUDY_NAME
  preset = file.path("input", "antares_presets", preset_name,
                     fsep = .Platform$file.sep)
  msg = paste("[MAIN] - Reading pre-existing", preset_name, "study...")
  logMain(msg)
  setSimulationPath(preset, "input")
}


source("parameters.R")

if (INCLUDE_DATE_IN_SIMULATION) {
  simulation_name <- generateName(LAUNCH_SIMULATION_NAME)
} else {
  simulation_name <- LAUNCH_SIMULATION_NAME
}

msg = paste("[MAIN] - Starting", simulation_name, "simulation...")
logMain(msg)
simulation_start_time <- Sys.time()

#simulation_path <- file.path(study_path, "output", simulation_name)

antares_solver_path <- ".\\antares\\AntaresWeb\\antares_solver\\antares-8.8-solver.exe"

# Lancer la simulation
runSimulation(
  name = simulation_name,
  mode = "economy", # ah, et ça aussi c'est un paramètre, mais bon...
  path_solver = antares_solver_path,
  wait = TRUE,
  show_output_on_console = TRUE,
  parallel = TRUE,
  #opts = antaresRead::setSimulationPath(simulation_path)
)



simulation_end_time <- Sys.time()
duration <- round(difftime(simulation_end_time, simulation_start_time, units = "mins"), 2)
msg = paste0("[MAIN] - Antares simulation finished! (run time : ", duration,"min).\n \n")
logMain(msg)