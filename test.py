my_set = {"January", "March", "February", "January"}
my_set.add("April")  # adding
for element in my_set:
    print(element)  # listed in a random order
''' SETs: 
 - do not allow duplicates
 - output is not ordered
  '''
print(my_set)

# removing an element from the set
my_set.remove("January")
for element in my_set:
    print(element)  # printing elements
print("printing a whole set")
print(my_set) # printing a whole set