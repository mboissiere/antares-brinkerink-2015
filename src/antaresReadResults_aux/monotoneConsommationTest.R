library(antaresRead)
library(antaresProcessing)
library(antaresViz)

study_name = "Deane_Beta_EU__2024_08_08_15_48_17"
simulation = -1
study_path = file.path("input", "antares_presets", study_name,
                       fsep = .Platform$file.sep)

setSimulationPath(study_path, simulation)

timestep = "hourly"

# areas = getAreas(nodes) # les areas c lowercase, eu-aut eu-fra etc
# variables_of_interest <- c("SOLAR", "WIND", # Ici l'ordre compte pas jcrois,
#                            # c'est dans setStackAlias machin qu'on le détermine
#                            "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "OIL",
#                            "LOAD",
#                            "H. STOR",
#                            "BALANCE",
#                            "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
#                            "UNSP. ENRG",
#                            "PSP_closed_injection", "PSP_closed_withdrawal", "PSP_closed_level",
#                            "Battery_injection", "Battery_withdrawal", "Battery_level",
#                            "Other1_injection", "Other1_withdrawal", "Other1_level", # Rappel : thermal
#                            "Other2_injection", "Other2_withdrawal", "Other2_level", # Rappel : hydrogen
#                            "Other3_injection", "Other3_withdrawal", "Other3_level" # Rappel : CAE
# )

# Essayons d'avoir une monotone de conso de juste la France pour l'instant

fra_data <- readAntares(areas = "eu-fra",
                         #mcYears = "all",
                         #select = variables_of_interest,
                         timeStep = timestep
)

print(fra_data)

library(dplyr)
library(tidyr)

fra_tbl <- as_tibble(fra_data)
print(fra_tbl)
print(colnames(fra_tbl))

# Trier les données par consommation décroissante
fra_tbl_sorted <- fra_tbl[order(-fra_tbl$LOAD), ]

sources <- c("NUCLEAR", "WIND", "SOLAR", "MISC. DTG", "H. STOR",
             "MIX. FUEL", "GAS", "COAL", "OIL", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
             "PSP_closed_withdrawal", "Battery_withdrawal", "Other1_withdrawal", # à comprendre comme une injection
             "Other2_withdrawal", "Other3_withdrawal", "Other4_withdrawal",
             "BALANCE")

fra_tbl_sorted_sources <- fra_tbl_sorted %>%
  select(timeId, time, LOAD, sources)

fra_tbl_sorted_sources_succint <- fra_tbl_sorted_sources %>%
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
    `COMPRESSED AIR STOR` = `Other3_withdrawal`
  )

sources_new <- c("NUCLEAR", "WIND", "SOLAR", "GEOTHERMAL", "HYDRO",
             "BIO AND WASTE", "GAS", "COAL", "OIL", "OTHER",
             "PSP STOR", "CHEMICAL STOR", "THERMAL STOR", "HYDROGEN STOR", "COMPRESSED AIR STOR", # à comprendre comme une injection
             "IMPORTS")

print(fra_tbl_sorted_sources_succint)

library(ggplot2)

# Convertir le tableau pour un format long, nécessaire pour ggplot
fra_tbl_long <- fra_tbl_sorted_sources_succint %>%
  select(time, LOAD, sources_new) %>%
  pivot_longer(cols = sources_new, names_to = "energy_source", values_to = "production_mwh")

print(fra_tbl_long, n = 50)

# # Créer le graphique empilé
# ggplot(fra_tbl_long, aes(x = reorder(time, -LOAD), y = production_mwh, fill = energy_source)) +
#   geom_bar(stat = "identity") +
#   labs(x = "Consommation (triée décroissante)", y = "Consommation par source", fill = "Source d'énergie") +
#   theme_minimal()

# Cette ligne est censée réordonner selon l'ordre choisi
# (choisi dans l'écriture de la liste sources)
fra_tbl_long$energy_source <- factor(fra_tbl_long$energy_source, levels = rev(sources_new))
print(fra_tbl_long, n = 50)

# Créer le graphique empilé avec la courbe de la consommation totale
p <- ggplot(fra_tbl_long, aes(x = reorder(time, -LOAD))) +
  # Graphique empilé
  geom_bar(aes(y = production_mwh, fill = energy_source), stat = "identity") +
  # Ajouter la courbe de consommation totale
  geom_line(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +
  scale_fill_manual(values = c("NUCLEAR" = "yellow", "WIND" = "turquoise", "SOLAR" = "orange",  "GEOTHERMAL" = "springgreen", "HYDRO" = "blue",
                               "BIO AND WASTE" = "darkgreen", "GAS" = "red", "COAL" = "darkred", "OIL" = "darkslategray", "OTHER" = "lavender",
                               "PSP STOR" = "darkblue", "CHEMICAL STOR" = "goldenrod", "THERMAL STOR" = "burlywood", "HYDROGEN STOR" = "darkmagenta", "COMPRESSED AIR STOR" = "salmon",
                               "IMPORTS" = "grey")) +
  labs(x = "Load (in reverse order)", y = "Production", fill = "Energy source") +
  theme_minimal() +
  theme(
    # Legend adjustments
    legend.position = "right",
    legend.text = element_text(size = 8), # Legend text size
    legend.title = element_text(size = 10), # Legend title size
    legend.key.size = unit(0.4, "cm"), # Size of the legend keys
    legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
    legend.margin = margin(0, 0, 0, 0), # Margin around the legend
    legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box
    
    # Axis title adjustments
    axis.title.x = element_text(size = 10), # X-axis title size
    axis.title.y = element_text(size = 10), # Y-axis title size
    
    # Axis label adjustments
    axis.text.x = element_text(size = 8), # X-axis labels size
    axis.text.y = element_text(size = 8)  # Y-axis labels size
  ) 
  # theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())  # Pour cacher les labels des abscisses si besoin

# Example: Save the plot to the Desktop with a resolution of 300 DPI


# Error in `ggsave()`:
#   ! Dimensions exceed 50 inches (`height` and `width` are specified in inches not pixels).
# i If you're sure you want a plot that big, use `limitsize = FALSE`.
# Run `rlang::last_trace()` to see where the error occurred.
# 
# To create a 1920x1080 pixel image, you can calculate the required width and height in inches by dividing the pixel dimensions by the desired DPI.
# 
# For example, with a DPI of 300:
# 
# Width in inches = 1920 pixels / 300 DPI = 6.4 inches
# Height in inches = 1080 pixels / 300 DPI = 3.6 inches
resolution_dpi = 300
# width_pixels = 1920
height_pixels = 2*1080
# is this 4k ??
width_pixels = 2 * height_pixels # ptet mieux pour un graphe looong comme une année en horaire

node = "eu-fra"
chemin_sortie <- file.path("output", "graphes", paste0(node,"_monotone_",resolution_dpi,"dpi.png"))

ggsave(filename = chemin_sortie, plot = p, 
       width = width_pixels/resolution_dpi, height = height_pixels/resolution_dpi,
       dpi = resolution_dpi)

# 
# setProdStackAlias(
#   name = "monotoneConsommation",
#   variables = alist(
#     Nucleaire = NUCLEAR,
#     Eolien = WIND,
#     Solaire = SOLAR,
#     Geothermique = `MISC. DTG`,
#     `Hydro lacs` = `H. STOR`,
# 
#     `Bio et dechets` = `MIX. FUEL`,
#     Gaz = GAS,
#     Charbon = COAL,
#     Fioul = OIL,
#     Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
# 
#     `Contrib. STEP` = PSP_closed_withdrawal,
#     `Contrib. Batteries` = Battery_withdrawal,
#     `Contrib. Thermique` = Other1_withdrawal,
#     `Contrib. Hydrogene` = Other2_withdrawal,
#     `Contrib. Air comprime` = Other3_withdrawal,
#     
#     Imports = -BALANCE
#   ),
#   colors = c("yellow", "turquoise", "orange", "springgreen", "blue",
#              "darkgreen", "red", "darkred", "darkslategray", "lavender",
#              "darkblue", "goldenrod", "burlywood", "darkmagenta", "salmon",
#              "grey"
#   ),
#   lines = alist(
#     Consommation = LOAD
#     #Production =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`
#   ),
#   lineColors = c("black")#, "violetred")
# )