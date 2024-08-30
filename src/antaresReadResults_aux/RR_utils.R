divideAntaresDataByHours <- function(antares_data, variables, timestep) {
  hours <- NB_HOURS_IN_TIMESTEP[[timestep]]
  
  variables_of_interest_in_mwh = intersect(variables, MWH_COLUMNS)
  
  antares_data <- antares_data %>%
    mutate(across(all_of(variables_of_interest_in_mwh), ~ . / hours))
}

convertTo

