#  ERROR HANDLING: TRY ... EXCEPT

calculation_to_units=24
name_of_unit = "hours"  # this variable is GLOBAL


def days_to_units(num_of_days):
    return f"{num_of_days} days are {num_of_days*calculation_to_units} {name_of_unit}"
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
        user_input_number = int(user_input)
        if user_input_number > 0:
            calculated_value=days_to_units(user_input_number)
            print(calculated_value)
        elif user_input_number == 0:
            print("you entered a 0, enter a positive number")
    except ValueError:

        print("your input is not a valid number")
user_input = input("hey input some data and i will convert it to hours\n")
validate_and_execute()

