### Named lists (for ggplot2)

renamedProdStackWithBatteries_lst = c("GEOTHERMAL" = "springgreen", "OTHER" = "lavender", "NUCLEAR" = "yellow", "WIND" = "turquoise", "SOLAR" = "orange",  "HYDRO" = "blue",
                                      "BIO AND WASTE" = "darkgreen", "GAS" = "red", "COAL" = "darkred", "OIL" = "darkslategray",
                                      "PSP STOR" = "darkblue", "CHEMICAL STOR" = "goldenrod", "THERMAL STOR" = "burlywood", "HYDROGEN STOR" = "darkmagenta", "COMPRESSED AIR STOR" = "salmon",
                                      "IMPORTS" = "grey", "UNSUPPLIED" = "grey25", "SPILLAGE" = "grey25")





eCO2MixColors_lst = c("GEOTHERMAL" = "springgreen", "OTHER" = "lavender",
                      "NUCLEAR" = "#E4A701", "WIND" = "#72CBB7", "SOLAR" = "#D66B0D",  
                      "HYDRO" = "#2672B0", "BIO AND WASTE" = "#156956", "GAS" = "#F20809",
                      "COAL" = "#A68832", "OIL" = "#80549F",
                      "PSP STOR" = "blue", "CHEMICAL STOR" = "yellow", "THERMAL STOR" = "orange",
                      "HYDROGEN STOR" = "magenta", "COMPRESSED AIR STOR" = "salmon",
                      "IMPORTS" = "#969696", "UNSUPPLIED" = "grey25", "SPILLAGE" = "grey25")

eCO2MixFusion_lst = c("GEOTHERMAL" = "springgreen", "OTHER" = "lavender",
                      "NUCLEAR" = "#E4A701", "WIND" = "#72CBB7", "SOLAR" = "#D66B0D",
                      "HYDRO" = "#2672B0", "BIO AND WASTE" = "darkgreen", "GAS" = "#F20809",
                      "COAL" = "darkred", "OIL" = "#80549F",
                      "PSP STOR" = "blue", "CHEMICAL STOR" = "yellow", "THERMAL STOR" = "orange",
                      "HYDROGEN STOR" = "magenta", "COMPRESSED AIR STOR" = "salmon",
                      "IMPORTS" = "#969696", "UNSUPPLIED" = "grey25", "SPILLAGE" = "grey25")

eCO2MixFusion_noStorage_lst = c("GEOTHERMAL" = "springgreen",
                      "NUCLEAR" = "#E4A701", "WIND" = "#72CBB7", "SOLAR" = "#D66B0D",
                      "HYDRO" = "#2672B0", "BIO AND WASTE" = "darkgreen", "GAS" = "#F20809",
                      "COAL" = "darkred", "OIL" = "#80549F",
                      "IMPORTS" = "#969696", "UNSUPPLIED" = "grey25", "SPILLAGE" = "grey25")

eCO2MixFusion_noStorage_withCSP_lst = c("GEOTHERMAL" = "springgreen", "NUCLEAR" = "#E4A701", 
                                "WIND" = "#72CBB7", "PV" = "#D66B0D", "CSP" = "#EEDD82",
                                "HYDRO" = "#2672B0", "BIO AND WASTE" = "darkgreen", "GAS" = "#F20809",
                                "COAL" = "darkred", "OIL" = "#80549F",
                                "IMPORTS" = "#969696", "UNSUPPLIED" = "grey25", "SPILLAGE" = "grey25")

eCO2MixFusion_noStorage_withCSP_thermalBelow_lst = c("GEOTHERMAL" = "springgreen",  "NUCLEAR" = "#E4A701", 
                                                     "BIO AND WASTE" = "darkgreen", "COAL" = "darkred", 
                                                     "GAS" = "#F20809", "OIL" = "#80549F", 
                                                     "WIND" = "#72CBB7", "PV" = "#D66B0D", "CSP" = "#EEDD82", "HYDRO" = "#2672B0",
                                                     "IMPORTS" = "#969696", "UNSUPPLIED" = "grey25", "SPILLAGE" = "grey25")



deane_technology_colors <- c(
  "Bio and Waste" = "darkgreen",
  "Coal" = "darkred",
  "Gas" = "red",
  "Geothermal" = "springgreen",
  "Hydro" = "blue",
  "Nuclear" = "yellow",
  "Oil" = "darkslategray",
  "Solar" = "orange",
  "Wind" = "turquoise"
)


### Prod stack aliases (for AntaresViz)

# Créer un alias pour la stack de production
setProdStackAlias(
  name = "productionStack",
  variables = alist(
    NUCLEAR = NUCLEAR,
    WIND = WIND,
    SOLAR = SOLAR,
    GEOTHERMAL = `MISC. DTG`,
    # Nota bene : dans les graphes finaux de Deane, en toute logique le CSP est dans solaire
    # enfin je crois il faudrait lui demander demander
    HYDRO = `H. STOR`,
    # mais étrange alors, Wav est-il dans Hydro ou Other ? Est-ce qu'en fait s'il y a pas de Other
    # dans les graphes de fin c'est qu'il a mis des trucs en vrac (whatever Sto and Oth can be) ?
    # parce que en prenant un Other fidèle au PLEXOS (sauf le géothermique) on a quand même
    # un truc non négligeable (assez enthousiaste sur le marémoteur en fait, en tout cas en France)
    `BIO AND WASTE` = `MIX. FUEL`,
    GAS = GAS,
    COAL = COAL,
    OIL = OIL,
    OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    EXCHANGES = -BALANCE
  ),
  colors = c("yellow", "turquoise", "orange", "springgreen", "blue", 
             "darkgreen", "red", "darkred", "darkslategray", "lavender",
             "grey"),
  lines = alist(
    LOAD = LOAD,
    TOTAL_PRODUCTION =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`

  ),
  lineColors = c("black", "violetred")#"green")
)


setProdStackAlias(
  name = "productionStackWithUnsupplied",
  variables = alist(
    NUCLEAR = NUCLEAR,
    WIND = WIND,
    SOLAR = SOLAR,
    GEOTHERMAL = `MISC. DTG`,
    HYDRO = `H. STOR`,
    `BIO AND WASTE` = `MIX. FUEL`,
    GAS = GAS,
    COAL = COAL,
    OIL = OIL,
    OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    EXCHANGES = -BALANCE,
    UNSUPPLIED = `UNSP. ENRG`
  ),
  colors = c("yellow", "turquoise", "orange", "springgreen", "blue", 
             "darkgreen", "red", "darkred", "darkslategray", "lavender",
             "gray", "gray25"),
  lines = alist(
    LOAD = LOAD,
    TOTAL_PRODUCTION =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`
  ),
  lineColors = c("black", "violetred")
)

# So, looking at the graphs with no unsp energy but still gaps between production and load...
# "how much batteries help" is pretty much load - total production right ?

setProdStackAlias(
  name = "contributionsBatteries",
  variables = alist(
    # Par contre on fait un POV batterie (et on suit l'évolution du niveau)
    # ou on fait un POV réseau (et on suit l'évolution de - le niveau) ?
    `Contrib. STEP` = PSP_closed_withdrawal,
    `Contrib. Batteries` = Battery_withdrawal,
    `Contrib. Thermique` = Other1_withdrawal,
    `Contrib. Hydrogene` = Other2_withdrawal,
    `Contrib. Air comprime` = Other3_withdrawal,
    `Stock. STEP` = -PSP_closed_injection,
    `Stock. Batteries` = -Battery_injection,
    `Stock. Thermique` = -Other1_injection,
    `Stock. Hydrogene` = -Other2_injection,
    `Stock. Air comprime` = -Other3_injection
    # `Contrib. STEP` = -(PSP_closed_injection - PSP_closed_withdrawal),
    # `Contrib. Batteries` = -(Battery_injection - Battery_withdrawal),
    # `Contrib. Thermique` = -(Other1_injection - Other1_withdrawal),
    # `Contrib. Hydrogène` = -(Other2_injection - Other2_withdrawal),
    # `Contrib. Air comprimé` = -(Other3_injection - Other3_withdrawal)
  ),
  colors = c("darkblue", "darkgreen", "darkgoldenrod", "darkgray", "darksalmon",
             "lightblue", "lightgreen", "#EEDD82", "lightgray", "lightsalmon"),
  # colors = c("blue", "yellow", "orange", "cyan", "red"),
  lines = alist(
    `Niveau STEP` = PSP_closed_level - PSP_closed_level[1], # ça marche ça ? pour prendre le niveau initial ?
    `Niveau Batteries` = Battery_level - Battery_level[1],
    `Niveau Thermique` = Other1_level - Other1_level[1],
    `Niveau Hydrogene` = Other2_level - Other2_level[1],
    `Niveau Air comprime` = Other3_level - Other3_level[1]
  ),
  lineColors = c("blue", "green", "goldenrod", "gray", "salmon")
)

setProdStackAlias(
  name = "productionStackWithBatteryContributions",
  variables = alist(
    Geothermique = `MISC. DTG`,
    Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    # Est-ce correct tout de même de le mettre en base ?
    # Souvent c'est de l'autoconso plus qu'un apport au réseau, non ?
    Nucleaire = NUCLEAR,
    Eolien = WIND,
    Solaire = SOLAR,
    `Hydro lacs` = `H. STOR`,
    
    `Bio et dechets` = `MIX. FUEL`,
    Gaz = GAS,
    Charbon = COAL,
    Fioul = OIL,
    
    `Contrib. STEP` = PSP_closed_withdrawal - PSP_closed_injection,
    `Contrib. Batteries` = Battery_withdrawal - Battery_injection,
    `Contrib. Thermique` = Other1_withdrawal - Other1_injection,
    `Contrib. Hydrogene` = Other2_withdrawal - Other2_injection,
    `Contrib. Air comprime` = Other3_withdrawal - Other3_injection,
    
    `Imports/Exports` = -BALANCE,
    Defaillance = `UNSP. ENRG`,
    Ecretement = -`SPIL. ENRG`
  ),
  colors = c("springgreen", "lavender", "yellow", "turquoise", "orange", "blue", 
             "darkgreen", "red", "darkred", "darkslategray",
             "darkblue", "goldenrod", "burlywood", "darkmagenta", "salmon",
             "gray", "gray25", "gray25"
  ),
  lines = alist(
    Consommation = LOAD,
    Production =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`
  ),
  lineColors = c("black", "violetred")
)

setProdStackAlias(
  name = "eCO2MixColorsWithBatteryContributions",
  variables = alist(
    Geothermique = `MISC. DTG`,
    Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    Nucleaire = NUCLEAR,
    Eolien = WIND,
    Solaire = SOLAR,
    `Hydro lacs` = `H. STOR`,
    
    `Bio et dechets` = `MIX. FUEL`,
    Gaz = GAS,
    Charbon = COAL,
    Fioul = OIL,
    
    `Contrib. STEP` = PSP_closed_withdrawal - PSP_closed_injection,
    `Contrib. Batteries` = Battery_withdrawal - Battery_injection,
    `Contrib. Thermique` = Other1_withdrawal - Other1_injection,
    `Contrib. Hydrogene` = Other2_withdrawal - Other2_injection,
    `Contrib. Air comprime` = Other3_withdrawal - Other3_injection,
    
    `Imports/Exports` = -BALANCE,
    Defaillance = `UNSP. ENRG`,
    Ecretement = -`SPIL. ENRG`
  ),
  colors = c("springgreen", "lavender", "#E4A701", "#72CBB7", "#D66B0D", "#2672B0", 
             "#156956", "#F20809", "#A68832", "#80549F",
             # Envisager, éventuellement, de distinguer marémoteur du reste...
             "blue", "yellow", "orange", "magenta", "salmon",
             "#969696", "gray25", "gray25"
  ),
  lines = alist(
    Consommation = LOAD,
    Production =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`
  ),
  lineColors = c("black", "violetred")
)

RTE_blue = "#00A7DE"
Antares_yellow = "#FFB800"

setProdStackAlias(
  name = "eCO2MixFusionStack",
  variables = alist(
    Geothermique = `MISC. DTG`,
    Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    Nucleaire = NUCLEAR,
    Eolien = WIND,
    Solaire = SOLAR,
    `Hydro lacs` = `H. STOR`,
    
    `Bio et dechets` = `MIX. FUEL`,
    Gaz = GAS,
    Charbon = COAL,
    Fioul = OIL,
    
    `Contrib. STEP` = PSP_closed_withdrawal - PSP_closed_injection,
    `Contrib. Batteries` = Battery_withdrawal - Battery_injection,
    `Contrib. Thermique` = Other1_withdrawal - Other1_injection,
    `Contrib. Hydrogene` = Other2_withdrawal - Other2_injection,
    `Contrib. Air comprime` = Other3_withdrawal - Other3_injection,
    
    `Imports/Exports` = -BALANCE,
    Defaillance = `UNSP. ENRG`,
    Ecretement = -`SPIL. ENRG`
  ),
  colors = c("springgreen", "lavender", "#E4A701", "#72CBB7", "#D66B0D", "#2672B0", 
             "darkgreen", "#F20809", "darkred", "#80549F",
             # Envisager, éventuellement, de distinguer marémoteur du reste...
             "blue", "yellow", "orange", "magenta", "salmon",
             "#969696", "gray25", "gray25"
  ),
  lines = alist(
    Production =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    Consommation = LOAD
  ),
  lineColors = c("violetred", "black")
  # lineColors = c("black", "#FFB800")
)

setProdStackAlias(
  name = "eCO2MixFusionStack_noStorage_noOther",
  variables = alist(
    Geothermique = `MISC. DTG`,
    # Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    Nucleaire = NUCLEAR,
    Eolien = WIND,
    Solaire = SOLAR,
    `Hydro lacs` = `H. STOR`,
    
    `Bio et dechets` = `MIX. FUEL`,
    Gaz = GAS,
    Charbon = COAL,
    Fioul = OIL,
    
    `Imports/Exports` = -BALANCE,
    Defaillance = `UNSP. ENRG`,
    Ecretement = -`SPIL. ENRG`
  ),
  colors = c("springgreen", "#E4A701", "#72CBB7", "#D66B0D", "#2672B0", 
             "darkgreen", "#F20809", "darkred", "#80549F",
             "#969696", "gray25", "gray25"
  ),
  lines = alist(
    Production =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG`,
    Consommation = LOAD
  ),
  lineColors = c("violetred", "black")
  # lineColors = c("black", "#FFB800")
)

setProdStackAlias(
  name = "eCO2MixFusionStack_noStorage_withCSP",
  variables = alist(
    Geothermique = `MISC. DTG`,
    Nucleaire = NUCLEAR,
    # Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    Eolien = `WIND ONSHORE`,
    PV = `SOLAR PV`,
    CSP = `SOLAR CONCRT.`,
    `Hydro lacs` = `H. STOR`,
    
    
    `Bio et dechets` = `MIX. FUEL`,
    Gaz = GAS,
    Charbon = COAL,
    Fioul = OIL,
    
    `Imports/Exports` = -BALANCE,
    Defaillance = `UNSP. ENRG`,
    Ecretement = -`SPIL. ENRG`
  ),
  colors = c("springgreen", "#E4A701", "#72CBB7", "#D66B0D", "#EEDD82", "#2672B0", # rip lightgoldenrod
             "darkgreen", "#F20809", "darkred", "#80549F",
             "#969696", "gray25", "gray25"
  ),
  lines = alist(
    Production =  NUCLEAR + `WIND ONSHORE` + `SOLAR PV` + `SOLAR CONCRT.` + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG`,
    Consommation = LOAD
  ),
  lineColors = c("violetred", "black")
  # lineColors = c("black", "#FFB800")
)


setProdStackAlias(
  name = "eCO2MixFusionStack_noStorage_withCSP_thermalBelow",
  variables = alist(
    Geothermique = `MISC. DTG`,
    
    Nucleaire = NUCLEAR,
    `Bio et dechets` = `MIX. FUEL`,
    Charbon = COAL,
    Gaz = GAS,
    Fioul = OIL,
    
    # Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    Eolien = `WIND ONSHORE`,
    PV = `SOLAR PV`,
    CSP = `SOLAR CONCRT.`,
    `Hydro lacs` = `H. STOR`,
    
    #`Imports/Exports` = -BALANCE,
    Defaillance = `UNSP. ENRG`,
    Ecretement = -`SPIL. ENRG`
  ),
  colors = c("springgreen", "#E4A701", "darkgreen", "darkred", "#F20809", "#80549F",
             "#72CBB7", "#D66B0D", "#EEDD82",  "#2672B0", # rip lightgoldenrod
             
             # "#969696", 
             "gray25", "gray25"
  ),
  lines = alist(
    Production =  NUCLEAR + `WIND ONSHORE` + `SOLAR PV` + `SOLAR CONCRT.` + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG`,
    Consommation = LOAD
  ),
  lineColors = c("violetred", "black")
  # lineColors = c("black", "#FFB800")
)


# eCO2MixFusion_lst = c("GEOTHERMAL" = "springgreen", "OTHER" = "lavender",
#                       "NUCLEAR" = "#E4A701", "WIND" = "#72CBB7", "SOLAR" = "#D66B0D",
#                       "HYDRO" = "blue", "BIO AND WASTE" = "darkgreen", "GAS" = "#F20809",
#                       "COAL" = "darkred", "OIL" = "#80549F",
#                       "PSP STOR" = "darkblue", "CHEMICAL STOR" = "yellow", "THERMAL STOR" = "orange",
#                       "HYDROGEN STOR" = "magenta", "COMPRESSED AIR STOR" = "salmon",
#                       "IMPORTS" = "#969696", "UNSUPPLIED" = "grey25", "SPILLAGE" = "grey25")


# setProdStackAlias(
#   name = "eCO2MixFusionColors",
#   variables = alist(
#     Geothermique = `MISC. DTG`,
#     Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
#     Nucleaire = NUCLEAR,
#     Eolien = WIND,
#     Solaire = SOLAR,
#     `Hydro lacs` = `H. STOR`,
#     
#     `Bio et dechets` = `MIX. FUEL`,
#     Gaz = GAS,
#     Charbon = COAL,
#     Fioul = OIL,
#     
#     `Contrib. STEP` = PSP_closed_withdrawal - PSP_closed_injection,
#     `Contrib. Batteries` = Battery_withdrawal - Battery_injection,
#     `Contrib. Thermique` = Other1_withdrawal - Other1_injection,
#     `Contrib. Hydrogene` = Other2_withdrawal - Other2_injection,
#     `Contrib. Air comprime` = Other3_withdrawal - Other3_injection,
#     
#     `Imports/Exports` = -BALANCE,
#     Defaillance = `UNSP. ENRG`,
#     Ecretement = -`SPIL. ENRG`
#   ),
#   colors = c("springgreen", "lavender", "#E4A701", "#72CBB7", "#D66B0D", "blue", 
#              "#156956", "#F20809", "#A68832", "darkred",
#              # Envisager, éventuellement, de distinguer marémoteur du reste...
#              "blue", "yellow", "orange", "magenta", "salmon",
#              "#969696", "gray25", "gray25"
#   ),
#   lines = alist(
#     Consommation = LOAD,
#     Production =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`
#   ),
#   lineColors = c("black", "violetred")
# )





setProdStackAlias(
  name = "productionStackForAnnual",
  # Les tracés noir load et violet production gênent un peu
  # Et peut-être pour les graphes nationaux il faudrait comparer pays de chaque continent ?
  # Jsp bref
  variables = alist(
    Nucleaire = NUCLEAR,
    Eolien = WIND,
    Solaire = SOLAR,
    Geothermique = `MISC. DTG`,
    `Hydro lacs` = `H. STOR`,
    
    `Bio et dechets` = `MIX. FUEL`,
    Gaz = GAS,
    Charbon = COAL,
    Fioul = OIL,
    Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    
    `Contrib. STEP` = PSP_closed_withdrawal - PSP_closed_injection,
    `Contrib. Batteries` = Battery_withdrawal - Battery_injection,
    `Contrib. Thermique` = Other1_withdrawal - Other1_injection,
    `Contrib. Hydrogene` = Other2_withdrawal - Other2_injection,
    `Contrib. Air comprime` = Other3_withdrawal - Other3_injection,
    
    `Imports/Exports` = -BALANCE,
    Defaillance = `UNSP. ENRG`
  ),
  colors = c("yellow", "turquoise", "orange", "springgreen", "blue", 
             "darkgreen", "red", "darkred", "darkslategray", "lavender",
             "darkblue", "goldenrod", "burlywood", "darkmagenta", "salmon",
             "gray", "gray25"
  )
)

##########################################

#https://cran.r-project.org/web/packages/khroma/vignettes/tol.html
# ici des color palettes colorblind compatibles
# notamment les bright, contrast, vibrant, muted
# En fait celle ci est vrmt sympa :
# https://org.coloradomesa.edu/~mapierce2/accessible/
# https://personal.sron.nl/~pault/
# et ici y en a 16 !
# https://lospec.com/palette-list/krzywinski-colorblind-16
# Ouais mais "Some colors may appear similar to individuals with tritanopia."
# Pour montrer que c'est cool, ce serait bien de faire un graphe "simulant" le truc pour colorblind
# (il y a une formule dans le site de PaulT)
# faire un "colorblind mode" dans les paramètres serait dingo en tout cas

setProdStackAlias(
  name = "productionStackColorblindSafe",
  variables = alist(
    NUCLEAR = NUCLEAR,
    WIND = WIND,
    SOLAR = SOLAR,
    GEOTHERMAL = `MISC. DTG`,
    HYDRO = `H. STOR`,
    `BIO AND WASTE` = `MIX. FUEL`,
    GAS = GAS,
    COAL = COAL,
    OIL = OIL,
    OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    EXCHANGES = -BALANCE
  ),
  colors = c("#F7F056", "#7BAFDE", "#F4A736", "#CAACCB", "#1965B0", 
             "#4EB265", "#E65518", "#A5170E", "#42150A", "#AA6F9E",
             "#777777"),
  # Ici basé sur le discrete rainbow à 23 couleurs : https://personal.sron.nl/~pault/#fig:scheme_rainbow_discrete
  lines = alist(
    LOAD = LOAD,
    TOTAL_PRODUCTION =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`
  ),
  lineColors = c("black", "#882E72")
)