# Charger les packages nécessaires
library(readr)
library(dplyr)

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
print(coordinates_df[1])


# Renommer la colonne "LABEL EN" dans coordinates_df en "Country" pour correspondre à countries_df
coordinates_df <- coordinates_df %>% rename(Country = 'LABEL EN')

# Sélectionner uniquement les colonnes nécessaires
coordinates_df <- coordinates_df %>% select(Country, geo_point_2d)

# Associer les coordonnées aux pays
updated_countries_df <- countries_df %>%
  left_join(coordinates_df, by = "Country")

# Ajouter la colonne "coordinates_source" avec la valeur "ILO"
updated_countries_df <- updated_countries_df %>%
  mutate(coordinates_source = "ILO")

# Écrire le résultat dans un nouveau fichier CSV
write_csv(updated_countries_df, ".\\input\\updated_list_of_nodes.csv")
