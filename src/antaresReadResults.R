# Chargement des packages nécessaires
# library(antaresRead)
library(antaresProcessing)
library(antaresViz)

source("parameters.R")
source(".\\src\\logging.R")

# Ouais faut vraiment rendre ça plus propre
# (cf readResultsComments.R)


if (!CREATE_STUDY) {
  study_name = IMPORT_STUDY_NAME
  study_path = file.path("input", "antares_presets", study_name,
                         fsep = .Platform$file.sep)
  msg = paste("[MAIN] - Reading simulations of pre-existing", study_name, "study...")
  logMain(msg)
}
if (!LAUNCH_SIMULATION) {
  simulation_name = IMPORT_SIMULATION_NAME
} else {
  simulation_name = -1
}
setSimulationPath(study_path, simulation_name)

if (simulation_name == -1) {
  msg = "[MAIN] - Opening latest simulation..."
  logMain(msg)
  } else {
    msg = paste("[MAIN] - Opening", simulation_name, "simulation...")
    logMain(msg)
  }

setRam(16)

start_date <- "2015-01-01"
end_date <- "2015-12-31"

source(".\\src\\antaresReadResults_support\\productionStacksPresets.R")
source(".\\src\\data\\addNodes.R")

################################################################################

initializeOutputFolder <- function(
    #nodes
    ) {
  # output_dir = file.path("output", "test")
  output_dir = paste0("./output/results_", study_name, "-sim-",
                      simulation_name
                      )
  # msg = "[OUTPUT] - Initializing output folder..."
  # logFull(msg)
  if (!dir.exists(output_dir)) {
  dir.create(output_dir)
  }
 
  continents_dir <- file.path(output_dir, "continent_graphs")
  if (!dir.exists(continents_dir)) {
    dir.create(continents_dir)
  }

  countries_dir <- file.path(output_dir, "country_graphs")
  if (!dir.exists(countries_dir)) {
    dir.create(countries_dir)
  }
  
  nodes_tbl <- getNodesTable(nodes)
  continents <- nodes_tbl$continent %>% unique()
  for (continent in continents) {
    continent_dir <- file.path(countries_dir, tolower(continent))
    if (!dir.exists(continent_dir)) {
      dir.create(continent_dir)
    }
    
    # Possible piste d'amélioration :
    # faire une arborisation [1] world avec dedans des png des graphes par continent à la deane
    # puis [6] continents avec dossiers africa, asia etc et ce que j'ai l'habitude de faire 
    # (en fait des graphes de chaque pays)
    # ET ! dans chaque pays en fait il y a des régions finalement.
    # dans les graphes pays, prendre en fait les districts as-chn na-usa etc au lieu des régions
    # mais au sein de chaque continent en fait faire des dossiers genre
    # [34] as-chn regions, [5] as-ind regions, [24] na-usa regions, etc
    # et hop architecture monde -> continent -> pays -> région au fur et à mesure qu'on clique
    # (avec à chaque fois des dossiers prodStack, prodMonotone, etc)
    # (j'ai tellement envie de faire stack des exports genre dans quels pays ça part etc...)
    
  }
  return(output_dir)
}

initializeOutputFolder_v2 <- function(
    ) {
  output_dir = paste0("./output/results_", study_name, "-sim-",
                      simulation_name
                      )
  if (!dir.exists(output_dir)) {
  dir.create(output_dir)
  }
  
  global_dir <- file.path(output_dir, "1 - Global-level graphs")
  if (!dir.exists(global_dir)) {
    dir.create(global_dir)
  }
  
  continental_dir <- file.path(output_dir, "2 - Continental-level graphs")
  if (!dir.exists(continental_dir)) {
    dir.create(continental_dir)
  }
  
  national_dir <- file.path(output_dir, "3 - National-level graphs")
  if (!dir.exists(national_dir)) {
    dir.create(national_dir)
  }
  
  regional_dir <- file.path(output_dir, "4 - Regional-level graphs")
  if (!dir.exists(regional_dir)) {
    dir.create(regional_dir)
  }
  
  geo_scales_dirs = c(global_dir, continental_dir, national_dir, regional_dir)
  
  rawdata_dir <- file.path(output_dir, "Raw data")
  if (!dir.exists(rawdata_dir)) {
    dir.create(rawdata_dir)
  }
  # backupStudy(
  #   backupfile,
  #   what = "study",
  #   opts = antaresRead::simOptions(),
  #   extension = ".zip"
  # )
  
  # Copy of the output files of an Antares study.
  # 
  # Usage
  # copyOutput(opts, extname, mcYears = "all")
  
  for (folder in geo_scales_dirs) {
    prod_stack_dir <- file.path(folder, "Production stacks")
    # ça ça pourrait aussi ce mettre en liste genre, la liste des noms possibles
    # de trucs qu'on peut faire
    if (!dir.exists(prod_stack_dir)) {
      dir.create(prod_stack_dir)
    }
    
    load_mono_dir <- file.path(folder, "Load monotones")
    if (!dir.exists(load_mono_dir)) {
      dir.create(load_mono_dir)
    }
  } 
  return(output_dir)
}

# initializeOutputFolder()

# et après faut ptet du preprocessing de AntaresRead genre...
# on prend areas et district, on prend des tolower du geography_tbl et on fait un
# countries, un continents, un regions qui vient remplacer le prod_data

# ou bien un objet antaresread nouveau à chaque fois genre
# for country in geography
# if .isna region aller mettre le nom dans areas ou dans districts
# if country = node peut-être
# fin jsp parcourir row par row


################################################################################

HEIGHT = 2*1080
WIDTH = 2*HEIGHT
TIMESTEPS = c("hourly", "daily", "weekly", "monthly", "annual")

variables_of_interest <- c("SOLAR", "WIND",
                           "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "OIL",
                           "LOAD",
                           "H. STOR",
                           "BALANCE",
                           "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                           "UNSP. ENRG",
                           "PSP_closed_injection", "PSP_closed_withdrawal", "PSP_closed_level",
                           "Battery_injection", "Battery_withdrawal", "Battery_level",
                           "Other1_injection", "Other1_withdrawal", "Other1_level", # Rappel : thermal
                           "Other2_injection", "Other2_withdrawal", "Other2_level", # Rappel : hydrogen
                           "Other3_injection", "Other3_withdrawal", "Other3_level", # Rappel : CAE
                           
                           "CO2 EMIS."
                           # Tout ce qu'on a dans les histos c'est CO2 Emission et Generation 
                           # (pure donc, sans batteries jpense) totale en TWh
                           # c'est donc amplement fine ce qu'on importe ici
                           
                           # (mais j'aimerais grave importer des trucs de links !!)
                           
                           )
# Pourrait être une variable globale vu comment elle pop souvent tbh

# Variables typiques quand on importe des liens :
# "FLOW LIN.", "UCAP LIN." et des trucs de congestion on dirait

##############################

getAntaresData <- function(nodes, timestep) {
  areas = getAreas(nodes)
  antares_data <- readAntares(areas = areas,
                              mcYears = NULL,#"all", # let's see if maybe it's better at averages
                              select = variables_of_interest,
                              timeStep = timestep
  )
  return(antares_data)
  } 
# may seem redundant but saves time on the other variables if known
# and we might switch often from hourly, to daily, etc


##########

getGlobalData <- function(timestep) {
  global_data <- readAntares(areas = NULL,
                              districts = "world", # ça pourrait être une variable etc etc
                              mcYears = NULL,
                              select = variables_of_interest,
                              timeStep = timestep
  )
  # à tester
  # print(antares_data)
  return(global_data)
} 

geography_tbl <- readRDS(".\\src\\objects\\geography_tbl.rds")
# print(geography_tbl)

# geography_lower_tbl <- geography_tbl %>%
#   mutate(continent = tolower(continent),
#          country = tolower(country),
#          region = tolower(region),
#          node = tolower(node)
#          )
tolowerVec <- Vectorize(tolower)
geography_lower_tbl <- as_tibble(tolowerVec(geography_tbl))
# print(geography_lower_tbl, n = 258)

continents <- geography_lower_tbl$continent %>% unique() #ça peut pas être global ça ?
# print(continents)

getContinentalData <- function(timestep) {
  timestep = "daily"
  # districts = getDistricts(NULL)
  # continental_districts <- intersect(districts, continents)
  # mdr c'est débile att
  
  continental_districts = getDistricts(select = continents,
                                       regexpSelect = FALSE)
  # antares fait déjà un taf d'intersection ! même s'il y a des districts en trop
  # dans ce qu'on passe en argument de getDistricts
  # print(districts)
  continental_data <- readAntares(areas = NULL, # ça existe ça ? j'y crois bof
                              districts = continental_districts,
                              mcYears = NULL,#"all", # let's see if maybe it's better at averages
                              select = variables_of_interest,
                              timeStep = timestep
                              )
  # print(continental_data)
  return(continental_data)
} 
# Attention à être clair : un graphe continental, c'est un graphe où les données sont
# à échelle des continents.
# un plot stack avec SEULEMENT l'europe dessus, c'est un graphe continental.
# un histogramme qui compare PLUSIEURS continents entre eux, c'est AUSSI un graphe continental.


countries <- geography_lower_tbl$country %>% unique() #ça peut pas être global ça ?
# print(countries)
# > getAreas(countries)
# [1] "sa-arg"    "sa-bol"    "sa-bra-cn" "sa-bra-cw" "sa-bra-j1" "sa-bra-j2" "sa-bra-j3" "sa-bra-ne"
# [9] "sa-bra-nw" "sa-bra-se" "sa-bra-so" "sa-bra-we" "sa-chl"    "sa-col"    "sa-ecu"    "sa-guf"   
# [17] "sa-guy"    "sa-per"    "sa-pry"    "sa-ury"    "sa-ven" 
# chelou qu'il y ait des régions là-dedans
# ok c bon ça la lisait comme des regexp

#ignore.case	
#Should the case be ignored when evaluating the regular expressions ?
# depuis le début...

getNationalData <- function(timestep) {
  timestep = "daily"
  country_areas = getAreas(select = countries,
                           regexpSelect = FALSE)
  country_districts = getDistricts(select = countries,
                                   regexpSelect = FALSE)
  
  # print(continental_districts)
  antares_data <- readAntares(areas = country_areas,
                               districts = country_districts,
                               mcYears = NULL,# again, if it's averages we want, which should be a parameter imo
                               select = variables_of_interest,
                               timeStep = timestep
  )

  areas_data <- antares_data$areas
  districts_data <- antares_data$districts
  
  colnames(districts_data)[colnames(districts_data) == "district"] <- "area"
  # if (!identical(colnames(areas_data), colnames(districts_data))) {
  #   stop("Columns in 'areas' and 'districts' are not identical.")
  # }
  combined_data <- rbind(areas_data, districts_data)
  # print(combined_data)
  # Possible qu'il soit reconnu comme un "simple datatable" et non un antaresDataTable
  # de type areas. Si c'est le cas, il y a des fonctions pour interpréter un df en objet antares
  national_data <- as.antaresDataTable(combined_data, synthesis = TRUE, timeStep = timestep, type = "areas")
  # synthesis = TRUE et le fait que mcYears soit NULL / une moyenne, c'est la même je crois
  # print(national_data)
  return(national_data)
}

regions_tbl <- geography_lower_tbl %>%
  filter(!is.na(region))

# print(regions_tbl)

regions <- regions_tbl$region %>% unique() #ça peut pas être global ça ?
# print(regions)

getRegionalData <- function(timestep) {
  timestep = "daily"
  regional_areas = getAreas(select = regions,
                            regexpSelect = FALSE)
  
  regional_data <- readAntares(areas = regional_areas,
                              districts = NULL,
                              mcYears = NULL,# again, if it's averages we want, which should be a parameter imo
                              select = variables_of_interest,
                              timeStep = timestep
  )

  # print(regional_data)
  return(regional_data)
} 

################################################################################

saveCountryProductionStacks <- function(nodes, 
                                        output_folder,
                                        stack_palette = "productionStackWithBatteryContributions",
                                        timestep = "daily"
                                        ) {
  msg = "[OUTPUT] - Preparing to save production stacks to output folder..."
  logFull(msg)
  areas = getAreas(nodes)
  variables_of_interest <- c("SOLAR", "WIND",
                             "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "OIL",
                             "LOAD",
                             "H. STOR",
                             "BALANCE",
                             "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                             "UNSP. ENRG",
                             "PSP_closed_injection", "PSP_closed_withdrawal", "PSP_closed_level",
                             "Battery_injection", "Battery_withdrawal", "Battery_level",
                             "Other1_injection", "Other1_withdrawal", "Other1_level", # Rappel : thermal
                             "Other2_injection", "Other2_withdrawal", "Other2_level", # Rappel : hydrogen
                             "Other3_injection", "Other3_withdrawal", "Other3_level" # Rappel : CAE
                             )
  prod_data <- getAntaresData(nodes, timestep)
  
  country_graphs_dir = file.path(output_folder, "country_graphs")
  nodes_tbl <- getNodesTable(nodes)
  continents <- nodes_tbl$continent %>% unique()
  for (cnt in continents) {
    
    nodes_in_continent_tbl <- nodes_tbl %>% filter(continent == cnt)
    nodes_in_continent <- tolower(nodes_in_continent_tbl$node)
    
    prod_stack_dir <- file.path(country_graphs_dir, tolower(cnt), "productionStack")
    # maybe could be part of the global variables / config
    # but the ones that we don't touch too much unlike parameters
    
    unit = "GWh"
    for (country in nodes_in_continent) {
      if (stack_palette == "dynamic") {
        null_variables = list()
        for (variable in variables_of_interest) {
          var_in_area_df <- readAntares(areas = country,
                                        mcYears = "all",
                                        timeStep = timestep,
                                        select = variable
          )[[variable]]
          df_is_null <- all(var_in_area_df == 0)
          if (df_is_null) {
            null_variables <- c(null_variables, variable)
          }
        }
        createFilteredStack(stack_palette, null_variables)
      }
      
      stack_plot <- prodStack(
        x = prod_data,
        stack = stack_palette,
        areas = country,
        dateRange = c(start_date, end_date),
        timeStep = timestep,
        main = paste(timestep, "production stack for", country, "in 2015", unit),
        unit = unit,
        interactive = FALSE
      )
      msg = paste("[OUTPUT] - Saving", timestep, "production stack for", country, "node...")
      logFull(msg)
      png_path = file.path(prod_stack_dir, paste0(country, "_", timestep, ".png"))
      savePlotAsPng(stack_plot, file = png_path,
                    width = WIDTH, #3*WIDTH,
                    height = HEIGHT # 2*HEIGHT)
                    )
      msg = paste("[OUTPUT] - The", timestep, "production stack for", country, "has been saved!")
      logFull(msg)
    }
  }
}

################################################################################
# NB : this one doesn't work so far

saveUnsuppliedAndSpillage <- function(nodes,
                                      output_folder,
                                      timestep
                                      ) {
  areas = getAreas(nodes)
  energy_data <- readAntares(areas = areas,
                           mcYears = "all",
                           select = c("UNSP. ENRG", "SPIL. ENRG"),
                           timeStep = timestep
  )
  msg = "[OUTPUT] - Preparing to save production monotones to output folder..."
  logFull(msg)
  country_graphs_dir = file.path(output_folder, "country_graphs")
  nodes_tbl <- getNodesTable(nodes)
  continents <- nodes_tbl$continent %>% unique()
  for (cnt in continents) {
    nodes_in_continent_tbl <- nodes_tbl %>% filter(continent == cnt)
    nodes_in_continent <- tolower(nodes_in_continent_tbl$node)
    unsp_spil_dir <- file.path(country_graphs_dir, tolower(cnt), "unsuppliedAndSpillage")
    if (!dir.exists(unsp_spil_dir)) {
      dir.create(unsp_spil_dir)
    }
    unit = "MWh"
    for (country in nodes_in_continent) {
      ts_plot <- plot(
        x = energy_data,
        type = "ts",
        variable =  -`UNSP. ENRG`,
        colors = "red",
        elements = country,
        dateRange = c(start_date, end_date),
        main = paste(timestep, "unsupplied energy for", country, "in 2015 (MWh)"),
        interactive = FALSE
        )
      msg = paste("[OUTPUT] - Saving", timestep, "unsupplied/spilled energy for", country, "node...")
      logFull(msg)
      png_path = file.path(unsp_spil_dir, paste0(country, "_", timestep, ".png"))
      savePlotAsPng(ts_plot, file = png_path,
                    width = WIDTH,
                    height = HEIGHT)
      msg = paste("[OUTPUT] - The", timestep, "unsupplied/spilled energy for", country, "has been saved!")
      logFull(msg)
    }
  }
}

################################################################################

resolution_dpi = 300
height_pixels = 2*1080
width_pixels = 2*height_pixels

sources <- c("NUCLEAR", "WIND", "SOLAR", "MISC. DTG", "H. STOR",
                    "MIX. FUEL", "GAS", "COAL", "OIL", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                    "PSP_closed_withdrawal", "Battery_withdrawal", "Other1_withdrawal",
                    "Other2_withdrawal", "Other3_withdrawal",
                    "BALANCE", "UNSP. ENRG")

sources_new <- c("NUCLEAR", "WIND", "SOLAR", "GEOTHERMAL", "HYDRO",
                 "BIO AND WASTE", "GAS", "COAL", "OIL", "OTHER",
                 "PSP STOR", "CHEMICAL STOR", "THERMAL STOR", "HYDROGEN STOR", "COMPRESSED AIR STOR", # à comprendre comme une injection
                 "IMPORTS", "UNSUPPLIED")

library(dplyr)
library(tidyr)
library(ggplot2)

saveCountryProductionMonotones <- function(nodes,
                                           output_dir,
                                           timestep = "hourly") {
  hourly_prod_data <- getAntaresData(nodes, timestep)
  hourly_prod_tbl <- as_tibble(hourly_prod_data)
  
  areas = getAreas(nodes)
  
  nodes_tbl <- getNodesTable(nodes)
  continents <- nodes_tbl$continent %>% unique()
  for (cnt in continents) {
    nodes_in_continent_tbl <- nodes_tbl %>% filter(continent == cnt)
    nodes_in_continent <- tolower(nodes_in_continent_tbl$node)
    continent_dir <- file.path(output_dir, "country_graphs", cnt)
    for (country in nodes_in_continent) {
      area_tbl <- hourly_prod_tbl %>%
        filter(area == country)
      
      area_tbl_sorted <- area_tbl[order(-area_tbl$LOAD), ] %>%
        select(timeId, time, LOAD, sources)
      
      area_tbl_succint <- area_tbl_sorted %>%
        mutate(OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
               IMPORTS = -BALANCE) %>%
        select(-`MISC. DTG 2`, -`MISC. DTG 3`, -`MISC. DTG 4`) %>%
        rename(
          GEOTHERMAL = `MISC. DTG`,
          HYDRO = `H. STOR`,
          `BIO AND WASTE` = `MIX. FUEL`,
          `PSP STOR` = `PSP_closed_withdrawal`,
          `CHEMICAL STOR` = `Battery_withdrawal`,
          `THERMAL STOR` = `Other1_withdrawal`,
          `HYDROGEN STOR` = `Other2_withdrawal`,
          `COMPRESSED AIR STOR` = `Other3_withdrawal`,
          UNSUPPLIED = `UNSP. ENRG`
        )
      
      area_tbl_long <- area_tbl_succint %>%
        select(time, LOAD, sources_new) %>%
        pivot_longer(cols = sources_new, names_to = "energy_source", values_to = "production_mwh")
      
      area_tbl_long$energy_source <- factor(area_tbl_long$energy_source, levels = rev(sources_new))
      
      # La production est mille fois trop grande, c'est peut-être un problème des mc years...
      
      
      p <- ggplot(area_tbl_long, aes(x = reorder(time, -LOAD))) +
        geom_bar(aes(y = production_mwh, fill = energy_source), stat = "identity") +
        geom_line(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +
        scale_fill_manual(values = c("NUCLEAR" = "yellow", "WIND" = "turquoise", "SOLAR" = "orange",  "GEOTHERMAL" = "springgreen", "HYDRO" = "blue",
                                     "BIO AND WASTE" = "darkgreen", "GAS" = "red", "COAL" = "darkred", "OIL" = "darkslategray", "OTHER" = "lavender",
                                     "PSP STOR" = "darkblue", "CHEMICAL STOR" = "goldenrod", "THERMAL STOR" = "burlywood", "HYDROGEN STOR" = "darkmagenta", "COMPRESSED AIR STOR" = "salmon",
                                     "IMPORTS" = "grey", "UNSUPPLIED" = "grey25")) +
        labs(x = "Load (in reverse order)", y = "Production (MWh)", fill = paste(country, "energy mix")) +
        theme_minimal() +
        theme(
          legend.position = "right",
          legend.text = element_text(size = 8), # Legend text size
          legend.title = element_text(size = 10), # Legend title size
          legend.key.size = unit(0.4, "cm"), # Size of the legend keys
          legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
          legend.margin = margin(0, 0, 0, 0), # Margin around the legend
          legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box
          
          axis.title.x = element_text(size = 10), # X-axis title size
          axis.title.y = element_text(size = 10), # Y-axis title size
          
          axis.text.x = element_text(size = 8), # X-axis labels size
          axis.text.y = element_text(size = 8)  # Y-axis labels size
        )
      
      msg = paste("[OUTPUT] - Saving", timestep, "production monotone for", country, "node...")
      logFull(msg)
      plot_path <- file.path(continent_dir, "productionMonotone", paste0(country,"_monotone.png"))
      ggsave(filename = plot_path, plot = p, 
             width = width_pixels/resolution_dpi, height = height_pixels/resolution_dpi,
             dpi = resolution_dpi)
      msg = paste("[OUTPUT] - The", timestep, "production monotone for", country, "has been saved!")
      logFull(msg)
    }
  }
  # faudrait ajouter la défaillance aussi...
}

# Next step : continental graphs
# Setting districts via antaresEditObject and antaresRead sounds like
# the easiest, honestly
# not only districts for disaggregated countries (USA, China)
# but also for continents

# Voir en tout cas si y a pas moyen d'avoir des monotones sur AntaresViz.
# le passage par ggplot2 est quand même assez long en temps de calcul, rien à voir
# par rapport aux stacks de production faits sur AntaresViz...
# (10s pour un stack vs 3 min pour une monotone (qui s'est mm pas sauvegardée))
# update : plutôt 45s en vrai, ça va un peu mieux. et la sauvegarde c'était une question de répertoire.
# et ça peut aussi faciliter le travail si les districts sont implémentées

################################################################################

#nodes = all_deane_nodes_lst
output_dir <- initializeOutputFolder()
saveCountryProductionStacks(NODES,
                            output_dir,
                            "productionStackWithBatteryContributions",
                            "hourly"
                            )
# pareil est-ce que nodes c'est important ? ne veut-on pas juste tout produire ?
# à voir
saveCountryProductionMonotones(NODES,
                               output_dir,
                               "hourly"#,
                               #"hourly"
                               )



#####################################################

# initializeOutputFolder_v2 <- function(nodes) {
#   output_dir = "./output/test"# just for testing
#                       
#   # output_dir = paste0("./output/results_", study_name, "-sim-", 
#   #                     simulation_name
#   # )
#   msg = "[OUTPUT] - Initializing output folder..."
#   print(msg)
#   # logFull(msg)
#   if (!dir.exists(output_dir)) {
#     dir.create(output_dir)
#   }
#   
#   graphs_dir <- file.path(output_dir, "graphs")
#   if (!dir.exists(graphs_dir)) {
#     dir.create(graphs_dir)
#   }
#   
#   # Est-ce que c'était vraiment très malin de faire une arborescence alors que genre...
#   # on pourrait vouloir tous les graphes d'un coup, non ?
#   # peut-etre que continent_graphs + country_graphs en parallèle c'était bien depuis le début
#   # juste graphs -> dossier continent level, dossier country level, + graphes mondiaux métriques deanes
#   # dans dossier continent level, des stacks et des monotones européens etc
#   # dans dossier country level
#   # en fait juste du unordered quoi merde c'est ptet ça le mieux
#   # du continent_graphs, country_graphs, region_graphs
#   # dedans y a productionStacks et productionMonotones et C'EST TOUT et on mélange les continents
#   # et au moins on a 2 niveaux de hiérarchie et pas genre 7
#   # et au moins on peut les comparer en fait (libre à l'utilisateur de réorganiser après s'il veut)
#   # (ne serait-ce qu'en triant par ordre alphabétique avec le af-... y aura déjà une séparation)
#   
#   # Note that graphs aren't the only thing.
#   # It's good practice for open-source to also return raw data, so you can work on that
#   # eg Antares results/output in txt form, or in rds form (txt seems better)
# 
#   # world_dir <- file.path(graphs_dir, "[1] - World")
#   # if (!dir.exists(world_dir)) {
#   #   dir.create(world_dir)
#   # }
# 
#   # Le plus simple est ptet de faire un répertoire genre regions dans countries etc
#   geography_tbl <- readRDS(".\\src\\objects\\geography_tbl.rds")
# 
#   sim_geography_tbl <- geography_tbl %>%
#     filter(node %in% nodes)
#   
#   continents <- sim_geography_tbl$continent %>% unique()
#   nb_continents <- length(continents)
#   
#   # Step 1: Create "Continents" directory inside "World"
#   # en fait y a un monde où ça c'est mon "main" et jsuis juste obligé de construire
#   # les getProdStack machin etc dedans parce que sinon c'est infernal de re-choper les path après
#   # ou alors repartir de geography_tbl (ouais mais j'ai nommé genre [.] continents, pas malin..)
#   continents_dir <- file.path(graphs_dir, paste0("[", nb_continents,"] Continents"))
#   if (!dir.exists(continents_dir)) {
#     dir.create(continents_dir)
#   }
#   
#   for (cont in continents) {
#     
#     continent_dir <- file.path(continents_dir, cont)
#     if (!dir.exists(continent_dir)) {
#       dir.create(continent_dir)
#     }
#     
#     sim_continent_tbl <- sim_geography_tbl %>%
#       filter(continent == cont)
#     
#     countries <- sim_continent_tbl$country %>% unique()
#     nb_countries <- length(countries)
#     
#     countries_dir <- file.path(continent_dir, paste0("[", nb_countries,"] Countries"))
#     if (!dir.exists(countries_dir)) {
#       dir.create(countries_dir)
#     }
#     
#     for (ctry in countries) {
#       
#       country_dir <- file.path(countries_dir, ctry)
#       if (!dir.exists(country_dir)) {
#         dir.create(country_dir)
#       }
#       
#       sim_country_tbl <- sim_continent_tbl %>%
#         filter(country == ctry)
#       
#       sim_regions_tbl <- sim_country_tbl %>%
#         filter(!is.na(region))
#       
#       regions <- sim_regions_tbl$region %>%
#         unique()
#       
#       nb_regions <- length(regions)
#       #if (nb_regions > 0) { # pas sûr que ce soit nécessaire (for k in vide) mais ce serait propre
#       for (regn in regions) { # ça fait automatiquement rien si regions est vide
#         regions_dir <- file.path(country_dir, paste0("[", nb_regions,"] Regions"))
#         if (!dir.exists(regions_dir)) {
#           dir.create(regions_dir)
#         }
#         }
#       #}
#       
#     }
#   }
#   
#   # for (row in 1:nrow(geography_tbl)) {
#   #   node_row = geography_tbl[row]
#   # }
#   
#   # # Step 2: Loop through each continent and create folders
#   # sim_geography_tbl %>%
#   #   group_by(continent) %>%
#   #   do({
#   #     continent_name <- unique(.$continent)
#   #     
#   #     # Create continent folder
#   #     continent_folder <- file.path(continents_dir, continent_name)
#   #     if (!dir.exists(continent_folder)) {
#   #       dir.create(continent_folder)
#   #     }
#   #     
#   #     # Create "Countries" directory within continent folder
#   #     countries_dir <- file.path(continent_folder, "[y] Countries")
#   #     if (!dir.exists(countries_dir)) {
#   #       dir.create(countries_dir)
#   #     }
#   #     
#   #     # Step 3: Loop through each country and create folders
#   #     .$country %>%
#   #       unique() %>%
#   #       lapply(function(country_name) {
#   #         country_folder <- file.path(countries_dir, country_name)
#   #         
#   #         # Create country folder
#   #         if (!dir.exists(country_folder)) {
#   #           dir.create(country_folder)
#   #         }
#   #         
#   #         # Step 4: Create region folders for countries that have regions
#   #         country_data <- filter(sim_geography_tbl, country == country_name)
#   #         if (any(!is.na(country_data$region))) {
#   #           # Loop through regions
#   #           country_data %>%
#   #             filter(!is.na(region)) %>%
#   #             .$region %>%
#   #             unique() %>%
#   #             lapply(function(region_name) {
#   #               region_folder <- file.path(country_folder, paste("[z]", region_name, sep = " "))
#   #               
#   #               # Create region folder
#   #               if (!dir.exists(region_folder)) {
#   #                 dir.create(region_folder)
#   #               }
#   #               
#   #               # You can create graphs here for each region and save them in this folder
#   #               # Example: save graph for the region
#   #               # plot(some_graph)
#   #               # ggsave(filename = file.path(region_folder, "graph.png"))
#   #             })
#   #         }
#   #       })
#   #   })
#     
#     # Possible piste d'amélioration :
#     # faire une arborisation [1] world avec dedans des png des graphes par continent à la deane
#     # puis [6] continents avec dossiers africa, asia etc et ce que j'ai l'habitude de faire 
#     # (en fait des graphes de chaque pays)
#     # ET ! dans chaque pays en fait il y a des régions finalement.
#     # dans les graphes pays, prendre en fait les districts as-chn na-usa etc au lieu des régions
#     # mais au sein de chaque continent en fait faire des dossiers genre
#     # [34] as-chn regions, [5] as-ind regions, [24] na-usa regions, etc
#     # et hop architecture monde -> continent -> pays -> région au fur et à mesure qu'on clique
#     # (avec à chaque fois des dossiers prodStack, prodMonotone, etc)
#     # (j'ai tellement envie de faire stack des exports genre dans quels pays ça part etc...)
#     
#     # prod_stack_dir <- file.path(continent_dir, "productionStack")
#     # if (!dir.exists(prod_stack_dir)) {
#     #   dir.create(prod_stack_dir)
#     # }
#     # 
#     # prod_mono_dir <- file.path(continent_dir, "productionMonotone")
#     # # peut-être en faire des variables globales / paramètres ?
#     # # doublement utile pour la simplification de cette fonction, et des autres
#     # if (!dir.exists(prod_mono_dir)) {
#     #   dir.create(prod_mono_dir)
#     # }
#   return(output_dir)
# }
# 
# initializeOutputFolder_v2(all_deane_nodes_lst)