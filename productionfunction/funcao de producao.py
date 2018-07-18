# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 16:51:03 2017

@author: CarlosABG
"""

import sympy 
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


path = r"C:\Users\PRADMIN\Desktop\PIB Função de Produção\master_file.xlsx"
w_df = pd.read_excel(path, sheetname='python_input')

####################
# SYMBOLIC ALGEBRA #
####################

# Define variables

y, a, phi, k, t, h, gamma, l, e, alpha, beta  = sympy.symbols('y a phi k t h gamma l e alpha beta')

# Set model, solve for A

eq_y = sympy.Eq(y, a * ((phi*k) ** alpha) * (t ** beta) * ( (h * gamma * l * e ) ** (1-alpha-beta)))
eq_a = sympy.solve(eq_y, a)

##################
# SET PARAMETERS #
##################
    
alpha = 0.4 # Capital Share
beta = 0.05 # Land share
dep = 0.1 # Depreciation rate
s = 0.2 # Savings rate
ca = -0.03 # Current account
tfp_growth = 0.00 # TFP growth in forecast period

# Mean reversion or convergence of other paramenters

parameters = { 'phi': np.mean(w_df.loc[1990:2010]['phi']) ,
               'gamma': np.mean(w_df.loc[1990:2010]['gamma']),
               'e': 12,
               'h': 36,
               't': 3500000,
               'l': 150000000
}

# Convergence factors

convergence = { 'phi': 0.9 ,
               'gamma': 0.9,
               'e': 0.95,
               'h': 0.95,
               't': 0.99,
               'l': 0.95
               }

# Set labels

labels = {
        'h': 'Horas trabalhadas por semana, média',
        'e': 'Escolaridade média, em anos',
        'gamma': 'Taxa de emprego',
        'phi': 'Taxa de utilização de capital',
        't': 'Terra',
        'l': 'Força de Trabalho',
        'a': 'Produtividade Total dos Fatores',
        'y': 'PIB real',
        'k': 'Estoque de Capital',
        'Dy': "Crescimento anual do PIB"
        }

##################
# SOLVE FOR TFP #
##################

# Use solution eq_a to fit TFP

w_df['a'] = (w_df['y'] / 
            (
                ( w_df['phi'] * w_df['k'] ) ** alpha *
                  w_df['t'] ** beta *
                ( w_df['e'] * w_df['gamma'] * w_df['l'] * w_df['e'] ) ** (1-alpha-beta)
            ))

# Do the inverse to make sure your calculation is right

w_df['yz'] = (w_df['a'] *
            (
                ( w_df['phi'] * w_df['k'] ) ** alpha *
                  w_df['t'] ** beta *
                ( w_df['e'] * w_df['gamma'] * w_df['l'] * w_df['e'] ) ** (1-alpha-beta)
            ))
            

'''
# Alternatively, linearize and solve for the log of TFP

w_df['lna'] = ( (1-alpha) * np.log(w_df['y'] / (w_df['gamma'] * w_df['l']) )
                - alpha * np.log(w_df['phi'])
                - alpha * np.log(w_df['k'] / w_df['y'] )
                - beta * np.log(w_df['t'])
                - (1 - alpha - beta) * np.log(w_df['h'] * w_df['e'])
                + beta * np.log(w_df['gamma'] * w_df['l'])
              )      
'''

#######################
# EXOGENOUS FORECASTS #
#######################

# Forecast parameters

last_actual = max(w_df.index)
first = last_actual+1
last = first+30

w_df = w_df.append(pd.DataFrame(columns=w_df.columns, index=range(first,last+1)))

w_df = w_df.loc[1980:]

for key in parameters.keys():
    w_df.loc[last,key] = parameters[key]
    for year in range(first,last+1):
        w_df.loc[year,key] = convergence[key] * w_df.loc[year-1,key] + (1-convergence[key]) * parameters[key]

# Forecasting, TFP growth

for year in range(first, last+1):
     w_df.loc[year,'a'] = (1 + tfp_growth) * w_df.loc[year-1,'a']

########################
# ENDOGENOUS FORECASTS #
########################

# Copy Real GDP

w_df['y_model'] = w_df['y'].copy()

# Set iterative algorithm

def min_k(period, max_iter = 100, tolerance=1e-8):
    n_iter = 1
    
    # In the first iteration, the capital stock will be constant
        # We then solve for Y
    
    if n_iter == 1:
        w_df.loc[period,'k'] = w_df.loc[period-1,'k']
        w_df.loc[period,'y_model'] =    (
                                    w_df.loc[period,'a'] *
                                    (
                                     ( w_df.loc[period,'phi'] *
                                       w_df.loc[period,'k'] )
                                      ** alpha
                                     ) *
                                     ( w_df.loc[period,'t'] ** beta ) *
                                     (
                                      ( w_df.loc[period,'e'] *
                                        w_df.loc[period,'gamma'] *
                                        w_df.loc[period,'l'] *
                                        w_df.loc[period,'e'] )
                                      ** (1-alpha-beta)
                                     )
                                    )
        n_iter += 1
        
    pass
    
    # Starting in the second iteration, we let capital stock
        # depreciate and increase with domestic and foreign
        # savings. We then solve for Y again, based on the
        # new capital stock, and repeat the process again
        # until (a) the percent change in Y for the iteration is
        # smaller than set tolerance; or (b) we reach the
        # maximum number of iterations.   

    while n_iter <= max_iter:
       y_b = w_df.loc[period,'y']
       
       w_df.loc[period,'k'] = ((1-dep) * w_df.loc[period-1,'k'] +
                                (s - ca) * w_df.loc[period,'y_model'])
            
       w_df.loc[period,'y_model'] = (
                                    w_df.loc[period,'a'] *
                                    (
                                     ( w_df.loc[period,'phi'] *
                                       w_df.loc[period,'k'] )
                                      ** alpha
                                     ) *
                                     ( w_df.loc[period,'t'] ** beta ) *
                                     (
                                      ( w_df.loc[period,'e'] *
                                        w_df.loc[period,'gamma'] *
                                        w_df.loc[period,'l'] *
                                        w_df.loc[period,'e'] )
                                      ** (1-alpha-beta)
                                     )
                                )

       n_iter += 1
             
       change = w_df.loc[period,'y'] / y_b - 1
      
       if change < tolerance:
           break
       else:
           continue

# Run the iteration algorithm for each period

for year in range(first, last+1):
     min_k(year)

# To avoid a break, smooth the transition between actual GDP
     # and model forecast

parameter = 0.8
for year in range(first, last+1):
    w_df['y'].loc[year] = parameter * w_df['y'].loc[year-1] + (1-parameter) * w_df['y_model'].loc[year-1]

# Calculate percent change in Real GDP
     
change = [w_df.loc[period,'y'] / w_df.loc[period-1,'y'] - 1 for period in w_df.index[1:]]
w_df['Dy'] = ([np.nan] + change)

###############
# PLOT CHARTS #
###############

for key in labels.keys():
    w_df[key].plot(title=labels[key], color='red', linewidth=2)
    plt.axvspan(first,last, color='gray', alpha=0.25)
    plt.show()      
