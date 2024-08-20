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

initializeOutputFolder <- function(nodes) {
  output_dir = paste0("./output/results_", study_name, "-sim-", 
                      simulation_name
                      )
  msg = "[OUTPUT] - Initializing output folder..."
  logFull(msg)
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
    
    prod_stack_dir <- file.path(continent_dir, "productionStack")
      if (!dir.exists(prod_stack_dir)) {
        dir.create(prod_stack_dir)
      }
    
    prod_mono_dir <- file.path(continent_dir, "productionMonotone")
    # peut-être en faire des variables globales / paramètres ?
    # doublement utile pour la simplification de cette fonction, et des autres
    if (!dir.exists(prod_mono_dir)) {
      dir.create(prod_mono_dir)
    }
  }
  return(output_dir)
}

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
                           "Other3_injection", "Other3_withdrawal", "Other3_level") # Rappel : CAE
# Pourrait être une variable globale vu comment elle pop souvent tbh

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
output_dir <- initializeOutputFolder(NODES)
saveCountryProductionStacks(NODES,
                            output_dir#,
                            #"productionStackWithBatteryContributions",
                            #"daily"
                            )
saveCountryProductionMonotones(NODES,
                               output_dir,
                               "hourly"#,
                               #"hourly"
                               )
