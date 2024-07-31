# Pas la foi de faire ça tout de suite, mais je pense que refactor idéal serait :
# Un main qui appelle antaresCreateStudy, puis LaunchSimulation, puis readResults

# Il resterait parameters.R mais typiquement ALL_DEANE_NODES serait plutôt dans
# antaresVariables, les trucs qui changent pas trop
# ou juste les appeler helperFunctions, helperVariables

# il y aurait peut etre tout un dossier genre createStudyModules ou quoi
# plutôt que juste "data"