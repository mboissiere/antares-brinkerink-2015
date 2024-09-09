OBJECTS_PATH = file.path("~", "GitHub", "antares-brinkerink-2015", "src", "objects",
                         fsep = .Platform$file.sep)
# Ptet qu'il faudra faire des paths globaux pour éviter pb de "ah on est dans un autre repertoire
# psk on l'a appelé depuis antaresCreateStudy" ou jsp
# print(OBJECTS_PATH)

CREATESTUDY_AUX_PATH = file.path("src", "antaresCreateStudy_aux",
                                 fsep = .Platform$file.sep)
preprocessPlexosData_module = file.path(CREATESTUDY_AUX_PATH, "preprocessPlexosData.R")
preprocessNinjaData_module = file.path(CREATESTUDY_AUX_PATH, "preprocessNinjaData.R")
addNodes_module = file.path(CREATESTUDY_AUX_PATH, "addNodes.R")
generateObjects_module = file.path(CREATESTUDY_AUX_PATH, "generateObjects.R")