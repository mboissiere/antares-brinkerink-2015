library(dplyr) # To be commented if the main script has that
library(roxygen2)

########## PARAMETERS ##########

PLEXOS_PATH = file.path("input", "dataverse_files", "PLEXOS-World 2015 Gold V1.1")

PLEXOS_OBJECTS_PATH = file.path(PLEXOS_PATH, "Objects.txt")
MEMBERSHIPS_PATH = file.path(PLEXOS_PATH, "Memberships.txt")
ATTRIBUTES_PATH = file.path(PLEXOS_PATH, "Attributes.txt")
PROPERTIES_PATH = file.path(PLEXOS_PATH, "Properties.txt")

########## FUNCTIONS ##########

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
    filter(memo == "With the exception of JPN_Nuc_Sendai13837 no active nuclear generators in Japan by 2015 due to Fukushima accident. https://en.wikipedia.org/wiki/Nuclear_power_in_Japan") %>%
    pull(child_object) %>%
    unique() %>%
    tolower()
  
  generators_tbl <- generators_tbl %>%
    filter(!generator_name %in% generator_names_to_remove)
  return(generators_tbl)
}


getGeneratorsFromNodes <- function(nodes) {
  # Initialization of generators table with only generator names and continent of origin
  generators_tbl <- getTableFromPlexos(PLEXOS_OBJECTS_PATH) %>%
    filter(class == "Generator") %>%
    select(name, category) %>%
    mutate(generator_name = tolower(name),
           continent = tolower(category))
  
  # Adding country/node info to each generator
  generators_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
    filter(parent_class == "Generator" & child_class == "Node") %>%
    mutate(generator_name = tolower(parent_object),
           node = tolower(child_object)) %>%
    left_join(generators_tbl, by = "generator_name")
  
  # Keep only nodes of interest
  generators_tbl <- generators_tbl %>%
    filter(node %in% nodes) %>%
    select(generator_name, continent, node)
  
  # # Forcing capital letters on generator names to avoid discrepancies with Ninja dataset
  # generators_tbl <- generators_tbl %>%
  #   mutate(generator_name = tolower(generator_name),
  #          continent = tolower(continent),
  #          node = tolower(node))
  # and actually on more stuff to never worry about capitalization, antares uses small letters anyway
  
  return(generators_tbl)
}
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
  fuels_tbl <- getTableFromPlexos(PLEXOS_OBJECTS_PATH) %>%
    filter(class == "Fuel") %>%
    select(name, category) %>%
    rename(plexos_fuel_group = name,
           plexos_fuel_type = category)
  
  # Une mission à faire je pense : refactorer le code pour qu'il fasse genre.
  # Je prends les trucs. Je mets les wind dans un objet R. Et j'importe que ça.
  # et ça minimise le temps de calcul. et je teste sur l'Europe.
  # peut-être que je fais déjà ça ? je sais pas. je sais plus.
  
  # Adding fuel info to each generator
  generators_fuels_memberships_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
    filter(parent_class == "Generator" & child_class == "Fuel") %>%
    rename(generator_name = parent_object,
           plexos_fuel_group = child_object) %>%
    # Forcing capital letters on generator names as is convention now
    mutate(generator_name = tolower(generator_name)) %>%
    select(generator_name, plexos_fuel_group)
  
  generators_tbl <- generators_tbl %>%
    left_join(generators_fuels_memberships_tbl, by = "generator_name") %>%
    left_join(fuels_tbl, by = "plexos_fuel_group")
  
  # Adding a column for Antares cluster type
  # NOTE : All power plants outside the use cases defined (e.g. geothermal)
  # are then removed and thus will not be studied.
  # Finer implementation needs to be adjusted here.
  generators_tbl <- generators_tbl %>%
    mutate(antares_cluster_type = case_when(
      grepl("Sol$", plexos_fuel_group) ~ "Solar PV",
      grepl("Csp$", plexos_fuel_group) ~ "Solar Thermal",
      
      grepl("Win$", plexos_fuel_group) ~ "Wind Onshore",
      grepl("Wof$", plexos_fuel_group) ~ "Wind Offshore",
      
      grepl("Gas$", plexos_fuel_group) ~ "Gas",
      grepl("Cog$", plexos_fuel_group) ~ "Gas", # Note that cogeneration is treated as regular gas
      grepl("Coa$", plexos_fuel_group) ~ "Hard Coal",
      grepl("Pet$", plexos_fuel_group) ~ "Oil",
      grepl("Nuc$", plexos_fuel_group) ~ "Nuclear",
      grepl("Bio$", plexos_fuel_group) ~ "Mixed Fuel", # Note that bio is treated as mixed fuel
      grepl("Was$", plexos_fuel_group) ~ "Mixed Fuel", # Note that waste is treated as mixed fuel
      grepl("Oil$", plexos_fuel_group) ~ "Oil",
      
      grepl("Hyd$", plexos_fuel_group) ~ "Hydro", # It's debateable whether or not this will be useful.
      # Hydro will probably require a very different implementation than the usual generators_tbl.
      grepl("Geo$", plexos_fuel_group) ~ "Other", # yep, Geothermal is on the menu
      # Group: 'Other 1' is not a valid name recognized by Antares, you should be using one of: Gas, Hard coal, Lignite, Mixed fuel, Nuclear, Oil, Other, Other 2, Other 3, Other 4
      
      grepl("Sto$", plexos_fuel_group) ~ "Other 2",
      grepl("Wav$", plexos_fuel_group) ~ "Other 3",
      grepl("Oth$", plexos_fuel_group) ~ "Other 4",
      # Dans les graphes, il y a une catégorie "Other" et je pense qu'on va pas se faire chier à importer par la suite
      # chaque truc individuellement alors qu'on peut juste mettre un "Other" tou poti.
      # cependant, c'est bête de perdre de l'information quand on pourrait un jour s'y intéresser.
      # D'où, les 4 others.
      # sure, why not at this point
      
      TRUE ~ NA_character_  # For unrelated child_object values (other)
    )) %>%
    filter(!is.na(antares_cluster_type)) %>%
    
    # Chosen conventional order :
    # from most global (e.g. continent) to more informative (e.g. node)
    select(generator_name, continent, node, plexos_fuel_group, plexos_fuel_type, antares_cluster_type)
  
  return(generators_tbl)
}

# example <- addGeneralFuelInfo(example)
# print(example)

# Function to get just the year
# Should be in utils tbh
extract_date_from_excel_integer <- function(excel_int) {
  format(as.Date(excel_int, origin = "1899-12-30"), "%Y-%m-%d")
}
# # Excel stores dates as the number of days since 1900-01-01 (or 1899-12-30 if you're taking Excel's leap year bug into account
# extract_year_from_excel_integer <- function(excel_int) {
#   as.numeric(format(as.Date(excel_int, origin = "1899-12-30"), "%Y"))
# }

extract_year_from_date <- function(ymd) {
  as.numeric(format(as.Date(ymd, format = "%Y-%m-%d"), "%Y"))
}

getBaseGeneratorData <- function(generators_tbl) {
  properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Generators") %>%
    filter(property %in% c("Max Capacity", "Units", "Commission Date")) %>%
    select(child_object, property, value)
  
  inactive_in_2015 <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(memo == "With the exception of JPN_Nuc_Sendai13837 no active nuclear generators in Japan by 2015 due to Fukushima accident. https://en.wikipedia.org/wiki/Nuclear_power_in_Japan") %>%
    pull(child_object) %>%
    unique() %>%
    tolower()
  
  # print(inactive_in_2015)
  
  properties_tbl <- properties_tbl %>%
    filter(!(property == "Units" & value == 0)) %>%
    # No information is lost by removing these rows : either the generators are never active,
    # or they are, but the line is a duplicate to indicate different scenarios.
    pivot_wider(names_from = property, values_from = value) %>%
    mutate(generator_name = tolower(child_object),
           nb_units = Units,
           nominal_capacity = `Max Capacity`,
           commission_date = extract_date_from_excel_integer(`Commission Date`),
           active_in_2015 = !(extract_year_from_date(commission_date) > 2015 | generator_name %in% inactive_in_2015)
           ) %>%
    select(generator_name, nb_units, nominal_capacity, commission_date, active_in_2015)
  
  generators_tbl <- generators_tbl %>%
    left_join(properties_tbl, by = "generator_name") %>%
    select(generator_name, continent, node, nominal_capacity, nb_units, commission_date, active_in_2015, antares_cluster_type, plexos_fuel_type, plexos_fuel_group)
  
  return(generators_tbl)
}



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