# Ok, let's test how it's like to import a study
if (!CREATE_STUDY) {
  preset_name = "threePoints_minimal",
  preset = file.path("input", "antares_presets", preset_name,
                     fsep = .Platform$file.sep)
  msg = paste("[MAIN] - Reading pre-existing", preset_name, "study...")
  logMain(msg)
  setSimulationPath(preset, "input")
}
# A cleaner thing to do would be to pass the study name as argument of a function
# and to do the CREATE_STUDY check in main.

# Truc un peu relou : tout ça ne sauvegardera pas dans /output mais dans
# input/antares_presets/nom_etude/output
# donc y a un... input dans l'output ce qui casse un peu le truc
# à la rigueur faire des gitignore mais bon

# si j'arrive à faire un truc qui prend le .gitignore et qui écrit dedans
# pour enlever les /output sur tous les presets c'est fort mdr

# après, en soi, on s'en fout d'après le remettre dans Antares
# la lecture sur Antares Web est inintéressante au possible, c'est des tableurs
# donc juste prendre le machin et le AntaresVizer



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
#msg = paste0("[MAIN] - Successfully saved simulation in output/", simulation_name, " folder...")
#logMain(msg)
# En vérité c'est 20240731-1517eco-simulation__2024_07_31_15_17_31, à modifier

simulation_end_time <- Sys.time()
duration <- round(difftime(simulation_end_time, simulation_start_time, units = "mins"), 2)
msg = paste0("[MAIN] - Antares simulation finished! (run time : ", duration,"min).\n \n")
logMain(msg)