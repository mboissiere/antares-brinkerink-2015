#################################### GLOBAL ####################################

getGlobalAntaresData <- function(timestep, 
                                 variables = COMMON_COLUMNS#,
                                 #divide_by_hours = TRUE
) {
  global_data <- readAntares(areas = NULL,
                             districts = "world", # ça pourrait être une variable etc etc
                             mcYears = NULL,
                             select = variables,
                             timeStep = timestep,
                             simplify = TRUE
  )
  # if (divide_by_hours) {
  #   divideAntaresDataByHours(global_data, variables, timestep)
  # }
  return(global_data)
}

#########

getContinentalAntaresData <- function(timestep, 
                                      variables = COMMON_COLUMNS
                                      ) {
  
  continental_districts = getDistricts(select = CONTINENTS,
                                       regexpSelect = FALSE)
  
  continental_data <- readAntares(areas = NULL,
                                  districts = continental_districts,
                                  mcYears = NULL,
                                  select = variables,
                                  timeStep = timestep,
                                  simplify = TRUE
  )
  return(continental_data)
} 


##########

getNationalAntaresData <- function(timestep,
                            variables = COMMUN_COLUMNS
                            ) {
  country_areas = getAreas(select = COUNTRIES,
                           regexpSelect = FALSE)
  country_districts = getDistricts(select = COUNTRIES,
                                   regexpSelect = FALSE)
  
  antares_data <- readAntares(areas = country_areas,
                              districts = country_districts,
                              mcYears = NULL,# again, if it's averages we want, which should be a parameter imo
                              select = variables,
                              timeStep = timestep
  )
  
  areas_data <- antares_data$areas
  districts_data <- antares_data$districts
  
  colnames(districts_data)[colnames(districts_data) == "district"] <- "area"

  combined_data <- rbind(areas_data, districts_data)
  
  national_data <- as.antaresDataTable(combined_data, synthesis = TRUE, timeStep = timestep, type = "areas")
  return(national_data)
}

##########


getRegionalAntaresData <- function(timestep, 
                            variables = COMMON_COLUMNS
                            ) {
  regional_areas = getAreas(select = REGIONS,
                            regexpSelect = FALSE)
  
  regional_data <- readAntares(areas = regional_areas,
                               districts = NULL,
                               mcYears = NULL,# again, if it's averages we want, which should be a parameter imo
                               select = variables,
                               timeStep = timestep
  )
  return(regional_data)
} 