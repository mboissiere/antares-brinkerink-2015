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
                                    variables = COMMON_COLUMNS # is this even necessary ?
                                    # we can just convert all MWh columns and then filter this later
                                    ) {
  nb_mwh <- NB_MWH_IN_UNIT[[unit]]
  
  variables_of_interest_in_mwh = intersect(variables, MWH_COLUMNS)
  
  antares_data <- antares_data %>%
    mutate(across(all_of(variables_of_interest_in_mwh), ~ . / nb_mwh))
}

adaptAntaresVariables <- function(antares_data_tbl) {
  if (READ_2060) {
    renamed_tbl <- antares_data_tbl %>%
      mutate(
        #IMPORTS = -BALANCE,
             SPILLAGE = -`SPIL. ENRG`
      ) %>%
      rename(
        GEOTHERMAL = `MISC. DTG`,
        HYDRO = `H. STOR`,
        `BIO AND WASTE` = `MIX. FUEL`,
        UNSUPPLIED = `UNSP. ENRG`,
        PV = `SOLAR PV`,
        CSP = `SOLAR CONCRT.`,
        WIND = `WIND ONSHORE`,
      )
  } else {
    renamed_tbl <- antares_data_tbl %>%
      mutate(OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
             
             `PSP STOR` = PSP_closed_withdrawal - PSP_closed_injection,
             `CHEMICAL STOR` = Battery_withdrawal - Battery_injection,
             `THERMAL STOR` = Other1_withdrawal - Other1_injection,
             `HYDROGEN STOR` = Other2_withdrawal - Other2_injection,
             `COMPRESSED AIR STOR` = Other3_withdrawal - Other3_injection,
             
             IMPORTS = -BALANCE,
             SPILLAGE = -`SPIL. ENRG`
      ) %>%
      select(-`MISC. DTG 2`, -`MISC. DTG 3`, -`MISC. DTG 4`) %>%
      rename(
        GEOTHERMAL = `MISC. DTG`,
        HYDRO = `H. STOR`,
        `BIO AND WASTE` = `MIX. FUEL`,
        UNSUPPLIED = `UNSP. ENRG`,
      )
  }
  
  
  return(renamed_tbl)
}

