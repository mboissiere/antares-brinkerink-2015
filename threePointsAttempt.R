# Charger les packages
library(antaresRead)
library(antaresEditObject)

# Définir le chemin racine des études
base_path <- ".\\antares\\examples\\studies"


# Fonction pour générer le nom de l'étude basé sur l'heure actuelle
generateName <- function(prefix) {
  timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
  return(paste0(prefix, "__", timestamp))
  }

# Exemple d'utilisation dans runSimulation
study_name <- generateName("Etude_sur_R")

print(study_name)

# Chemin complet vers l'étude
study_path <- file.path(base_path, study_name)

# Créer une nouvelle étude
createStudy(
  path = base_path,
  study_name = study_name,
  antares_version = "8.6.0"
  )

# Mettre à jour les paramètres généraux de l'étude
updateGeneralSettings(
  mode = "Economy",
  horizon = "2015", # Nombre d'années Monte-Carlo à préparer pour la simulation
  nbyears = 1,
  simulation.start = 1,
  simulation.end = 365,
  january.1st = "Thursday",
  first.month.in.year = "january",
  first.weekday = "Monday",
  leapyear = FALSE,
  year.by.year = TRUE,
  )

# Mettre à jour les paramètres d'optimisation
updateOptimizationSettings(
  unit.commitment.mode = "accurate",
  renewable.generation.modelling = "clusters" # "aggregated"
  )

# Mettre à jour les paramètres de sortie
updateOutputSettings(
  synthesis = TRUE,
  #storenewset = FALSE,
  #archives = c("load", "wind"),
  #result.format = "zip"
  )

# Ajouter des zones
createArea(
  name = "che",
  localization = c(8.2275, 46.8182)
)

createArea(
  name = "deu",
  localization = c(10.4515, 51.1657)
)

createArea(
  name = "fra",
  localization = c(2.2137, 46.6034)
)

# Ajouter une liaison entre les zones
createLink(
  from = "che", 
  to = "deu", 
  #propertiesLink = propertiesLinkOptions()
)

createLink(
  from = "che", 
  to = "fra", 
  #propertiesLink = propertiesLinkOptions()
)

createLink(
  from = "deu", 
  to = "fra", 
  #propertiesLink = propertiesLinkOptions()
)

# Définir le chemin menant aux données 2015
data_path <- ".\\input\\dataverse_files"

load_csv = "All Demand UTC 2015.csv"
load_path <- file.path(data_path, load_csv)

# Lire les données en spécifiant que toutes les colonnes sont numériques
load_data_matrix <- read.table(
  load_path,
  header = TRUE,
  sep = ",",
  row.names = 1,
  stringsAsFactors = FALSE)

# print(load_data_matrix)

writeInputTS(
  data = load_data_matrix$EU.CHE,
  type = "load",
  area = "che"
)

writeInputTS(
  data = load_data_matrix$EU.DEU,
  type = "load",
  area = "deu"
)

writeInputTS(
  data = load_data_matrix$EU.FRA,
  type = "load",
  area = "fra"
)

# Maintenant pour les clusters : https://rdrr.io/github/rte-antares-rpackage/antaresEditObject/man/editCluster.html
# Ce serait bien de pouvoir Giter quand même..



wind_csv = "Renewables.ninja.wind.output.Full.adjusted.csv"
wind_path <- file.path(data_path, wind_csv)

# Lire les données en spécifiant que toutes les colonnes sont numériques
wind_data_matrix <- read.table(wind_path, 
                               header = TRUE,
                               sep = ",",
                               dec = ".",
                               #row.names = 1,
                               stringsAsFactors = FALSE)
print(wind_data_matrix)
# stringsAsFactors
# logical: should character vectors be converted to factors? Note that this is overridden by as.is and colClasses, both of which allow finer control.
# pacompri, a comprendre

# Remplacer les espaces dans les noms des colonnes par des underscores
colnames(wind_data_matrix) <- gsub(" ", "_", colnames(wind_data_matrix))
# Remplacer les points dans les noms des colonnes par des underscores (sinon lu comme regex)
colnames(wind_data_matrix) <- gsub("\\.", "_", colnames(wind_data_matrix))
print(colnames(wind_data_matrix))

#print(wind_data_matrix)
print(wind_data_matrix$FRA_Win_Capacity_Scaler)

# Identifier les colonnes commençant par "FRA_"
cols_to_extract <- grep("^FRA_",
                        names(wind_data_matrix),
                        value = TRUE)
print(cols_to_extract)

# ça se généralise sûrement avec une fonction qui prendrait en argument le FRA
# et du matriciel

# Extraire les colonnes correspondantes
wind_data_fra <- wind_data_matrix[, cols_to_extract]

print(wind_data_fra)

# Boucle pour créer les clusters RES pour chaque éolienne française
for (col_name in names(wind_data_fra)) {
  # Extraire le nom de l'éolienne
  turbine_name <- sub("^FRA_", "", col_name)
  
  # Créer le cluster RES pour cette éolienne
  createClusterRES(
    area = "fra",
    cluster_name = paste("wind_", turbine_name, sep = ""),
    group = "Wind Onshore",  # Vous pouvez ajuster le groupe si nécessaire
    time_series = wind_data_fra[, col_name]
    # Ajoutez d'autres paramètres si nécessaire, comme unitcount, nominalcapacity, etc.
  )
}
# NB : il y a probablement redondance entre extraction matricielle et boucle for.
# je pense qu'à terme il faudra faire tout en matriciel pour aller plus vite.

# OUPS IL Y A AUSSI LA CONTRAINTE COUPLANTE KIRCHHOFF !!!
# Create the binding constraint
createBindingConstraint(
  name = "kirchhoff_che_deu_fra",
  operator = "equal",
  enabled = TRUE,
  timeStep = "hourly",
  coefficients = list("che%deu" = 1, "deu%fra" = 1, "che%fra" = -1)
)



# Exemple d'utilisation dans runSimulation
simulation_name <- generateName("simulation")
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



simulation <- -1

setSimulationPath(
  study_path,
  simulation
  ) 

# Lire les résultats de la simulation
sim_results <- readAntares(
  areas = "all",
  links = "all",
  clusters = "all",
  mcYears = "all"
)

# Afficher les résultats
print(sim_results)


# Prochaine étape : AntaresVizer ça !
# Et euh rajouter les cluster aussi psk y en a juste pas là

# Bon, résultats sont print mais pas sur AntaresWeb, étonnant. En tout cas vwala

# Ce serait bien aussi de faire des logs de "simulation path set !" fin des
# ptits tests pour vérifier que ça marche bien quoi