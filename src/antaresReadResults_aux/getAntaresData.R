#################################### GLOBAL ####################################

getGlobalData <- function(timestep, 
                          variables = COMMON_COLUMNS,
                          divide_by_hours = TRUE) {
  
  global_data <- readAntares(areas = NULL,
                             districts = "world", # ça pourrait être une variable etc etc
                             mcYears = NULL,
                             select = variables,
                             timeStep = timestep,
                             simplify = TRUE
  )
  
  if (divide_by_hours) {
    divideAntaresDataByHours(global_data, variables, timestep)
  }
  return(global_data)
} 