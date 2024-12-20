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
    horizon = horizon,
    nbyears = nb_MCyears,
    simulation.start = simulation_start,
    simulation.end = simulation_end,
    january.1st = find_january_1st_day(horizon),
    first.month.in.year = first_month_in_year,
    first.weekday = first_weekday,
    leapyear = is_leap_year(horizon),
    year.by.year = year_by_year,
    
    generate = c("thermal"),
    # nbtimeseriesload = 1,
    # nbtimeserieshydro = 1,
    # nbtimeserieswind = 1,
    nbtimeseriesthermal = 10,
    #nbtimeserieshydro = 10
  )
  
  updateOptimizationSettings(
    renewable.generation.modelling = RENEWABLE_GENERATION_MODELLING,
    unit.commitment.mode = UNIT_COMMITMENT_MODE
  )
  
  updateOutputSettings(
    synthesis = generateSynthesis
  )
  
  updateOptimizationSettings(
    include.exportmps = "true"
  )
}