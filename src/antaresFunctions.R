# Mode de la simulation
# - "Adequacy" vérifie simplement si on peut équilibrer production et conso
# - "Economy" réalise également une optimisation économique omnisciente sur le merit order
# - "Draft" est très rapide mais produit des résultats pas ouf
source(".\\src\\antaresVariables.R")
source(".\\src\\utils.R")
source("parameters.R")

### FONCTIONS ###

updateAllSettings <- function() {
  updateGeneralSettings(
    mode = simulation_mode,
    simulation.start = simulation_start,
    simulation.end = simulation_end,
    horizon = horizon,
    first.month.in.year = first_month_in_year,
    first.weekday = first_weekday,
    january.1st = find_january_1st_day(horizon),
    leapyear = is_leap_year(horizon),
    nbyears = nb_MCyears
  )
  
  updateOptimizationSettings(
    renewable.generation.modelling = renewable_generation_modelling
  )
  
  updateOutputSettings(
    synthesis = generateSynthesis
  )
}




# Idée : faire un dossier "data" et un dossier "antares"
# En fait à terme il faudrait ptet faire un fichier genre parametres.txt avec
# ce qui peut amener à changer souvent, et ce qui sera très peu amené à changer