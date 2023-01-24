

user_input = input("hey input some data and i will convert it to hours\n")
validate_and_execute()


print(200)
print(200)  # STRING
print(1.5)  # FLOAT
print(1)  # INTEGER


daysM=20*24*60  # assign a variable
daysS=20*24*60*60

print(daysS)  # testing
print(f"20 days are   {daysM}   minutes")  # including var

print(f"20 days are   {daysS}   seconds")

calculation_to_units=24*60
name_of_unit = "minutes"  # this variable is GLOBAL
print(f"20 days are {20*calculation_to_units}   {name_of_unit}")
print(f"35 days are {35*calculation_to_units}   {name_of_unit}")
print(f"50 days are {50*calculation_to_units}   {name_of_unit}")
print(f"100 days are {100*calculation_to_units}   {name_of_unit}")

# FUNCTIONS


def days_to_units(num_of_days, custom_message): # num_of_days is LOCAL scope variable
    print(f"{num_of_days} days are {num_of_days * calculation_to_units}   {name_of_unit}")
    print(custom_message)

# example of using functions
days_to_units(22, "super")
days_to_units(11, "vey bad")

# SCOPE
# variable is only available from inside the region it is created
# GLOBAL scope - variables available from within any scope
# LOCAL scope - variables created inside a function can be used only inside that function

# defining a local var "num_of_days" that has the same name as the one from function days_to_units (line 25)

def scope_check(num_of_days):
    my_var="variable inside function"
    print(name_of_unit) # GLOBAL var
    print(f"{num_of_days}") # LOCAL var / this function
    print(my_var) # LOCAL inside function BODY
scope_check(1)

#  USER INPUT
calculation_to_units=24
name_of_unit = "hours"  # this variable is GLOBAL


def days_to_units(num_of_days):
    print(f"{num_of_days} days are {num_of_days*calculation_to_units} {name_of_unit}")

user_input=input("hey input some data\n")
print(f"what user given is {user_input}")

#  FUNCTIONS with RETURN VALUES
calculation_to_units=24
name_of_unit = "hours"  # this variable is GLOBAL


def days_to_units(num_of_days):
    return f"{num_of_days} days are {num_of_days*calculation_to_units} {name_of_unit}" #  value is returned by a function


#  user_input=input("hey input some data\n")

my_var = days_to_units(20)
print(my_var)

# user_input=input("hey user gimme some\n")
# print(f"what user given is {user_input}")

# USER INPUT 2

calculation_to_units=24
name_of_unit = "hours"  # this variable is GLOBAL

def days_to_units(num_of_days):
    return f"{num_of_days} days are {num_of_days*calculation_to_units} {name_of_unit}"


user_input = input("hey input some data\n")

# input value must be converted to Integer, otherwise python will treat the input value as String

# Method 1

calculated_value = days_to_units(int(user_input))
print(f"{calculated_value}")


# Method 2
"""
user_input_number = int(user_input)
calculated_value = days_to_units(user_input_number)
print(f"{calculated_value}")
"""

#  CONDITIONALS
# validating users input

calculation_to_units=24
name_of_unit = "hours"  # this variable is GLOBAL


def days_to_units(num_of_days):
    condition_check = num_of_days > 0  # assign to a variable
    if num_of_days > 0:
        return f"{num_of_days} days are {num_of_days*calculation_to_units} {name_of_unit}"
    elif num_of_days == 0:
        return "you entered 0, please gimme soemthing else"
    else:
        return "you entered incorrect value you sucker"


user_input = input("hey input some data\n")

# input value must be converted to Integer, otherwise python will treat the input value as String

# Method 1

calculated_value = days_to_units(int(user_input))
print(f"{calculated_value}")


# Method 2
"""
user_input_number = int(user_input)
calculated_value = days_to_units(user_input_number)
print(f"{calculated_value}")
"""

#  MORE VALIDATION
# validating users input

calculation_to_units=24
name_of_unit = "hours"  # this variable is GLOBAL


def days_to_units(num_of_days):
    condition_check = num_of_days > 0  # assign to a variable
    if num_of_days > 0:
        return f"{num_of_days} days are {num_of_days*calculation_to_units} {name_of_unit}"
    elif num_of_days == 0:
        return "you entered 0, please gimme soemthing else"
    else:
        return "you entered incorrect value you sucker"

""" BEST PRACTICE - block below can be put as a function.
if user_input.isdigit():
    user_input_number=int(user_input)
    calculated_value = days_to_units(int(user_input))
    print(f"{calculated_value}")
else:
    print("your input was not a number")
"""


def validate_and_execute():  # function is used to check if the input is a digit, float or string
    if user_input.isdigit():
        user_input_number = int(user_input)
        calculated_value = days_to_units(int(user_input))
        print(f"{calculated_value}")
    else:
        print("your input was not a number")

user_input = input("hey input some data and i will convert it to hours\n")
validate_and_execute()

#  NESTED IF ... ELSE

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
    if user_input.isdigit():
        user_input_number = int(user_input)
        if user_input_number > 0:
            calculated_value=days_to_units(user_input_number)
            print(calculated_value)
        elif user_input_number == 0:
            print("you entered a 0, enter a positive number")
    else:
        print("your input was not a number")

user_input = input("hey input some data and i will convert it to hours\n")
validate_and_execute()

#  ERROR HANDLING: TRY ... EXCEPT

calculation_to_units = 24
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
            calculated_value = days_to_units(user_input_number)
            print(calculated_value)
        elif user_input_number == 0:
            print("you entered a 0, enter a positive number")
        else:
            print("you entered a negative number, no conversion for you")
    except ValueError:
        print("your input is not a valid number")


user_input = input("hey input some data and i will convert it to hours\n")
validate_and_execute()


#  WHILE LOOPS


calculation_to_units = 24
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
            calculated_value = days_to_units(user_input_number)
            print(calculated_value)
        elif user_input_number == 0:
            print("you entered a 0, enter a positive number")
        else:
            print("you entered a negative number, no conversion for you")
    except ValueError:
        print("your input is not a valid number")

while True:
    user_input = input("hey input some data and i will convert it to hours\n")
    validate_and_execute()


#  WHILE LOOPS - while user does not enter exit, a program will continue to run


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
        user_input_number = int(user_input)
        if user_input_number > 0:
            calculated_value = days_to_units(user_input_number)
            print(calculated_value)
        elif user_input_number == 0:
            print("you entered a 0, enter a positive number")
        else:
            print("you entered a negative number, no conversion for you")
    except ValueError:
        print("your input is not a valid number")


user_input = ""  # variable needs to be initialized before loop starts, otherwise it will complain and stop
while user_input != "exit":
    user_input = input("hey input some data and i will convert it to hours\n")
    validate_and_execute()


#  LIST - DATA TYPE
# using FOR LOOP - it is used to iterate over a sequence / list. then we can execute every element of the list

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


''' on the first run user_input is evaluated but since user has not typed anything we need to declare an  empty variable '''
''' #1 variable needs to be initialized before loop starts, otherwise it will complain and stop. 
In this case we assign an empty variable '''
user_input = ""

''' #2 condition gets evaluated 
as long as "exit" was no typed by a user, the condition is still met and function executed 
'''
while user_input != "exit":

    ''' #3 user is asked for an input '''
    user_input = input("hey input alist as a comma separated list and i will convert it to hours\n")
    print(type(user_input.split(",")))  # shows type of the user input converted
    print(user_input.split(","))
    for num_of_days_element in user_input.split(","):  # user input with commas will be converted to list data type
        validate_and_execute()
