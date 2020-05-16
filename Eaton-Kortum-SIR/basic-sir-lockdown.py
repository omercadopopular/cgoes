# -*- coding: utf-8 -*-

"""
Basic SIR model in Python
Author: Carlos Góes
www.carlosgoes.com
"""

def sirTransition(mu,Beta,Gamma, ReductionEffect):
    # Import libraries
    import numpy as np
    muv = np.reshape(mu,(3,1))
        
    # Define transition matrix
    AT = np.matrix([ [-Beta*(1-ReductionEffect)*mu[1], 0, 0],
                   [Beta*(1-ReductionEffect)*mu[1],-Gamma,0],
                   [0,Gamma,0] ])
    dmu = np.matmul(AT,muv)
    return dmu

def sirModel(mu0,T,R0,Tinf, LockdownStart, LockdownEnd, ReductionEffect):
    # Import libraries
    import numpy as np
    
    # Create time and state matrices
    TimeGrid = np.linspace(0,T-1,T)
    Mu = np.zeros((T,3)) # state matrix: columns are S, I, R: [0,1,2]
    Mu[0,:] = mu0
    
    # Define parameters
    Beta = R0 / Tinf
    Gamma = 1 / Tinf
    Rt = np.zeros((T,1)) # Dynamic transmission rate
    Rt[0,0] = Beta/Gamma
    ReductionEffect0 = 0
    
    for period in range(0,T-1):
        if period in range(LockdownStart, LockdownEnd+1):
            ReductionEffect0 = ReductionEffect
            
        mu = Mu[period,:]
        dmu = sirTransition(mu, Beta, Gamma, ReductionEffect0)
        Mu[period+1,:] = mu + dmu.T
        
        Rt[period+1,0] = Beta*(1-ReductionEffect0)/Gamma
        
        ReductionEffect0 = 0
    
    return Mu, TimeGrid, Rt


# Import packages

import matplotlib.pyplot as plt

# No Lockdown

mu0 = [0.995,0.005,0]
T = 200
R0 = 2.5
Tinf = 7
LockdownStart = 0
LockdownEnd = 0
ReductionEffect = 0

Mu, TimeGrid, Rt = sirModel(mu0,T,R0,Tinf, LockdownStart, LockdownEnd, ReductionEffect)    

fig, ax = plt.subplots(1,1, figsize=(10,10))
plt.axhline(y=max(Mu[:,1]), color='gray', linewidth=.5)
plt.axvline(x=LockdownStart, color='gray', linewidth=.5)
plt.axvline(x=LockdownEnd, color='gray', linewidth=.5)
plt.plot(TimeGrid, Mu[:,0], label='Suscetível', color='Blue', linewidth=2)
plt.plot(TimeGrid, Mu[:,1], label='Infectado', color='Red', linewidth=3)
plt.plot(TimeGrid, Mu[:,2], label='Recuperado', color='Black', linewidth=2)
plt.legend(loc='upper right', fontsize='x-large')
plt.title('Model SIR básico, sem intervenções', fontsize='x-large')
plt.show()    

fig, ax = plt.subplots(1,1, figsize=(10,10))
plt.axvline(x=LockdownStart, color='gray', linewidth=.5)
plt.axvline(x=LockdownEnd, color='gray', linewidth=.5)
plt.plot(TimeGrid, Rt, label='Taxa de Reprodução', color='Red', linewidth=3)
plt.legend(loc='upper right', fontsize='x-large')
plt.title('Model SIR básico, sem intervenções', fontsize='x-large')
plt.show()    

infect_0 = Mu[:,1]

# Lockdown

        
mu0 = [0.995,0.005,0]
T = 200
R0 = 2.5
Tinf = 7
LockdownStart = 10
LockdownEnd = 70
ReductionEffect = 0.6

Mu, TimeGrid, Rt = sirModel(mu0,T,R0,Tinf, LockdownStart, LockdownEnd, ReductionEffect)    
   
import matplotlib.pyplot as plt
fig, ax = plt.subplots(1,1, figsize=(10,10))
plt.axhline(y=max(Mu[:,1]), color='gray', linewidth=.5)
plt.axvline(x=LockdownStart, color='gray', linewidth=.5)
plt.axvline(x=LockdownEnd, color='gray', linewidth=.5)
plt.plot(TimeGrid, Mu[:,0], label='Suscetível', color='Blue', linewidth=2)
plt.plot(TimeGrid, Mu[:,1], label='Infectado', color='Red', linewidth=3)
plt.plot(TimeGrid, Mu[:,2], label='Recuperado', color='Black', linewidth=2)
plt.legend(loc='upper right', fontsize='x-large')
plt.title('Model SIR básico, com intervenção', fontsize='x-large')
plt.show()
    
fig, ax = plt.subplots(1,1, figsize=(10,10))
plt.axvline(x=LockdownStart, color='gray', linewidth=.5)
plt.axvline(x=LockdownEnd, color='gray', linewidth=.5)
plt.plot(TimeGrid, Rt, label='Taxa de Reprodução', color='Red', linewidth=3)
plt.legend(loc='upper right', fontsize='x-large')
plt.title('Model SIR básico, com intervenção', fontsize='x-large')
plt.show()    

infect_1 = Mu[:,1]


# Comparação

import matplotlib.pyplot as plt
fig, ax = plt.subplots(1,1, figsize=(10,10))
plt.axvline(x=LockdownStart, color='gray', linewidth=.5)
plt.axvline(x=LockdownEnd, color='gray', linewidth=.5)
plt.plot(TimeGrid, infect_0, label='Sem intervenção', color='Blue', linewidth=2)
plt.plot(TimeGrid, infect_1, label='Com intervenção', color='Red', linewidth=3)
plt.legend(loc='upper right', fontsize='x-large')
plt.title('Comparação: Infecções', fontsize='x-large')
plt.show()
    