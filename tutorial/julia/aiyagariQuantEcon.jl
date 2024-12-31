using LinearAlgebra
using Plots
using LaTeXStrings
using Parameters
using Statistics
using QuantEcon
using Roots: fzero

Household = @with_kw (r = 0.01, # interest rate guess (hh takes as given)
                      w = 1.0, # wage guess (hh takes as given)
                      σ = 1.0, # intertemporal elasticity of substitution 
                      β = 0.96, # discount rate
                      z_chain = MarkovChain([0.75 0.25; 0.25 0.75], [0.1; 1.0]), # probability transition matrix, state values
                      a_min = 1e-10, # lower bound for asset grid
                      a_max = 18.0, # higher bound for asset grid
                      a_size = 200, # steps for asset grid
                      a_vals = range(a_min, a_max, length = a_size), # asset grid
                      z_size = length(z_chain.state_values),
                      n = a_size * z_size,
                      s_vals = gridmake(a_vals, z_chain.state_values),
                      s_i_vals = gridmake(1:a_size, 1:z_size),
                      u = σ == 1 ? x -> log(x) : x -> (x^(1 - σ) - 1) / (1 - σ),
                      R = setup_R!(fill(-Inf, n, a_size), a_vals, s_vals, r, w, u),
                      # -Inf is the utility of dying (0 consumption)
                      Q = setup_Q!(zeros(n, a_size, n), s_i_vals, z_chain))

# R will be an (a_size * z_size, a_size) array.
# that is, a_size * z_size are all possible states, and
# a_size are all possible choices. Notice that we handle only *one* choice here.
# i.e. one row for each combination of a and z values
# and one column for each possible a choice.
# `a_vals` is (a_size,1)
# `s_vals` is (a_size * z_size,2): col 1 is a, col 2 is z
function setup_R!(R, a_vals, s_vals, r, w, u)
	# looping over columns
	# remember that first index varies fastest, so filling column-wise is performant
    for new_a_i in 1:size(R, 2)  # asset choice indices
        a_new = a_vals[new_a_i]  # asset choice values
		# looping over rows
        for s_i in 1:size(R, 1)
            a = s_vals[s_i, 1]  # tease out current state of a
            z = s_vals[s_i, 2]  # current state of z
            c = w * z + (1 + r) * a - a_new  # compute consumption
            if c > 0
                R[s_i, new_a_i] = u(c)
			end # we dont put an `else` because we filled R with -Inf
        end
    end
    return R
end


# Q will be an (z_size * a_size, a_size, z_size * a_size) array.
# At each state (dimension 1)
# given each choice (dim 2)
# what's the probability that you end up in tomorrow's state (a',z') (dim 3)
function setup_Q!(Q, s_i_vals, z_chain)
    for next_s_i in 1:size(Q, 3)  # loop over tomorrow's state indices
        for a_i in 1:size(Q, 2)   # loop over current choice indices
            for s_i in 1:size(Q, 1)  # loop over current state indices
                z_i = s_i_vals[s_i, 2]  # get current index (!) of z
                next_z_i = s_i_vals[next_s_i, 2]  # get index of next z
                next_a_i = s_i_vals[next_s_i, 1]  # get index of next a
                if next_a_i == a_i  # only up in state a' if we also chose a'
                    Q[s_i, a_i, next_s_i] = z_chain.p[z_i, next_z_i]
                end
            end
        end
    end
    return Q
end



h = Household();

am = Household(a_max = 20.0, r = 0.03, w = 0.956)
#fieldnames(typeof(am))

# Use the instance to build a discrete dynamic program
am_ddp = DiscreteDP(am.R, am.Q, am.β)

# Solve using policy function iteration
results = QuantEcon.solve(am_ddp, PFI)	
#fieldnames(typeof(results))

vstar = reshape(results.v,am.a_size,am.z_size)

gr(display_type=:inline)
figv = plot(layout=(1,1), size=(400,400))
plot!(am.a_vals,vstar, legend = :bottomright, label = ["low z" "high z"],
     xlab = "a",ylab = "V")
Plots.savefig(figv, raw"C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\tutorial\julia\vfunction.pdf")


# Simplify names
@unpack z_size, a_size, n, a_vals = am
z_vals = am.z_chain.state_values

# Get all optimal actions across the set of
# a indices with z fixed in each column
a_star = reshape([a_vals[results.sigma[s_i]] for s_i in 1:n], a_size, z_size)

figa = plot(layout=(1,1), size=(400,400))
labels = [L"z = %$(z_vals[1])" L"z = %$(z_vals[2])"]
plot!(a_vals, a_star, label = labels, lw = 2, alpha = 0.6)
plot!(a_vals, a_vals, label = "", color = :black, linestyle = :dash)
plot!(xlabel = "current assets", ylabel = "next period assets", grid = false)
Plots.savefig(figa, raw"C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\tutorial\julia\afunction.pdf")

# Stationary Distribution 

results.mc.p

mm = reshape(stationary_distributions(results.mc)[1], am.a_size,am.z_size)
mmTotal = sum(mm, dims=2)
mmlow = mm[:,1]
mmhigh = mm[:,2]

figd = plot(layout=(1,1), size=(400,400))
plot!(collect(a_vals), mmTotal, 
    xlab = "Assets",
    ylab = "Probability",
    legend = false)
Plots.savefig(figd, raw"C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\tutorial\julia\stationarydist1.pdf")


	# equation (3)
function r_to_w(r,fp)
		@unpack A, θ, δ, N = fp
	    return A * (1 - θ) * (A * θ / (r + δ)) ^ (θ / (1 - θ))
end

	# equation (1)
function rd(K,fp)
		@unpack A, θ, δ, N = fp
	    return A * θ * (N / K) ^ (1 - θ) - δ
end

# capital stock implied by consumer behaviour when interest is r
function next_K_stock(am, r, fp )
	# derive wage	
	w = r_to_w(r,fp)
	@unpack a_vals, s_vals, u = am

	# rebuild R! cash on hand depends on both r and w of course!
	setup_R!(am.R, a_vals, s_vals, r, w, u)

	aiyagari_ddp = DiscreteDP(am.R, am.Q, am.β)

	# Compute the optimal policy
	results = QuantEcon.solve(aiyagari_ddp, PFI)

	# Compute the stationary distribution
	stationary_probs = stationary_distributions(results.mc)[1]

	# Return equation (4): Average steady state capital
	return dot(am.s_vals[:, 1], stationary_probs)  # s_vals[:, 1] are asset values
end

function alleqs(;A = 1,N = 1, θ = 0.33, β = 0.96, δ = 0.05)

        # create a firm parameter
        fp = @with_kw (A = A, N = N, θ = θ, δ = δ)
    
         # Create an instance of Household
        am = Household(β = β, a_max = 20.0)
    
        # Create a grid of r values at which to compute demand and supply of capital
        r_vals = range(0.01, 0.05, length = 40)
    
        # Compute supply of capital
        k_vals = next_K_stock.(Ref(am), r_vals, fp )  # notice the broadcast!
    
        demand = rd.(k_vals,fp)
        
        (k_vals,r_vals,demand)
end

k_vals,r_vals,demand  = alleqs()


fige = plot(layout=(1,1), size=(400,400))
labels =  ["demand for capital" "supply of capital"]
plot!(k_vals, [demand r_vals], label = labels, lw = 2, alpha = 0.6)
plot!(xlabel = "capital", ylabel = "interest rate", xlim = (2, 14), ylim = (0.0, 0.1))
Plots.savefig(fige, raw"C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\tutorial\julia\supplydemand1.pdf")

# capital demand
function Kd(r,fp)
	@unpack A, θ, δ, N = fp
	return N * ((A * θ) / (r + δ))^(1/(1-θ))
end

# create a firm parameter
fp = (A = 1,θ = 0.33,δ = 0.05, N=1)

# Create an instance of Household
am = Household(β = β, a_max = 20.0)

# Create a grid of r values at which to compute demand and supply of capital
r_vals = range(0.01, 0.05, length = 40)

eta = zeros(length(r_vals))
for i in 1:length(r_vals)
    eta[i] = next_K_stock(am, r_vals[i], fp) - Kd(r_vals[i],fp)
end # Calculate excess supply

figf = plot(layout=(1,1), size=(400,400))
plot!(r_vals, eta, lw = 2, alpha = 1, color=:red, legend=false)
hline!([0], color=:black)
plot!(xlabel = "interest rate", ylabel = "excess supply") 
Plots.savefig(figf, raw"C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\tutorial\julia\excesssupply.pdf")

function eqmfind(;A = 1,N = 1, θ = 0.33, β = 0.96, δ = 0.05)

	# create a firm parameter
	fp = @with_kw (A = A, N = N, θ = θ, δ = δ)

 	# Create an instance of Household
	am = Household(β = β, a_max = 20.0)

	# Create a grid of r values at which to compute demand and supply of capital
	r_vals = range(0.005, 0.04, length = 20)

	ex_supply(r) = next_K_stock(am, r, fp ) - Kd(r,fp)

	res = fzero(ex_supply, 0.005,0.04)
	(res, Kd(res,fp))

end

rstar, kstar = eqmfind()

function eqmfind(;A = 1,N = 1, θ = 0.33, β = 0.96, δ = 0.05)

	# create a firm parameter
	fp = @with_kw (A = A, N = N, θ = θ, δ = δ)

 	# Create an instance of Household
	am = Household(β = β, a_max = 20.0)

	# Create a grid of r values at which to compute demand and supply of capital
	r_vals = range(0.005, 0.04, length = 20)

	ex_supply(r) = next_K_stock(am, r, fp) - Kd(r,fp)

	res = fzero(ex_supply, 0.005,0.04)
	(res, Kd(res,fp))

end

rstar, kstar = eqmfind()

# Recalculate final probability
wstar = r_to_w(rstar,fp)

# Restate household
am = Household(a_max = 20.0, r = rstar, w = wstar)

# Use the instance to build a discrete dynamic program
am_ddp = DiscreteDP(am.R, am.Q, am.β)

# Solve using policy function iteration
results = QuantEcon.solve(am_ddp, PFI)	

# Compute the stationary distribution
stationary_probs = stationary_distributions(results.mc)[1]

mm = reshape(stationary_probs, am.a_size,am.z_size)
mmTotal = sum(mm, dims=2)
mmlow = mm[:,1]
mmhigh = mm[:,2]

figg = plot(layout=(1,1), size=(400,400))
plot!(collect(a_vals), mmTotal, 
    xlab = "Assets",
    ylab = "Probability",
    legend = false)
Plots.savefig(figg, raw"C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\tutorial\julia\stationarydist2.pdf")
