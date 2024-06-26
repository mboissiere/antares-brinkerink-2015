# Charger les packages nécessaires
library(readr)
library(dplyr)
library(tidyr)

# Lire le premier fichier CSV avec des identifiants de pays
countries_df <- read.csv(
  ".\\input\\list_of_nodes.txt",
  sep = ";"
)

# Lire le deuxième fichier CSV avec les coordonnées latitude et longitude
coordinates_df <- read.csv(
  ".\\input\\country_codes\\countries-codes.csv",
  header = TRUE,
  sep = ";",
)

#print(coordinates_df)
print(colnames(coordinates_df))


# Renommer la colonne "LABEL EN" dans coordinates_df en "Country" pour correspondre à countries_df
coordinates_df <- coordinates_df %>% rename(Country = LABEL.EN)

print(colnames(coordinates_df))

# Sélectionner uniquement les colonnes nécessaires
coordinates_df <- coordinates_df %>% select(Country, geo_point_2d)

print(coordinates_df)

# Associer les coordonnées aux pays
updated_countries_df <- countries_df %>%
  left_join(coordinates_df, by = "Country")

print(updated_countries_df)

# Ajouter la colonne "coordinates_source" avec la valeur "ILO"
updated_countries_df <- updated_countries_df %>%
  mutate(coordinates_source = "ILO")

# Séparer geo_point_2d en lat et lon
updated_countries_df <- updated_countries_df %>%
  separate(geo_point_2d, into = c("lat", "lon"), sep = ", ", convert = TRUE)
print(updated_countries_df)
print(updated_countries_df$lat)

print(updated_countries_df)
print(colnames(updated_countries_df))

# Écrire le résultat dans un nouveau fichier CSV
write_csv(updated_countries_df, ".\\input\\geo_list_of_nodes.csv")
