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

deane_nodes_path = ".\\input\\geo_list_of_nodes.csv"
deane_nodes_df <- read.csv(
  file = deane_nodes_path,
  header = TRUE,
  sep = ";",
  encoding = "UTF-8"
  )

print(deane_nodes_df)
print(colnames(deane_nodes_df))

zones = deane_nodes_df$Node


for (zone in zones) {
  # Il faudrait mettre ce truc dans le try, sinon ça met "adding" meme avant un fail, non ?
  # eh en vrai si isok
  cat(paste("Adding", zone, "node...\n"))
  country_code = getISOfromDeane(zone)
  # Use tryCatch to handle exceptions
  tryCatch({
    # Function that may throw an error
    # get_country_coordinates(country_code)
    coords = 
    x <- getAntaresCoordsFromCountry(country_code)$x
    y <- getAntaresCoordsFromCountry(country_code)$y
    createArea(
      name = zone,
      color = getColor(zone),
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

cat("Done adding nodes !\n")

deane_ntc_csv = ".\\input\\cross_border_transmission_capacities.txt"

ntc_df <- read.csv(
  deane_ntc_csv,
  header = TRUE,
  sep = ";",
  encoding = "UTF-8"
)

#print(ntc_df)
#print(colnames(ntc_df))
#print(ntc_df$From[10])

for (row in 1:nrow(ntc_df)) {
  from_node = ntc_df$From[row]
  to_node = ntc_df$To[row]
  ntc_direct = ntc_df$Max.Flow..MW.[row]
  ntc_indirect = -ntc_df$Min.Flow..MW.[row]
  #if (ntc_direct == 0 & ntc_indirect == 0){
    #cat(paste("Skipping ", from_node, " to ", to_node, " link (zero capacity)\n"))
    # nb : c'est bad long
  #} else {
    ts_link <- data.frame(
      rep(ntc_direct, 8760), 
      rep(ntc_indirect, 8760)
    )
    tryCatch({
      # Function that may throw an error
      createLink(
        from = from_node,
        to = to_node,
        tsLink = ts_link
      )
      # Point d'attention qu'il faudra vérifier : est-ce que si mauvais ordre
      # (eg from EU-AUT to AS-CHN, pas alphabétique), les capacités directe/indirecte
      # sont bien dans le bon ordre ? Surtout si différentes
      cat(paste("Linking ", from_node, " to ", to_node, "...\n"))
    }, 
    error = function(e) {
      # What happens if an error is thrown
      cat(paste("Skipping ", from_node, " to ", to_node, " link (one of the nodes may not exist)\n"))
    }
    )
    
    
    # Ajouter prints pour dire "skipping machin zero capacity"
  
  
  # TODO : faire un paramètre "include Deane null links" TRUE ou FALSE
  
  #}
  # Erreur : 'eu-kos' is not a valid area name,
  # Pareil faut une exception de Area pas trouvée
}

cat("Done adding links !")

# A ajouter : fonction qui chronometrent et l'affichent