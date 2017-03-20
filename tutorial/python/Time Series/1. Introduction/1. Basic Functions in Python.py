"""
Time Series Econometrics with Python

Coded by Carlos Góes (andregoes@gmail.com)
Chief-Research Officer, Instituto Mercado Popular

Last updated on March 20th, 2017
"""

# BASIC DATA TYPES

# Integers and Floats - numerical operations

# Integers (as expected) do not have decimal points

integer = 20
print(type(integer))

# Floats do

float = 20.5
print(type(float))

# Assingning values to multiple variables

a, b = 1, 2
c, d = 2.5, 10.0

print('a: ',type(a),
      'd: ', type(d))

# The ratio of two integers can be a float

print(a/b, ': ', type(a/b))

# Strings - words operations

string = 'This is a string'
print(type(string))

str1, str2, str3 = 'You can ', 'add strings ', 'to concatenate them'
concatenation = str1 + str2 + str3
print(concatenation)

# Booleans - logical operations (essential for loops)

x = True
print(x)

y = 100 < 10
print(y)

# When combined booleans turn into 1 (True) and 0 (False).
# We can use that for algebra

print('x+y: ',x+y,' x*y: ',x*y)

# TUPLES () and LISTS []
# Lists and tuples store different information you can assign to them

integers = [10, 20, 30]

# The items of a list are stored with indices running from zero to N.

print(integers[0])
print(integers[1])
print(integers[2])

# You can add and remove specific elements to that list

integers.append(40)
print(integers)

integers.remove(10)
print(integers)

# You can reference that specific list and replace it

print(integers)
integers[2] = 50
print(integers)

# And you can apply logical functions that return numbers based on the list
    # but do not change the object itself
    
print(sum(integers))
print(sorted(integers, reverse=True))

# You can also use such functions to assign value to a new object

reverseintegers = sorted(integers, reverse=True)
print(integers,reverseintegers)

# Slice notation

# The general rule is that a[m:n] returns n - m elements, starting at a[m]
# Create a sequential list

holder = [i for i in range(200)]

# List the nth object (it starts in zero)
     
print(holder[100])

holder[100:150] = [999 for i in range(50)]

print(holder[100:150])
print(holder[:101])
print(holder[-100:])

# List with booleans

booleans = [True, True, False, True]

print('Booleans: ',sum(booleans))

# It works with strings too

string = 'my string' + ' ' 'is awesome'

print(string)

print(string[0:4])

print(string[-2:])

# Assessing properties of lists

print(
      len(holder),
      len(string)
      )

# Dictionaries

person1 = {
        'name': 'Milton Friedman',
        'dob': 'July 31, 1911'
        }

print(person1['name'], person1['dob'])
person1['dob'] = 'July 31, 1912'
print(person1['name'], person1['dob'])

person2 = {
        'name': 'Bob Lucas',
        'dob': 'September 15, 1937'
        }

chicago = [person1, person2]

# Sets

set1 = {'john', 'mary', 'jane'}
set2 = {'jack', 'john'}
set3 = {'john', 'mary'}

# You can check if one set is a subset of the other one

set2.issubset(set1) # Set2 is not
set3.issubset(set1) # But set3 is 

set2.intersection(set1) # Although there is an intersection between set2 and set1

# LOOPS

# Try the following:

for professor in chicago:
    print(professor['name'] + ' was born on ' + professor['dob'])
    
# Explanation:
    # The object chicago = [person1, person2]
    # When you type in 'for professor in chicago'
    # Python will loop over all objects in 'chicago' (person1 and person2)
    # and whenever you type in 'professor' in the loop, it will replace it
    # with the objects in 'chicago'.
    
    # The first iteration will report:
    # print(person1['name'] + ' was born on ' + person1['dob'])

    # The second iteration will report:
    # print(person2['name'] + ' was born on ' + person2['dob'])
    
    # Until all objects in chicago are over.
    
# What would happen if we add one more object to chicago?

person3 = {
        'name': 'Ed Prescott',
        'dob': 'December 26, 1940'
        }

chicago.append(person3)

for professor in chicago:
    print(professor['name'] + ' was born on ' + professor['dob'])

    
