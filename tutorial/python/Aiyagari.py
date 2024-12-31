# -*- coding: utf-8 -*-
"""
Created on Sat Nov 26 19:08:37 2022

@author: Carlos
"""
import numpy as np

# parameters
θ  = 1/3                   # capital income share
b      = 0                     # borrowing constraint
β   = 97/100                # subjective discount factor
δ  = 5/100                 # depreciation rate of physical capital
γ  = 3/2                   # inverse elasticity of intertemporal substitution
ρ    = 5/10                  # persistence parameter prodictivity
N      = 2                     # number of possible productivity realizations
y1     = 95/100                # low productivity realization
y2     = 105/100               # high productivity realization

# transition probability matrix (productivity)
π      = np.zeros([N,N])

# probabilities have to sum up to 1
π[0,0] = ρ                  # transition from state 1 to state 1
π[0,1] = 1-ρ                # transition from state 2 to state 1
π[1,0] = 1-ρ                # transition from state 1 to state 2
π[1,1] = ρ                  # transition from state 2 to state 2

# (inverse) marginal utility functions
up    = lambda c: np.power(c,-γ)        # marginal utility of consumption
invup = lambda x: np.power(x,-1/γ)      # inverse of marginal utility of consumption

## 2. discretization

# set up asset grid
M  = 250                        # number of asset grid points
aM = 45                         # maximum asset level
A  = np.linspace(b,aM,M).T          # equally-spaced asset grid from a_1=b to a_M

# set up productivity grid
Y  = [y1,y2]                   # grid for productivity

# vectorize the grid in two dimensions
Amat = np.matrix(A).T
Amat = np.repeat(Amat,N,1)            # values of A change vertically
Ymat = np.matrix(Y)
Ymat = np.repeat(Ymat,M,0)           # values of Y change horizontally

## 3. endogenous functions

# current consumption level, cp0(anext,ynext) is the guess
C0 = lambda cp0,r: invup(β*(1+r)* np.dot(up(cp0),π.T))
                
# current asset level, c0 = C0(cp0(anext,ynext))
A0 = lambda anext,y,c0,r,w: 1/(1+r)*(c0+anext-y*w)
                
## 4. solve for the stationary equilibrium

# convergence criterion for consumption iteration
crit = 10**(-6)

# parameters of the simulation
# note: 
# it takes quite some simulation periods to get to the stationary
# distribution. Choose a high T >= 10^(-4) once the algorithm is running.
I = 10**(4)             # number of individuals
T = 10**(4)             # number of periods

# choose interval where to search for the stationary interest rate
# note: 
# the staionary distribution is very sensitive to the interst rate. 
# make use of the theoretical result that the stationary rate is slightly 
# below 1/beta-1
r0  = (1-β)/β

def stationary_equilibrium(r0,crit,I,T,Amat,Ymat,θ,b,δ,ρ,φ,A0,C0):
    # this function
    # (1) solves for the consumption decision rule, given an
    # intereste rate, r0
    # (2) simulates the stationary equilibrium associated with the interest
    # rate, r0
    # (3) (i) returns the residual between the given interes rate r0 and the one
    # implied by the stationary aggregate capital and labor supply.
    # (ii) returns as an optional output the wealth distribution.
    
    # get dimensions of the grid
    M,N = np.shape(Amat)
    
    # get productivity realizations from the first row
    y1 = Ymat[0,0]
    y2 = Ymat[0,1]
    
    # compute the wage according to marginal pricing and a Cobb-Douglas 
    # production function
    w0 = (1-θ)*(θ/(r0+δ))**(θ/(1-θ))
    
    # initial guess on future consumption (consume asset income plus labor
    # income from working h=1.
    cp0 = r0*Amat+Ymat*w0
    
    ### iterate on the consumption decision rule
    
    # distance between two successive functions
    # start with a distance above the convergence criterion
    dist    = crit+1
    # maximum iterations (avoids infinite loops)
    maxiter = 10**(3)
    # counter
    
    print('Inner loop, running... \n')
        
    for iteration in range(0,maxiter):
    
        # derive current consumption
        c0 = C0(cp0,r0)
        
        # derive current assets
        a0 = A0(Amat,Ymat,c0,r0,w0)
        
        ### update the guess for the consumption decision
        
        # consumption decision rule for a binding borrowing constraint
        # can be solved as a quadratic equation
        cpbind = (1+r0)*Amat+Ymat*w0+b
        
        # consumption for nonbinding borrowing constraint
        cpnon = np.zeros([M,N])
        # interpolation conditional on productivity realization
        # instead of extrapolation use the highest value in a0
        sq = lambda x: np.squeeze(np.asarray(x)) # this just transforms a matrix into an array for computation
        cpnon[:,0]  = np.interp(sq(Amat[:,0]), sq(a0[:,0]), sq(c0[:,0]))
        cpnon[:,1]  = np.interp(sq(Amat[:,1]), sq(a0[:,1]), sq(c0[:,1]))
        
        #transform to matrix
        cpnon = np.matrix(cpnon)
        
        # merge the two, separate grid points that induce a binding borrowing constraint
        # for the future asset level (the first observation of the endogenous current asset grid is the 
        # threshold where the borrowing constraint starts binding, for all lower values it will also bind
        # as the future asset holdings are monotonically increasing in the current
        # asset holdings).
        cpnext = np.zeros([M,N])
        cpnext[:,0] = (sq(Amat[:,0] > a0[0,0]) * sq(cpnon[:,0])) + (sq(Amat[:,0] <= a0[0,0]) * sq(cpbind[:,0]))
        cpnext[:,1] = (sq(Amat[:,1] > a0[0,1]) * sq(cpnon[:,1])) + (sq(Amat[:,0] <= a0[0,1]) * sq(cpbind[:,1]))
        
        # distance measure
        dist = np.amax(np.power(((cpnext-cp0)/cp0),2))
        
        # update the guess on the consumption function
        cp0 = cpnext

        # display every 100th iteration
        if (iteration%100 == 0) & (iteration > 0):
            print('Inner loop, iteration: {}, Norm: {:.2f} \n'.format(iteration,dist))

        if dist < crit:
            break
        
    print('Inner loop, done. \n')
        
    print('Starting simulation... \n')
        
    ### simulate the stationary wealth distribution
        
    # initialize variables
    at      = np.zeros([I,T+1])
    yt      = np.zeros([I,T])
    ct      = np.zeros([I,T])
        
    at[:,0] = 1            # initial asset level
    
    for t in range(0,T):
        # draw uniform random numbers across individuals
        s = np.random.uniform(0,1,[I,1])

        if t > 0:   # persistence for t>1
            yt[:,t] = sq( (sq(s <= ρ) & sq(yt[:,t-1]==y1)) * y1 +
                        (sq(s <= ρ) & sq(yt[:,t-1]==y2)) * y2 +
                        (sq(s > ρ)  & sq(yt[:,t-1]==y2)) * y1 + 
                        (sq(s > ρ)  & sq(yt[:,t-1]==y1)) * y2
                        )
        else:     # random allocation in t=0
            yt[:,t] = sq( (s <= 1/2)*y1 + (s>1/2)*y2 )
        
           # consumption
        ct[:,t] = sq( sq(yt[:,t]==y1) * np.interp(sq(at[:,0]), sq(Amat[:,0]), sq(c0[:,0]))
                    + sq(yt[:,t]==y2) * np.interp(sq(at[:,1]), sq(Amat[:,1]), sq(c0[:,1]))
                   )
               
        # future assets
        at[:,t+1] = (1+r0)*at[:,t] + yt[:,t]*w0 - ct[:,t] 
        
        
    printf('simulation done... \n')
        
    # compute aggregates from market clearing
    K = np.mean(np.mean(at[:,T-100:T]))
    r = θ*(K)**(θ-1)-δ
        
    # compute the distance between the two
    residual = (r-r0)/r0
    
    return residual, at


