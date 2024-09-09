OBJECTS_PATH = file.path("src", "objects",
                         fsep = .Platform$file.sep)

CREATESTUDY_AUX_PATH = file.path("src", "antaresCreateStudy_aux",
                                 fsep = .Platform$file.sep)
preprocessPlexosData_module = file.path(CREATESTUDY_AUX_PATH, "preprocessPlexosData.R")
preprocessNinjaData_module = file.path(CREATESTUDY_AUX_PATH, "preprocessNinjaData.R")
addNodes_module = file.path(CREATESTUDY_AUX_PATH, "addNodes.R")