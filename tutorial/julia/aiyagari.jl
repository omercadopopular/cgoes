using Dierckx
using Interpolations
using Distributions
using Optim
using Roots

# parameters
θ  = 1/3                   # capital income share
b      = 0                     # borrowing constraint
β   = 97/100                # subjective discount factor
δ  = 5/100                 # depreciation rate of physical capital
γ  = 3/2                   # inverse elasticity of intertemporal substitution
ρ    = 75/100                  # persistence parameter prodictivity
N      = 2                     # number of possible productivity realizations
y1     = 95/100                # low productivity realization
y2     = 105/100               # high productivity realization

# transition probability matrix (productivity)
π      = zeros(N,N)

# probabilities have to sum up to 1
π[1,1] = ρ                  # transition from state 1 to state 1
π[1,2] = 1-ρ                # transition from state 2 to state 1
π[2,1] = 1-ρ                # transition from state 1 to state 2
π[2,2] = ρ                  # transition from state 2 to state 2

# (inverse) marginal utility functions
up    = c -> c.^(-γ)        # marginal utility of consumption
invup = x -> x.^(-1/γ)      # inverse of marginal utility of consumption

## 2. discretization

# set up asset grid
M  = 250                        # number of asset grid points
aM = 45                         # maximum asset level
A  = LinRange(b,aM,M)          # equally-spaced asset grid from a_1=b to a_M

# set up productivity grid
Y  = [y1 y2]                   # grid for productivity

# vectorize the grid in two dimensions
Amat = repeat(A,1,N)            # values of A change vertically
Ymat = repeat(Y,M,1)           # values of Y change horizontally

## 3. endogenous functions

# current consumption level, cp0(anext,ynext) is the guess
C0 = (cp0,r) -> invup(β*(1+r)* up(cp0)*π' )
                
# current asset level, c0 = C0(cp0(anext,ynext))
A0 = (anext,y,c0,r,w) -> 1/(1+r)*(c0 .+ anext .- y.*w)
                
## 4. solve for the stationary equilibrium

# convergence criterion for consumption iteration
crit = 10^(-6)

# tolerante on r
crit_r0 = 10^(-4)

# parameters of the simulation
# note: 
# it takes quite some simulation periods to get to the stationary
# distribution. Choose a high T >= 10^(-4) once the algorithm is running.
I = 10^(4)             # number of individuals
T = 10^(4)             # number of periods

# choose interval where to search for the stationary interest rate
# note: 
# the staionary distribution is very sensitive to the interst rate. 
# make use of the theoretical result that the stationary rate is slightly 
# below 1/beta-1
r0  = (1-β)/β

function inner_loop(r0,crit,Amat,Ymat,θ,b,δ,ρ,A0,C0)
    # this function
    # (1) solves for the consumption decision rule, given an
    # intereste rate, r0
    # (2) simulates the stationary equilibrium associated with the interest
    # rate, r0
    # (3) (i) returns the residual between the given interes rate r0 and the one
    # implied by the stationary aggregate capital and labor supply.
    # (ii) returns as an optional output the wealth distribution.
    
    # get dimensions of the grid
    M,N = size(Amat)
    
    # get productivity realizations from the first row
    y1 = Ymat[1,1]
    y2 = Ymat[1,2]
    
    # compute the wage according to marginal pricing and a Cobb-Douglas 
    # production function
    w0 = (1-θ)*(θ/(r0+δ))^(θ/(1-θ))
    
    # initial guess on future consumption (consume asset income plus labor
    # income)
    cp0 = r0.*Amat .+ Ymat.*w0
    
    ### iterate on the consumption decision rule
    
    # distance between two successive functions
    # start with a distance above the convergence criterion
    dist    = crit+1
    # maximum iterations (avoids infinite loops)
    maxiter = 10^(4)
    # counter
    
#    print("Inner loop, running... \n")
        
    for iteration in 1:maxiter
    
        # derive current consumption
        c0 = C0(cp0,r0)
        
        # derive current assets
        a0 = A0(Amat,Ymat,c0,r0,w0)
        
        ### update the guess for the consumption decision
        
        # consumption decision rule for a binding borrowing constraint
        # can be solved as a quadratic equation
        cpbind = (1+r0) .* Amat .+ Ymat .* w0 .+ b
        
        # consumption for nonbinding borrowing constraint
        cpnon = zeros(M,N)
        # interpolation conditional on productivity realization
        # instead of extrapolation use the highest value in a0

        cpnon[:,1]  = Spline1D(a0[:,1], c0[:,1], k=1, bc="nearest")(Amat[:,1])
        cpnon[:,2]  = Spline1D(a0[:,2], c0[:,2], k=1, bc="nearest")(Amat[:,2])
        

        # merge the two, separate grid points that induce a binding borrowing constraint
        # for the future asset level (the first observation of the endogenous current asset grid is the 
        # threshold where the borrowing constraint starts binding, for all lower values it will also bind
        # as the future asset holdings are monotonically increasing in the current
        # asset holdings).
        cpnext = zeros(M,N)
        cpnext[:,1] = (Amat[:,1] .> a0[1,1]) .* cpnon[:,1] .+ (Amat[:,1] .<= a0[1,1]) .* cpbind[:,1]
        cpnext[:,2] = (Amat[:,2] .> a0[1,2]) .* cpnon[:,2] .+ (Amat[:,2] .<= a0[1,2]) .* cpbind[:,2]
                
        # distance measure
        dist = sqrt( sum( ((cpnext .- cp0) ./ cp0).^2 ) ) 
        
        # update the guess on the consumption function
        cp0 = cpnext

        # display every 100th iteration
        if (mod(iteration,100) == 1)
            #println("Inner loop, iteration: $iteration, Norm: $dist \n")
        end

        # Break if converged
        if dist < crit
            println("Inner loop converged in $iteration iterations. \n")
            break
        end
    end

    return cp0

end

function outer_loop(r0,crit,I,T,Amat,Ymat,θ,b,δ,ρ,A0,C0)

#    println("Inner loop, done. \n")
        
#    println("Starting simulation... \n")
    c0 = inner_loop(r0,crit,Amat,Ymat,θ,b,δ,ρ,A0,C0)    
    ### simulate the stationary wealth distribution
        
    # initialize variables
    at      = zeros(I,T+1)
    yt      = zeros(I,T)
    ct      = zeros(I,T)
        
    at[:,1] .= 1            # initial asset level
    
    for t in 1:T
        # draw uniform random numbers across individuals
        s = [rand(Uniform(0,1)) for x in 1:I]

        if t > 1   # persistence for t>1
            yt[:,t] = ( (s .<= ρ) .* (yt[:,t-1] .== y1) ) .* y1 .+
                      ( (s .> ρ)  .* (yt[:,t-1] .== y2)) .* y1 .+
                      ( (s .<= ρ) .* (yt[:,t-1] .== y2)) .* y2 .+
                      ( (s .> ρ)  .* (yt[:,t-1] .== y1)) .* y2;
        else     # random allocation in t=0
            yt[:,t] = (s .<= 1/2) .* y1 .+ (s .> 1/2).*y2
        end
        
           # consumption
        ct[:,t] = (yt[:,t] .== y1) .* Spline1D(Amat[:,1], c0[:,1],k=1)(at[:,t]) .+
                  (yt[:,t] .== y2) .* Spline1D(Amat[:,2], c0[:,2],k=1)(at[:,t])
               
        # future assets
        at[:,t+1] = (1+r0) .* at[:,t] .+ yt[:,t] .* w0 .- ct[:,t] 
        
    end

    #println("simulation done... \n")
        
    # compute aggregates from market clearing
    K = mean(mean(at[:,T-100:T]))
    r = θ*(K)^(θ-1)-δ
        
    # compute the distance between the two
    return r, c0, at

end

function stationary_equilibrium(r0,crit,I,T,Amat,Ymat,θ,b,δ,ρ,A0,C0)
    r, c0, at = outer_loop(r0,crit,I,T,Amat,Ymat,θ,b,δ,ρ,A0,C0)
    residual = ((r-r0))/r0
    #println("Residual in this iteration: $residual")
    return residual
end    

lower, upper = 1/β-1 - .01, 1/β-1 + 10^(-4)

lower_res = stationary_equilibrium(lower,crit,I,T,Amat,Ymat,θ,b,δ,ρ,A0,C0)
upper_res = stationary_equilibrium(upper,crit,I,T,Amat,Ymat,θ,b,δ,ρ,A0,C0)

f = r -> stationary_equilibrium(r,crit,I,T,Amat,Ymat,θ,b,δ,ρ,A0,C0)

#results = optimize(f, 1/β-1 - 10^(-4), 1/β-1 + 10^(-4); iterations=20, show_trace=true)
results = find_zero(f, (1/β-1 - .01, 1/β-1 + 10^(-4)); verbose=true, iterations=10)