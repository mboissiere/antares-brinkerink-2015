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

# Créer le graphique empilé avec la courbe de la consommation totale
ggplot(fra_tbl_long, aes(x = reorder(time, -LOAD))) +
  # Graphique empilé
  geom_bar(aes(y = production_mwh, fill = energy_source), stat = "identity") +
  # Ajouter la courbe de consommation totale
  geom_line(aes(y = LOAD, group = 1), color = "black", size = 1) +
  scale_fill_manual(values = c("NUCLEAR" = "yellow", "WIND" = "turquoise", "SOLAR" = "orange",  "GEOTHERMAL" = "springgreen", "HYDRO" = "blue",
                               "BIO AND WASTE" = "darkgreen", "GAS" = "red", "COAL" = "darkred", "OIL" = "darkslategray", "OTHER" = "lavender",
                               "PSP STOR" = "darkblue", "CHEMICAL STOR" = "goldenrod", "THERMAL STOR" = "burlywood", "HYDROGEN STOR" = "darkmagenta", "COMPRESSED AIR STOR" = "salmon",
                               "IMPORTS" = "grey")) +
  labs(x = "Consommation (triée décroissante)", y = "Consommation", fill = "Source d'énergie") +
  theme_minimal() # +
  # theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())  # Pour cacher les labels des abscisses si besoin


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