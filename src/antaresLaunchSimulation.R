simulation_name <- generateName("simulation")
msg = paste("[MAIN] - Starting", simulation_name, "simulation...")
logMain(msg)
simulation_start_time <- Sys.time()

#simulation_path <- file.path(study_path, "output", simulation_name)

antares_solver_path <- ".\\antares\\AntaresWeb\\antares_solver\\antares-8.8-solver.exe"

# Lancer la simulation
runSimulation(
  name = simulation_name,
  mode = "economy",
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