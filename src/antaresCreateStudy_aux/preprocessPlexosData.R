library(dplyr) # To be commented if the main script has that
library(roxygen2)

########## PARAMETERS ##########

PLEXOS_PATH = file.path("input", "dataverse_files", "PLEXOS-World 2015 Gold V1.1")

OBJECTS_PATH = file.path(PLEXOS_PATH, "Objects.txt")
MEMBERSHIPS_PATH = file.path(PLEXOS_PATH, "Memberships.txt")
ATTRIBUTES_PATH = file.path(PLEXOS_PATH, "Attributes.txt")
PROPERTIES_PATH = file.path(PLEXOS_PATH, "Properties.txt")

########## FUNCTIONS ##########

# preprocessPLexosData était censé être général et j'y ait mis ma tambouille de generators...
# Bon, pas très grave

getTableFromPlexos <- function(plexos_data_path) {
  tbl <- read.table(plexos_data_path,
                    header = TRUE,
                    sep = ";",
                    stringsAsFactors = FALSE,
                    encoding = "UTF-8",
                    check.names = FALSE,
                    fill = TRUE
  )
  tbl <- as_tibble(tbl)
  return(tbl)
}

apply2015ConstructionFilter <- function(generators_tbl) {
  generator_names_to_remove <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(scenario == "{Object}Exclude 2016-2019 Generators") %>%
    pull(child_object) %>%
    unique() %>%
    tolower()
  
  generators_tbl <- generators_tbl %>%
    filter(!generator_name %in% generator_names_to_remove)
  return(generators_tbl)
}

apply2015NuclearFilter <- function(generators_tbl) {
  generator_names_to_remove <- getTableFromPlexos(PROPERTIES_PATH) %>%
    # filter(scenario == "{Object}Exclude 2016-2019 Generators") %>%
    # lmao theres no way im actually this fucking stupid
    # filter(scenario == "{Object}Exclude 2016-2019 Generators") %>%
    filter(memo == "With the exception of JPN_Nuc_Sendai13837 no active nuclear generators in Japan by 2015 due to Fukushima accident. https://en.wikipedia.org/wiki/Nuclear_power_in_Japan") %>%
    pull(child_object) %>%
    unique() %>%
    tolower()
  
  generators_tbl <- generators_tbl %>%
    filter(!generator_name %in% generator_names_to_remove)
  return(generators_tbl)
}

# filterGeneratorsByNodes <- function(generators_tbl, nodes) {
#   generators_tbl <- generators_tbl %>%
#     filter(node %in% nodes)
#   
#   return(generators_tbl)
# }

########## OBJECTS ###########

#' A small table linking fuel groups with fuel types
#' (e.g. : Europe_Win and Europe_Wof, representing respectively
#' European Onshore Wind and European Offshore Wind, are of type "Wind")
#' @examples
#' > print(fuels_tbl, n= 5)
#' # A tibble: 209 x 2
#' fuel_group fuel_type
#' <chr>      <chr>    
#'   1 Africa_Cog Gas      
#' 2 Africa_Gas Gas      
#' 3 Asia_Cog   Gas      
#' 4 Asia_Gas   Gas      
#' 5 Europe_Cog Gas      
#' # i 204 more rows
#' # i Use `print(n = ...)` to see more rows


# print(fuels_tbl)



# # Ah c'est de tidyr que vient pivot_wider
# library(tidyr)
# 
# getNodesAttributes <- function(nodes) {
#   attributes_tbl <- getTableFromPlexos(ATTRIBUTES_PATH) %>%
#     filter(class == "Node") %>%
#     filter(name %in% nodes) %>%
#     pivot_wider(names_from = attribute, values_from = value) %>%
#     rename(
#       node = name,
#       latitude = Latitude,
#       longitude = Longitude) %>%
#     select(node, latitude, longitude)
#   
#   return(attributes_tbl)
# }
# 
# print(getNodesAttributes(getAllNodes()))
# print(getNodesAttributes(c("EU-CHE", "EU-DEU", "EU-FRA")))

#####################



#####################


# En vrai faire des trucs genre addNodes, addGenerators avec
# getGeneratorsTable, filterGeneratorFromNodes, addProperties
# donc logique soit d'initialization, soit d'ajout via jointures, soit de filtres
# et de même aec nodes : getNodesTable, filter, addAttributes



getGeneratorsFromNodes <- function(nodes) {
  # Initialization of generators table with only generator names and continent of origin
  generators_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
    filter(class == "Generator") %>%
    select(name, category) %>%
    rename(generator_name = name,
           continent = category)
  
  # Adding country/node info to each generator
  generators_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
    filter(parent_class == "Generator" & child_class == "Node") %>%
    rename(generator_name = parent_object,
           node = child_object) %>%
    left_join(generators_tbl, by = "generator_name")
  
  # Forcing capital letters on generator names to avoid discrepancies with Ninja dataset
  generators_tbl <- generators_tbl %>%
    mutate(generator_name = tolower(generator_name))
  
  # Keep only nodes of interest
  generators_tbl <- generators_tbl %>%
    filter(node %in% nodes) %>%
    select(generator_name, continent, node)
  
  return(generators_tbl)
}
# 
# example <- getGeneratorsFromNodes(c("EU-CHE", "EU-DEU", "EU-FRA"))
# print(example)

filterFor2015 <- function(generators_tbl) {
  # This should be a parameter !!
  # Optional for 2015: removing data for generators built after 2015
  # Could be enabled/disabled via boolean, for example when setting horizon as 2015
  # or, could be in main code
  generators_tbl <- apply2015ConstructionFilter(generators_tbl)
  # Optional for 2015: removing data for JPN nuclear reactors, offline in 2015
  generators_tbl <- apply2015NuclearFilter(generators_tbl)
}
# Peut-être faire une colonne "was in 2015" dans un base_generators_tbl
# et comme ça filtrer plus loin sera simple.
# Ou même inclure le commission date en réussissant à le convertir sachant que
# le nuclear filter est différent.

# 
# example <- filterFor2015(example)
# print(example)

addGeneralFuelInfo <- function(generators_tbl) {
  fuels_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
    filter(class == "Fuel") %>%
    select(name, category) %>%
    rename(fuel_group = name,
           fuel_type = category)
  
  # Une mission à faire je pense : refactorer le code pour qu'il fasse genre.
  # Je prends les trucs. Je fous les wind dans un objet R. Et j'importe que ça.
  # et ça minimise le temps de calcul. et je teste sur l'Europe.
  # peut-être que je fais déjà ça ? je sais pas. je sais plus.
  
  # Adding fuel info to each generator
  generators_fuels_memberships_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
    filter(parent_class == "Generator" & child_class == "Fuel") %>%
    rename(generator_name = parent_object,
           fuel_group = child_object) %>%
    # Forcing capital letters on generator names as is convention now
    mutate(generator_name = tolower(generator_name)) %>%
    select(generator_name, fuel_group)
  
  generators_tbl <- generators_tbl %>%
    left_join(generators_fuels_memberships_tbl, by = "generator_name") %>%
    left_join(fuels_tbl, by = "fuel_group")
  
  # Adding a column for Antares cluster type
  # NOTE : All power plants outside the use cases defined (e.g. geothermal)
  # are then removed and thus will not be studied.
  # Finer implementation needs to be adjusted here.
  generators_tbl <- generators_tbl %>%
    mutate(cluster_type = case_when(
      grepl("Sol$", fuel_group) ~ "Solar PV",
      grepl("Csp$", fuel_group) ~ "Solar Thermal",
      
      grepl("Win$", fuel_group) ~ "Wind Onshore",
      grepl("Wof$", fuel_group) ~ "Wind Offshore",
      
      grepl("Gas$", fuel_group) ~ "Gas",
      grepl("Cog$", fuel_group) ~ "Gas", # Note that cogeneration is treated as regular gas
      grepl("Coa$", fuel_group) ~ "Hard Coal",
      grepl("Pet$", fuel_group) ~ "Oil",
      grepl("Nuc$", fuel_group) ~ "Nuclear",
      grepl("Bio$", fuel_group) ~ "Mixed Fuel", # Note that bio is treated as mixed fuel
      grepl("Was$", fuel_group) ~ "Mixed Fuel", # Note that waste is treated as mixed fuel
      grepl("Oil$", fuel_group) ~ "Oil",
      
      grepl("Hyd$", fuel_group) ~ "Hydro", # It's debateable whether or not this will be useful.
      # Hydro will probably require a very different implementation than the usual generators_tbl.
      grepl("Geo$", fuel_group) ~ "Other", # yep, Geothermal is on the menu
      # Group: 'Other 1' is not a valid name recognized by Antares, you should be using one of: Gas, Hard coal, Lignite, Mixed fuel, Nuclear, Oil, Other, Other 2, Other 3, Other 4
      
      grepl("Sto$", fuel_group) ~ "Other 2",
      grepl("Wav$", fuel_group) ~ "Other 3",
      grepl("Oth$", fuel_group) ~ "Other 4",
      # Dans les graphes, il y a une catégorie "Other" et je pense qu'on va pas se faire chier à importer par la suite
      # chaque truc individuellement alors qu'on peut juste mettre un "Other" tou poti.
      # cependant, c'est bête de perdre de l'information quand on pourrait un jour s'y intéresser.
      # D'où, les 4 others.
      # sure, why not at this point
      
      TRUE ~ NA_character_  # For unrelated child_object values (other)
    )) %>%
    filter(!is.na(cluster_type)) %>%
    
    # Chosen conventional order :
    # from most global (e.g. continent) to more informative (e.g. node)
    select(generator_name, continent, node, fuel_group, cluster_type, fuel_type)
  
  return(generators_tbl)
}

# example <- addGeneralFuelInfo(example)
# print(example)






# Mettre tout dans une fonction ici et filtrer par les nodes !!!
# genre getGeneratorsFromNodes pour une première moitié de pull + filtrage
# et addGeneralGeneratorInfo pour une deuxième moitié de remplissage d'info

# print(generators_tbl)
# Je pense structure dans code sera :
# generators_tbl <- preprocessPlexosData (quitte à ce que tout ce qui précède soit une fonction)
# ou genre generatorWiki ou jsp mais sans les properties
# et après fonctions dans importWind qui opèrent sur ce generators_tbl,
# peut-être le modifient mais ne cherchent pas forcément à sauvegarder l'info de toute façon

# rm() function in R Language is used to delete objects from the memory. 
# It can be used with ls() function to delete all objects. 
# remove() function is also similar to rm() function.

# gc() : free unused memory

# exampleNodes = c("EU-CHE", "EU-DEU", "EU-FRA")
# generators_tbl <- filterGeneratorsByNodes(generators_tbl, exampleNodes)
# print(generators_tbl)