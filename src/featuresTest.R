coordinates_csv = ".\\input\\countries_codes_and_coordinates\\countries_codes_and_coordinates.csv"

# Fonction pour récupérer les coordonnées (en barycentre) d'un pays
get_country_coordinates <- function(country_code) {
  
  df <- read.csv(
    coordinates_csv,
    header = TRUE,
    sep = ',',
    stringsAsFactors = FALSE)
  df$Alpha.3.code <- trimws(df$Alpha.3.code)
  
  # Filter dataframe by country code
  country_info <- subset(df, Alpha.3.code == country_code) #df[df$Alpha.3.code == toupper(country_code), ]
  
  if (nrow(country_info) == 0) {
    stop("Invalid country code or country not found in the dataset")
  }
  
  lat <- country_info$`Latitude..average.`
  lon <- country_info$`Longitude..average.`
  
  return(list(lat = lat, lon = lon))
}

coords <- get_country_coordinates('CHE')

# print(coords)

linear_transform_coordinates <- function(coords, lat_scale = 20, lon_scale = 20) {
  
  x <- coords$lon * lon_scale 
  y <- coords$lat * lat_scale
  return(list(x = x, y = y))
  
  
}

# print(linear_transform_coordinates(coords))

getAntaresCoordsFromCountry <- function(country_code) {
  return(linear_transform_coordinates(get_country_coordinates(country_code)))
}


# # Generate all unique pairs
# pairs <- combn(zones, 2, simplify = FALSE)
# 
# # Apply createLink to each pair
# for (pair in pairs) {
#   createLink(from = pair[1], to = pair[2])
# }

# A faire : algorithme de Prim ou Kruskal (qui commence par les noeuds faibles ?)
# avec un graphe complet des distances afin d'avoir un réseau complet cohérent pour l'infini

## Création de points pour chaque région

# A faire ensuite (et tant pis pour le nettoyage pour l'instant) :
# parser Deane pour avoir EU-AUT etc, pouvoir avoir les 3-country codes et
# recup coordonnees, puis importer valeurs.
# (ah, et il y a les noeuds regionaux aussi... fucc)
