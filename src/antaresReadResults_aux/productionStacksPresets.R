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
    # on ne compte pas du coup les batteries ? ouais voilà mdr ce que j'avais déjà dit en fait
    # pour moi c'est ni dans production mais après on peut faire un graphe batteries
    # est-ce que les psp injection des batteries machin faut le mettre ? ou c'est du double comptage ?
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
  # NB : je crois que gray75 est plus sombre qu'annoncé
  lines = alist(
    LOAD = LOAD,
    TOTAL_PRODUCTION =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`
  ),
  lineColors = c("black", "violetred")
)

# So, looking at the graphs with no unsp energy but still gaps between production and load...
# "how much batteries help" is pretty much load - total production right ? maybe ??

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
             "lightblue", "lightgreen", "lightgoldenrod", "lightgray", "lightsalmon"),
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
    Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
    
    `Contrib. STEP` = PSP_closed_withdrawal - PSP_closed_injection,
    `Contrib. Batteries` = Battery_withdrawal - Battery_injection,
    `Contrib. Thermique` = Other1_withdrawal - Other1_injection,
    `Contrib. Hydrogene` = Other2_withdrawal - Other2_injection,
    `Contrib. Air comprime` = Other3_withdrawal - Other3_injection,
    
    `Imports/Exports` = -BALANCE,
    Defaillance = `UNSP. ENRG`
  ),
  colors = c("springgreen", "yellow", "turquoise", "orange", "blue", 
             "darkgreen", "red", "darkred", "darkslategray", "lavender",
             "darkblue", "goldenrod", "burlywood", "darkmagenta", "salmon",
             "gray", "gray25"
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
    Nucleaire = NUCLEAR,
    Eolien = WIND,
    Solaire = SOLAR,
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
  colors = c("springgreen", "#E4A701", "#72CBB7", "#D66B0D", "#2672B0", 
             "#156956", "#F20809", "#A68832", "#80549F", "lavender",
             # Envisager, éventuellement, de distinguer marémoteur du reste...
             "blue", "yellow", "orange", "magenta", "salmon",
             "#969696", "gray25"
  ),
  lines = alist(
    Consommation = LOAD,
    Production =  NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`
  ),
  lineColors = c("black", "violetred")
)





setProdStackAlias(
  name = "productionStackForAnnual",
  
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

# Ok ici on va essayer de faire comme le précédent mais en dynamique,
# en excluant les trucs nuls

#### OK BAH C'EST HORRIBLE et si je continue à forcer je vais câbler si jamais Nicolas trouve mieux
# en un claquement de doigts
# c'est pas vrai Nicolas si tu lis ceci j'aime beaucoup quand tu trouves mieux en un claquement de doigts
# c'est très fort et admirable et je suis toujours heureux d'en apprendre plus
# 
# all_variables <- alist(
#   Nucleaire = NUCLEAR,
#   Eolien = WIND,
#   Solaire = SOLAR,
#   Geothermique = `MISC. DTG`,
#   `Hydro lacs` = `H. STOR`,
#   `Bio et déchets` = `MIX. FUEL`,
#   Gaz = GAS,
#   Charbon = COAL,
#   Fioul = OIL,
#   Autres = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
#   `Contrib. STEP` = PSP_closed_withdrawal - PSP_closed_injection,
#   `Contrib. Batteries` = Battery_withdrawal - Battery_injection,
#   `Contrib. Thermique` = Other1_withdrawal - Other1_injection,
#   `Contrib. Hydrogene` = Other2_withdrawal - Other2_injection,
#   `Contrib. Air comprime` = Other3_withdrawal - Other3_injection,
#   `Import/Export` = -BALANCE,
#   Defaillance = `UNSP. ENRG`
# )
# 
# all_colors <- c("yellow", "turquoise", "orange", "springgreen", "blue", 
#                 "darkgreen", "red", "darkred", "darkslategray", "lavender",
#                 "darkblue", "goldenrod", "burlywood", "darkmagenta", "salmon",
#                 "gray", "gray25"
# )
# 
# # # Subset of variables contributing to "Production"
# # production_subset <- alist(NUCLEAR, WIND, SOLAR, `H. STOR`, GAS, COAL, OIL, `MIX. FUEL`, `MISC. DTG`, `MISC. DTG 2`, `MISC. DTG 3`, `MISC. DTG 4`)
# 
# 
# # # Define production subset (non-null variables for production)
# # production_subset <- c("NUCLEAR", "WIND", "SOLAR", "`H. STOR`", "GAS", "COAL", "OIL", "`MIX. FUEL`", "`MISC. DTG`", "`MISC. DTG 2`", "`MISC. DTG 3`", "`MISC. DTG 4`")
# 
# 
# createFilteredStack <- function(stack_name, null_variables) {
#   # Initialize empty alist for variables
#   variables_list <- alist()
#   
#   # Initialize empty alist for lines
#   lines_list <- alist()
#   
#   # Add non-null variables to the variables_list
#   for (var in names(all_variables)) {
#     if (!(deparse(all_variables[[var]]) %in% null_variables)) {
#       variables_list[[var]] <- all_variables[[var]]
#     }
#   }
#   print(variables_list)
#   
#   # Filter colors
#   filtered_colors <- all_colors[names(all_variables) %in% names(variables_list)]
#   print(filtered_colors)
#   
#   # Add lines
#   lines_list$Consommation <- quote(LOAD)
#   
#   ####### SCREW THIS
#   # # Filter out non-null variables from the production subset
#   # filtered_production <- production_subset[!(production_subset %in% null_variables)]
#   # 
#   # # Build the Production expression dynamically
#   # production_expr <- as.call(
#   #   c(
#   #     quote(`+`), 
#   #     lapply(filtered_production, function(var) {
#   #       # Safely convert string to an expression
#   #       eval(parse(text = var))
#   #     })
#   #   )
#   # )
#   # 
#   # # Add production line to the lines_list
#   # lines_list$Production <- production_expr
#   
#   # Creating the `setProdStackAlias` dynamically
#   do.call(setProdStackAlias, list(
#     name = stack_name,
#     variables = variables_list,
#     colors = filtered_colors,
#     lines = lines_list,
#     lineColors = c("black", "violetred")
#   ))
#   
# }






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