# Install and load the futile.logger package
if (!require("futile.logger")) {
  install.packages("futile.logger")
}
library(futile.logger)
# ah bah tiens tu devrais etre dans requirements toi

# A FAIRE : une sauvegarde des logs dans le dossier d'output.
# les études en vrai garder le YYMMDD mais en plus court.
# les simulations... normalement on change le nom qd mm

# Je pense que pour faire ça, il va clairement falloir mettre le
# createOutputFolder dans main/ utils
# au lieu de le limiter à un truc de readresults

source("parameters.R")

# NB : Initially thought logs could be in a "output" package of the function
# that would return Antares studies, but I feel like it creates them in 
# "antares/studies" automatically and there might not be an easy fix.
# Apart from a script copying the files ?
# anyway, a workaround for the moment could be giving the log folder the same
# name as the study
# hm, theres file.copy. Why not honestly.
# If I start knowing how to screenshot AntaresViz / automatically analyse them,
# that could be cool.

# Function to create the day directory
createDayDirectory <- function() {
  day_dir <- paste0("./logs/logs_", format(Sys.time(), "%Y-%m-%d"))
  if (!dir.exists(day_dir)) {
    dir.create(day_dir)
  }
  return(day_dir)
}

# Function to create the simulation directory
createSimulationDirectory <- function(day_dir, study_name) {
  folder_name = paste0(format(Sys.time(), "%H-%M-%S"), "_", study_name)
  # Better for sorting by chronological order!
  
  sim_dir <- file.path(day_dir, folder_name)
  dir.create(sim_dir)
  return(sim_dir)
}

# Function to set up the loggers
setupLoggers <- function(sim_dir) {
  # File appenders
  flog.appender(appender.file(paste0(sim_dir, "/full.log")), name = "full")
  flog.appender(appender.file(paste0(sim_dir, "/errors.log")), name = "errors")
  flog.appender(appender.file(paste0(sim_dir, "/main.log")), name = "main")
  # Changer "full" en "detailed"
  # et séparer un "clustering" qui vraiment serait trop long pour le full imo
  # en vrai si c'est ok... juste si on print pas le tableau cinq fois à chaque fois...
  
  # Console appenders
  if (PRINT_FULL_LOG_TO_CONSOLE) {
    flog.appender(appender.console(), name = "full_console")
  }
  flog.appender(appender.console(), name = "main_console")
  flog.appender(appender.console(), name = "errors_console")
  
  # Thresholds for file loggers
  flog.threshold(INFO, name = "full")
  flog.threshold(ERROR, name = "errors")
  flog.threshold(INFO, name = "main")
  
  # Thresholds for console loggers
  if (PRINT_FULL_LOG_TO_CONSOLE) {
    flog.threshold(INFO, name = "full_console")
  }
  flog.threshold(INFO, name = "main_console")
  flog.threshold(ERROR, name = "errors_console")
}

setupLogging <- function(study_name = "") {
  day_dir <- createDayDirectory()
  sim_dir <- createSimulationDirectory(day_dir, study_name)
  setupLoggers(sim_dir)
}


# Define logging functions
logFull <- function(msg) {
  flog.info(msg, name = "full")
  if (PRINT_FULL_LOG_TO_CONSOLE) {
    flog.info(msg, name = "full_console")
  }
}

logError <- function(msg) {
  flog.error(msg, name = "errors")
  flog.error(msg, name = "errors_console")
  flog.info(msg, name = "full")
}


logMain <- function(msg) {
  flog.info(msg, name = "main")
  flog.info(msg, name = "main_console")
  flog.info(msg, name = "full")
}

# logNextStep <- function() {
#   logMain("\n")
#   logMain("--------------------------------------------------------------------------------")
#   logMain("\n")
# }

