# -*- coding: utf-8 -*-

"""
Basic SIR model in Python
Author: Carlos Góes
www.carlosgoes.com
"""

def sirTransition(mu,Beta,Gamma):
    # Import libraries
    import numpy as np
    muv = np.reshape(mu,(3,1))
        
    # Define transition matrix
    AT = np.matrix([ [-Beta*mu[1], 0, 0],
                   [Beta*mu[1],-Gamma,0],
                   [0,Gamma,0] ])
    dmu = np.matmul(AT,muv)
    return dmu

def sirModel(mu0,T,R0,Tinf):
    # Import libraries
    import numpy as np
    
    # Create time and 
    TimeGrid = np.linspace(0,T-1,T)
    Mu = np.zeros((T,3)) # state matrix: columns are S, I, R: [0,1,2]
    Mu[0,:] = mu0
    
    # Define parameters
    Beta = R0 / Tinf
    Gamma = 1 / Tinf
    
    for period in range(0,T-1):
        mu = Mu[period,:]
        dmu = sirTransition(mu, Beta, Gamma)
        Mu[period+1,:] = mu + dmu.T
    
    return Mu, TimeGrid
        
mu0 = [0.995,0.005,0]
T = 100
R0 = 2.5
Tinf = 7

Mu, TimeGrid = sirModel(mu0,T,R0,Tinf)    
   
import matplotlib.pyplot as plt
fig, ax = plt.subplots(1,1, figsize=(10,10))
plt.plot(TimeGrid, Mu[:,0], label='Susceptible', color='Blue')
plt.plot(TimeGrid, Mu[:,1], label='Infected', color='Red')
plt.plot(TimeGrid, Mu[:,2], label='Recovered', color='Black')
plt.legend(loc='upper right')
plt.show()
    
