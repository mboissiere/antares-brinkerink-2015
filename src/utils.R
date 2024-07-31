## Fichier visant à rassembler des fonctions utilitaires, une "boîte à outils" ##
## Les fonctions réutilisables / qui ne sont pas associées à un processus particulier, sont regroupés ici ##



# Fonction pour générer le nom d'un fichier basé sur l'heure actuelle
generateName <- function(prefix) {
  timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M_%S")
  return(paste0(prefix, "__", timestamp))
}

# Fonction pour trouver automatiquement quel jour de la semaine était le 1er janvier
# Define a vector of weekday names in English
weekday_names <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

# Function to find the day of the week for January 1st of a given year
find_january_1st_day <- function(year) {
  date <- as.Date(paste0(year, "-01-01"))
  day_of_week_index <- format(date, "%u")  # %u gives the day of the week as a number (1 for Monday, ..., 7 for Sunday)
  
  # Convert day_of_week_index to numeric and then to integer
  day_of_week_index <- as.numeric(day_of_week_index)
  day_of_week_index <- as.integer(day_of_week_index)
  
  # Get the corresponding weekday name from the vector
  day_of_week <- weekday_names[day_of_week_index]
  
  # Return day of the week
  return(day_of_week)
}

# Fonction pour trouver automatiquement si l'année étudiée est bissextile
is_leap_year <- function(year) {
  if ((year %% 4 == 0 && year %% 100 != 0) || (year %% 400 == 0)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

linear_transform_coordinates <- function(coords, lat_scale = 20, lon_scale = 20) {
  
  x <- coords$lon * lon_scale 
  y <- coords$lat * lat_scale
  return(list(x = x, y = y))
  
  
}

# print(linear_transform_coordinates(coords))

#getAntaresCoordsFromCountry <- function(country_code) {
  #return(linear_transform_coordinates(get_country_coordinates(country_code)))
#}

getISOfromDeane <- function(input_string) {
  substr(input_string, 4, 6)
}



log_message <- function(message, log_file, printer = TRUE) {
  
  # Open the file in append mode
  con <- file(log_file, open = "a")
  
  # Write the error message
  if (printer) {
    cat(message)
  }
  writeLines(message, con)
  
  # Close the connection
  close(con)
}

# Faire une fonction : preprocess data en enlevant espaces, en mettant _
