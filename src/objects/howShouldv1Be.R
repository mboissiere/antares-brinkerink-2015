# Ok hear me out bc object usage has been a blessing for rapidity of testing
# but is starting to become a mess (I'm becoming lazy and making one-time)
# functions that create objects and then reuse the objects and never check functioning of functions
# again, etc
# 
# A release of the code should :
# - not include objects by default
# - have functions that transparently recreate them, and save them
# - in the processes, have a function that checks if some objects already exist
# and if they do, import them

# it's crucial because as i import objects, save them, read from them etc
# any errors that might have been in the data is seperated from it.
# perhaps i multiplied by something at some point and it remained. who knows.