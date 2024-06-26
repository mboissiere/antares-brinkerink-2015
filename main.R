## Script principal regroupant le coeur du processus ##
## Les objets sont typiquement déjà définis dans les fichiers auxilliaires

# Charger les packages
library(antaresRead)
library(antaresEditObject)

# Importer des fonctions et variables auxilliaires créées dans d'autres scripts
# Clairement set le path une bonne fois pour toute parce que ça bug
# et qqfois passe de Documents, à Documents/RStudio/AntaresDeane2015...
# Edit : en fait il faut préciser (dans le README ptet) d'ouvrir le .rproj
# et c'est bon
source(".\\src\\featuresTest.R")
source(".\\src\\antaresFunctions.R")
#source("parameters.R")


## Création d'une nouvelle étude
study_name <- generateName(study_basename)
# study_path <- file.path(base_path, study_name)

createStudy(
  path = base_path,
  study_name = study_name,
  antares_version = antares_version
  )

updateAllSettings()

for (zone in zones) {
  cat(paste("Adding", zone, "node...\n"))
  country_code = getISOfromDeane(zone)
  # Use tryCatch to handle exceptions
  tryCatch({
    # Function that may throw an error
    get_country_coordinates(country_code)
    x <- getAntaresCoordsFromCountry(country_code)$x
    y <- getAntaresCoordsFromCountry(country_code)$y
    createArea(
      name = zone,
      localization = c(x, y)
    )
  }, error = function(e) {
    cat("Error in get_country_coordinates(", country_code, ") :\n")
    cat("  ", conditionMessage(e), "\n")
    cat("Skipping this country code and continuing...\n\n")
  })
  
  # Continue parsing data or performing other operations
  # after successful execution of get_country_coordinates()
  # For example:
  # parse_data_for_country(country_code)
  
}

cat("Done !")