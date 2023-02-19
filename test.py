# Dictionary Data type 19  February 2023

calculation_to_units = 24
name_of_unit = "hours"  # this variable is GLOBAL


def days_to_units(num_of_days, conversion_unit):
    return f"{num_of_days} days are {num_of_days * calculation_to_units} {name_of_unit}"


def validate_and_execute():  # function is used to check if the input is a digit, float or string
    try:  # try/except is used to check  several lines for errors. if you cannot use IF...ELSE statement
        user_input_number = int(days_and_unit_dictionary["days"])
        if user_input_number > 0:
            calculated_value = days_to_units(user_input_number, days_and_unit_dictionary["unit"])
            print(calculated_value)
        elif user_input_number == 0:
            print("you entered a 0, enter a positive number")
        else:
            print("you entered a negative number, no conversion for you")
    except ValueError:
        print("your input is not a valid number")


user_input = ""
while user_input != "exit":
    user_input = input("hey input number of days and conversion unit\n")
    days_and_unit = user_input.split(":")  # user value is getting split into a list "45:hours" => ["45", "hours"]
    print(days_and_unit)
    # dictionary syntax / key value pairs {"days":20,"units":"hours"}
    days_and_unit_dictionary = {"days": days_and_unit[0], "unit": days_and_unit[1]}
    print(days_and_unit_dictionary)
    validate_and_execute()
"""
my_list=["20", "30"]
print(my_list[0])
my_dictionary={"days": "30", "unit": "hours","message":"all is not too bad"}
print(my_dictionary["days"], my_dictionary["message"])
"""