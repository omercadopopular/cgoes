"""
Time Series Econometrics with Python

Coded by Carlos Góes (andregoes@gmail.com)
Chief-Research Officer, Instituto Mercado Popular

Last updated on March 20th, 2017
"""

# Import all the necessary packages

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.formula.api as smf

# Define length of time series

tlength = 10000

# Define number of non-stationary series to be created

wide = 5

# Generate and plot a stationary series using the built-in command

stationary = np.random.randn(tlength)
plt.plot(stationary)
plt.show()

# Generate and plot a stationary series using a loop

holder = [] 

for i in range(tlength):
    e = np.random.randn()
    holder.append(e)

plt.plot(holder)
plt.show()

# Generate and plot a non-stationary series using a loop

holder = [] 

for i in range(tlength):
    if i == 0:  # generates a random observation for the first period
        b = np.random.randn()
        holder.append(b)    
    else: # adds a new random number to the past observations for subsequent observations
        e = np.random.randn()
        b = holder[i-1] + e
        holder.append(b)

plt.plot(holder, 'green')
plt.show()

# Generalize non-stationary as a program

def nonstationary(n):
    holder = []
    for i in range(n):
        if i == 0:
            b = np.random.randn()
            holder.append(b)    
        else:
            e = np.random.randn()
            b = holder[i-1] + e
            holder.append(b)
    return holder

# Generate n nonstationary series and compare them to a stationary series

matrixns = np.matrix([[0 for x in range(wide)] for y in range(tlength)])

for i in range(wide):
    data = nonstationary(tlength)
    matrixns[:,i] = np.transpose(np.matrix(data))
    plt.plot(matrixns[:,i], 'black')

plt.plot(stationary, 'red')
    
plt.show()

# Generalize stationary series generators as a program

def arstationary(n,alpha):
    if alpha >= 1:
        print("Alpha needs to be smaller than one")
    else:
        holder = []
        for i in range(n):
            if i == 0:
                b = np.random.randn()
                holder.append(b)    
            else:
                e = np.random.randn()
                b = alpha * holder[i-1] + e
                holder.append(b)
        return holder
    
# Generate n nonstationary series and compare them to a stationary series

matrix = np.matrix([[0 for x in range(wide)] for y in range(tlength)])

for i in range(wide):
    data = arstationary(tlength,0.99)
    matrix[:,i] = np.transpose(np.matrix(data))
    plt.plot(matrix[:,i])
    
plt.show()

# Define dataframe from simulated series
df = pd.DataFrame(matrixns, columns=('a','b','c','d','e'))

fig, axs = plt.subplots(1, 3, sharey=True)
df.plot(kind='scatter', x='a', y='b', ax=axs[0], figsize=(10, 6))
df.plot(kind='scatter', x='b', y='c', ax=axs[1])
df.plot(kind='scatter', x='c', y='d', ax=axs[2])
plt.show()

# Fit Linear models
lm1 = smf.ols(formula='a ~ b', data = df).fit()
lm2 = smf.ols(formula='b ~ c', data = df).fit()
lm3 = smf.ols(formula='c ~ d', data = df).fit()
lm4 = smf.ols(formula='d ~ e', data = df).fit()

results = [lm1.summary(), lm2.summary(), lm3.summary(), lm4.summary()]

print(results)