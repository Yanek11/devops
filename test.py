# SETS - data type
# list of UNIQUE elements. It does not allow duplicates

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

    user_input = input("hey input alist as a comma separated list and i will convert it to hours\n")
    list_of_days = user_input.split(",")  # extracting list to a variable
    print(list_of_days)
    print(set(list_of_days))
    print(type(list_of_days))
    print(type(set(list_of_days)))  # shows type of the user input converted
    """ NESTED FUNCTION EXECUTION !!!
    1. set(list_of_days)
        input - user input
        returns - converted set
    2. type(return_value_of_prev_set)
        input - the converted set
        output - returns data typeof the set
    3. print(return_value_of_prev_set)
        input - the data type
        output - prints the value to the console
    """
    for num_of_days_element in set(list_of_days):
        validate_and_execute()
