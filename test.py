# SET  28 January 2023
# SET does not allow  duplicates
calculation_to_units = 24
name_of_unit = "hours"  # this variable is GLOBAL


def days_to_units(num_of_days):
    return f"{num_of_days} days are {num_of_days * calculation_to_units} {name_of_unit}"


""" BEST PRACTICE - block below can be put as a function.
if user_input.isdigit():
    user_input_number=int(user_input)
    calculated_value = days_to_units(int(user_input))
    print(f"{calculated_value}")
else:
    print("your input was not a number")
"""


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


""" on the first run user_input is evaluated but since user has not typed anything we need to declare an  empty variable 
#1 variable needs to be initialized before loop starts, otherwise it will complain and stop. 
In this case we assign an empty variable """
user_input = ""

''' #2 condition gets evaluated 
as long as "exit" was no typed by a user, the condition is still met and function executed 
'''
while user_input != "exit":

    """ 3. user is asked for an input """
    user_input = input("hey input number of days as a comma separated list and i will convert it to hours\n")
    list_of_days=user_input.split(",")
    print(list_of_days)  # shows type of the user input converted
    print(set(list_of_days))
    print(type(list_of_days))
    print(type(set(list_of_days))) # nested function. executions from inner most function to the outer most function
    for num_of_days_element in set(list_of_days):  # condition is implicit
        validate_and_execute()  # this needs to be indented for "FOR LOOP" logic
""" output
1,11,1
<class 'list'>
['1', '11', '1']
11 days are 264 hours
1 days are 24 hours 
"""