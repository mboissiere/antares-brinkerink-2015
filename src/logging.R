# Install and load the futile.logger package
if (!require("futile.logger")) {
  install.packages("futile.logger")
}
library(futile.logger)

source("parameters.R")

# Function to create the day directory
createDayDirectory <- function() {
  day_dir <- paste0("./logs/logs_", format(Sys.time(), "%Y-%m-%d"))
  if (!dir.exists(day_dir)) {
    dir.create(day_dir)
  }
  return(day_dir)
}

# Function to create the simulation directory
createSimulationDirectory <- function(day_dir) {
  sim_dir <- paste0(day_dir, "/", format(Sys.time(), "%H-%M-%S"))
  dir.create(sim_dir)
  return(sim_dir)
}

# Function to set up the loggers
setupLoggers <- function(sim_dir) {
  # File appenders
  flog.appender(appender.file(paste0(sim_dir, "/full.log")), name = "full")
  flog.appender(appender.file(paste0(sim_dir, "/errors.log")), name = "errors")
  flog.appender(appender.file(paste0(sim_dir, "/main.log")), name = "main")
  
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

setupLogging <- function() {
  day_dir <- createDayDirectory()
  sim_dir <- createSimulationDirectory(day_dir)
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

