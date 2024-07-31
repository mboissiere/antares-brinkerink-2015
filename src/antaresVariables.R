## Fichier visant à rassembler les variables, chemin etc utilisées dans le script principal ##
# mais que l'on change peu (TODO : recommenter)
## Ainsi, une modification de configuration se fera généralement ici ##

### VARIABLES (fonctions plus bas) ###

# Chemin racine des études
# base_path <- ".\\antares\\examples\\studies"
base_path <- file.path("antares", "examples", "studies", 
                       fsep = .Platform$file.sep
                       )
# zut, je pensais que le but était de s'en affranchir, mais peut-être pas...
# Idée : faire une variable globale "file path seperator" qui change tout d'un coup,
# en cas de problème à la noix

# Oh, quoique, la doc R me recommande file.path(…, fsep = .Platform$file.sep)

# Version d'Antares utilisée
antares_version = "8.6.0"

# Premier jour étudié dans la simulation
simulation_start = 1

# Dernier jour étudié dans la simulation
simulation_end = 365

# Premier mois étudié dans la simulation
first_month_in_year = "january"

# Premier jour de la semaine dans la simulation
first_weekday = "Monday"

# Production de scénario "year by year" ou pas
year_by_year = TRUE

# Génération d'un fichier de synthèse
generateSynthesis = TRUE