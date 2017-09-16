"""
Estatística Aplicada com Python

Carlos Góes (andregoes@gmail.com)

"""

# TIPOS FUNDAMENTAIS

# Integers and Floats

# Integers são números inteiros - não têm decimais

integer = 20
print(type(integer))

# Floats também são números, mas têm decimais

float = 20.5
print(type(float))

# Você pode assignar valores para várias variáveis de uma vez só

a, b = 1, 2
c, d = 2.5, 10.0

print('a: ',type(a),
      'd: ', type(d))

# A razão de dois integers pode ser um float

print(a/b, ': ', type(a/b))

# Strings são variáveis com palavras

string = 'Esse é um string'
print(type(string))

str1, str2, str3 = 'Você pode ', 'usar a adição ', 'para concatená-los'
concatenation = str1 + str2 + str3
print(concatenation)

# Booleans trazem operações lógicas

x = True
print(x)

y = 100 < 10
print(y)

# Quando combinadas, booleanas se tornam 1 (verdadeiro) ou zero (falso)
# Nós podemos utilizar isso para fazer álgebra com booleanas

print('x+y: ',x+y,' x*y: ',x*y)

# TUPLES () and LISTS []
# Lists e tuples guardam informações que você pode assignar para elas

integers = [10, 20, 30]

# Os elementos das listas são acessados por meio de índices que vão de zero a N-1.

print(integers[0])
print(integers[1])
print(integers[2])

# Você pode adicionar ou remover elementos da lista

integers.append(40)
print(integers)

integers.remove(10)
print(integers)

# Você pode referenciar um elemento específico e modificá-lo

print(integers)
integers[2] = 50
print(integers)

# Você também pode usar a lista para fazer operações lógicas, sem alterá-la
    
print(sum(integers))
print(sorted(integers, reverse=True))

# Ou criar um novo objeto com essas operações lógicas

reverseintegers = sorted(integers, reverse=True)
print(integers,reverseintegers)

# Notação de corte

# Uma regra geral é que a[m:n] imprime n - m elementos, começando em a[m]
# Crie uma lista sequencial

holder = [i for i in range(200)]

# Imprima o elemento n
     
print(holder[100])

holder[100:150] = [999 for i in range(50)]

print(holder[100:150])
print(holder[:101])
print(holder[-100:])

# Lista com booleanas

booleans = [True, True, False, True]

print('Booleans: ',sum(booleans))

# Também funciona com strings

string = 'my string' + ' ' 'is awesome'

print(string)

print(string[0:4])

print(string[-2:])

# Compreendendo as propriedades das listas

print(
      len(holder),
      len(string)
      )

# Dicionários

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

# Conjuntos

set1 = {'john', 'mary', 'jane'}
set2 = {'jack', 'john'}
set3 = {'john', 'mary'}

# Você pode checar se um é um subconjunto de outro

set2.issubset(set1) # Set2 is not
set3.issubset(set1) # But set3 is 

set2.intersection(set1) # Although there is an intersection between set2 and set1

# LOOPS

# Tente fazer o seguinte:

for professor in chicago:
    print(professor['name'] + ' nasceu em ' + professor['dob'])
    
# Explicação:
    # O objeto chicago = [person1, person2]
    # Quando você escreve 'for professor in chicago'
    # Python vai iterar sobre todos os elementos em 'chicago' (person1 e person2)
    # e sempre que você digitar 'professor' dentro do loop, ele vai substituir
    # pelos elementos em 'chicago'.
    
    # A primeira iteração vai trazer:
    # print(person1['name'] + ' nasceu eu ' + person1['dob'])

    # A segunda iteração vai trazer:
    # print(person2['name'] + ' nasceu eu ' + person2['dob'])
    
    # Até que todos os objetos em Chicago estiverem finalizados.
    
# O que aconteceria se nós ajuntássemos mais um elemento em Chicago?

person3 = {
        'name': 'Ed Prescott',
        'dob': 'December 26, 1940'
        }

chicago.append(person3)

for professor in chicago:
    print(professor['name'] + ' was born on ' + professor['dob'])

    
