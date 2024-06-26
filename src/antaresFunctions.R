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

antaresRed = grDevices::rgb(208, 2, 27, max = 255)
antaresOrange = grDevices::rgb(230, 108, 44, max = 255)
antaresYellow = grDevices::rgb(248, 231, 28, max = 255)
antaresGreen = grDevices::rgb(126, 211, 33, max = 255)
antaresDarkGreen = grDevices::rgb(65, 117, 5, max = 255)
antaresBlue = grDevices::rgb(74, 144, 226, max = 255)
antaresFuchsia = grDevices::rgb(189, 16, 224, max = 255)

color_dict <- c("EU" = antaresBlue,
                "AF" = antaresOrange,
                "AS" = antaresRed,
                "NA" = antaresGreen,
                "SA" = antaresYellow,
                "OC" = antaresFuchsia)

getColor <- function(nodeName) {
  continentCode = substr(nodeName, 1, 2)
  color <- color_dict[continentCode]
  return(color)
}

#print(getColor("EU-AUT"))



# Idée : faire un dossier "data" et un dossier "antares"
# En fait à terme il faudrait ptet faire un fichier genre parametres.txt avec
# ce qui peut amener à changer souvent, et ce qui sera très peu amené à changer