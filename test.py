# Dictionary Data type 19  February 2023

def days_to_units(num_of_days, conversion_unit):
    if conversion_unit == "hours":
        return f"{num_of_days} days are {num_of_days *24} {conversion_unit}" # {conversion_unit} can be hard coded as
        # "hours"
    elif conversion_unit == "minutes":
        return f"{num_of_days} days are {num_of_days * 24 * 60} {conversion_unit}"
    else:
        return "unsupported unit"

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
    print(type(days_and_unit_dictionary))
    validate_and_execute()

    """ Summary of types of DATA TYPES
    #STRING message = "enter some value"
    #INT days = 20       
    #FLOAT price = 9.89    
    #BOOLEAN valid_number = True
    #LISTs list_of_days=[20, 40, 41] #Numbers
    #LISTs list_of_months=["January", "40", "41"] #STRING
    #SETs set_of_days= {20,40,11} # DO NOT ALLOW DUPLICATES
    #DICTIONARY days_and_unit = {"days": 20, "unit": "hours"} 
    """
"""
my_list=["20", "30"]
print(my_list[0])
my_dictionary={"days": "30", "unit": "hours","message":"all is not too bad"}
print(my_dictionary["days"], my_dictionary["message"])
"""