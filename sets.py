# SETs 28 January 2023 , 11 Feb

calculation_to_units = 24
name_of_unit = "hours"  # this variable is GLOBAL


def days_to_units(num_of_days):
    return f"{num_of_days} days are {num_of_days * calculation_to_units} {name_of_unit}"

def validate_and_execute():  # function is used to check if the input is a digit, float or string
    try:  # try/except is used to check  several lines for errors. if you cannot use IF...ELSE statement
        user_input_number = int(num_of_days_element)
        if user_input_number > 0:
            calculated_value = days_to_units(user_input_number)
            print(calculated_value)
        elif user_input_number == 0:
            print("you entered a 0, enter a positive number")
        else:
            print("you entered a negative number, no conversion for you")
    except ValueError:
        print("your input is not a valid number")


user_input = ""
while user_input != "exit":

    # comment


    user_input = input("hey input number of days as a comma separated list and i will convert it to hours\n")
    list_of_days=user_input.split(",") # defining a variable to make code more efficient
    print(list_of_days)  # shows type of the user input converted
    print(set(list_of_days))
    print(type(list_of_days))
    print(type(set(list_of_days)))
    '''  Nested Function: gets executed from inside out 
    1. set(list_of_days) - function SET is executed on users input array. output is converted set with no duplicates
    2. type(set(list_of_days)) - function TYPE is executed on value of previous function. Input - converted SET
    3. print(type(set(list_of_days))) - function PRINT is executed on a result of previous function TYPE. 
        Input - data type. Output - prints values to the console                                       '''
    for num_of_days_element in set(list_of_days):  # condition is implicit
        validate_and_execute()  # this needs to be indented for "FOR LOOP" logic




''' second part of SETS '''

my_set = {"January", "March", "February", "January"}

my_set.add("April")  # adding
# for element in my_set:
print(my_set)

my_set.remove("January")  # removing both occurrences of January
print(my_set)

""" removing from LISTS """

my_list = ["January", "March", "February", "March"]
print(my_list)
my_list.remove("March")  # removing only FIRST occurrence of March
print(my_list)
