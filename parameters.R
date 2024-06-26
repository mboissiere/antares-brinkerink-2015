source(".\\src\\featuresTest2.R")

# Nom servant de base pour la classification de l'étude
study_basename <- "Etude_sur_R_Monde"

# Ajouter un paramètre "verbose" pour avoir ou non les prints sur la console

simulation_mode = "Economy" # "Adequacy", "Economy" ou "Draft"
horizon = 2015 # entier, année d'étude
nb_MCyears = 1 # entier, nombre d'années Monte-Carlo

renewable_generation_modelling = "clusters" # "aggregated" ou "clusters"

# zones = c("AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA")
  #c("FRA", "GBR", "DEU", "ITA", "ESP")


#zones = deane_nodes_df$Node
#print(zones)
#print(zones[1])
#print(getISOfromDeane(zones[1]))
#print(getAntaresCoordsFromCountry(getISOfromDeane(zones[1])))