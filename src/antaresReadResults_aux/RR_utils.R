divideAntaresDataByHours <- function(antares_data, 
                                     timestep,
                                     variables = COMMON_COLUMNS
                                     ) {
  hours <- NB_HOURS_IN_TIMESTEP[[timestep]]
  
  variables_of_interest_in_mwh = intersect(variables, MWH_COLUMNS)
  
  antares_data <- antares_data %>%
    mutate(across(all_of(variables_of_interest_in_mwh), ~ . / hours))
}

###

convertAntaresMWhToUnit <- function(antares_data, 
                                    unit,
                                    variables = COMMON_COLUMNS
                                    ) {
  nb_mwh <- NB_MWH_IN_UNIT[[unit]]
  
  variables_of_interest_in_mwh = intersect(variables, MWH_COLUMNS)
  
  antares_data <- antares_data %>%
    mutate(across(all_of(variables_of_interest_in_mwh), ~ . / nb_mwh))
}

adaptAntaresVariables <- function(antares_data_tbl) {
  
  renamed_tbl <- antares_data_tbl %>%
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
  
  return(renamed_tbl)
}

