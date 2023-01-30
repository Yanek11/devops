#1 Built-In Functions
"""
print()
input()
set()
type()
int
"""
from typing import List


#2 User defined

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

#3 Functions that are called directly on the value
    # each data type has a separate group of functions

 print(type(user_input.split(",")))
"2, 3".split()