using LinearAlgebra, Statistics, Plots, LaTeXStrings

n = 100
ep = randn(n)

# Arrays
for i ∈ eachindex(ep)
    println(i)
end

# functions

function generatedata(n)
    ep = randn(n) # use built in function
    return ep .^ 2
end
data = generatedata(5)
println(data)

f(x) = x.^2
generatedata(n) = f.((randn(n)))
data = generatedata(5)
println(data)

generatedata(n, gen) = gen.(randn(n)) # broadcasts on gen
f(x) = x^2 # simple square function
data = generatedata(n, f) # applies f
println(data)
plot(1:1:n,data)

# direct solution with broadcasting, and small user-defined function
n = 100
f(x) = x^2

x = randn(n)
plot(f.(x), label = L"x^2")
plot!(x, label = L"x") # layer on the same plot

# Histogram
using Distributions

function plothistogram(distribution, n)
    ep = rand(distribution, n)  # n draws from distribution
    histogram(ep)
end

lp = Laplace()
normal = Normal()
plothistogram(normal, 100000)

# a fixed point alogrithm

# poor style
p = 1.0 # note 1.0 rather than 1
beta = 0.9
maxiter = 1000
tolerance = 1.0E-8
v_iv = 0.8 # initial condition

# setup the algorithm
v_old = v_iv
normdiff = Inf
iter = 1
for i in 1:maxiter
    v_new = p + beta * v_old # the f(v) map
    normdiff = norm(v_new - v_old)
    if normdiff < tolerance # check convergence
        iter = i
        break # converged, exit loop
    end
    # replace and continue
    v_old = v_new
end
println("Fixed point = $v_old
  |f(x) - x| = $normdiff in $iter iterations")

# good style
function fixedpointmap(f, iv; tolerance = 1E-7, maxiter = 1000)
    # setup the algorithm
    x_old = iv
    normdiff = Inf
    iter = 1
    while normdiff > tolerance && iter <= maxiter
        x_new = f(x_old) # use the passed in map
        normdiff = norm(x_new - x_old)
        x_old = x_new
        iter = iter + 1
    end
    return (; value = x_old, normdiff, iter) # A named tuple
end

# define a map and parameters
p = 1.0
beta = 0.9
f(v) = p .+ beta .* v # note that p and beta are used in the function!

sol = fixedpointmap(f, 0.8; tolerance = eps()) # don't need to pass
println("Fixed point = $(sol.value)
  |f(x) - x| = $(sol.normdiff) in $(sol.iter) iterations")


r = 2.0
g(x) = r .* x - r.* x.^2

sol = fixedpointmap(g, 0.8) # the ; is optional but generally good style
println("Fixed point = $(sol.value)
  |g(x) - g| = $(sol.normdiff) in $(sol.iter) iterations")


# best style
using NLsolve

# best style (note NLSolve aonly accepts vector valued function)
p = 1.0
beta = 0.9
iv = [0.8] 
sol = fixedpoint(v -> p .+ beta * v, iv)
fnorm = norm(f(sol.zero) - sol.zero)
println("Fixed point = $(sol.zero)
  |f(x) - x| = $fnorm  in $(sol.iterations) iterations
  converged = $(sol.f_converged)")


  # best style (note NLSolve aonly accepts vector valued function)

  p = 1.0
beta = 0.9
iv = [0.8] 
sol = fixedpoint(v -> p .+ beta * v, iv)
fnorm = norm(f(sol.zero) - sol.zero)
println("Fixed point = $(sol.zero)
  |f(x) - x| = $fnorm  in $(sol.iterations) iterations
  converged = $(sol.f_converged)")

# use arbitrary precision floating points
p = 1.0
beta = 0.9
iv = [BigFloat(0.8)] # higher precision

# otherwise identical
sol = fixedpoint(v -> p .+ beta * v, iv)
normdiff = norm(f(sol.zero) - sol.zero)
println("Fixed point = $(sol.zero)
  |f(x) - x| = $normdiff in $(sol.iterations) iterations")

  # Multivariate Fixed Point Maps

p = [1.0, 2.0]
beta = 0.9
iv = [0.8, 2.0]
f(v) = p .+ beta * v # note that p and beta are used in the function!

sol = fixedpointmap(f, iv; tolerance = 1.0E-8)
println("Fixed point = $(sol.value)
  |f(x) - x| = $(sol.normdiff) in $(sol.iter) iterations")

# using NLsolve

p = [1.0, 2.0, 0.1]
beta = 0.9
iv = [0.8, 2.0, 51.0]
f(v) = p .+ beta * v

sol = fixedpoint(v -> p .+ beta * v, iv)
normdiff = norm(f(sol.zero) - sol.zero)
println("Fixed point = $(sol.zero)
  |f(x) - x| = $normdiff in $(sol.iterations) iterations")

"""
  2.4.1. Exercise 1
Recall that 
 is read as “
 factorial” and defined as 
.

In Julia you can compute this value with factorial(n).

Write your own version of this function, called factorial2, using a for loop.
"""

# built-in:
factorial(10)

function factorial2(n)
    result = 1
    for i in 2:n
        result = result * i
    end

    return result
end
factorial2(10)

# exercise 2

function binomial_rv(n, p)
    return rand(n) .> p
end

binomial_rv(50, .5)

# exercise 3

function estimate_pi(n)
    count = 0
    for _ in 1:n
        x = rand()
        y = rand()
        if x^2 + y^2 <= 1
            count += 1
        end
    end
    return 4*count / n
end

n = 10^6
pi_estimate = estimate_pi(n)
println("Estimated π: ", pi_estimate)

#exercise 4

function binomial_rv(n, p)
    return rand(n) .> p
end

function payoff(n, cut)
    sample = binomial_rv(n,.5)
    counter = 0
    for i in 1:n
        if sample[i] == 1
            counter += 1
            if counter >= cut
                return "Pay"
            end
        else
            counter = 0  # Reset counter if a tail appears
        end
    end
    return "Don't pay"
end

n = 15
result = payoff(n, 5)
println("Result: ", result)


# exercise 5

function ar(n,alpha, iv=0.5, sigma=1)
    x = zeros(n)
    x[1] = iv

    for i in 2:n
        x[i] = alpha .* x[i-1] + sigma .* rand(Normal())  
    end

    return x
end

# exercise 7

function Ta(tmax,alpha,sigma,iv=1)

    x = zeros(tmax)
    x[1] = iv

    for t in 2:tmax

        if t == tmax
            x[t] = 0
            return t
        end

        x[t] = alpha .* x[t-1] + sigma .* rand(Normal())
        if x[t] < 0
            return t
        end
    end
end

m1 = mean([Ta(200, 0.8, 0.2) for i in 1:100])
m2 = mean([Ta(200, 1, 0.2) for i in 1:100]) 
m3 = mean([Ta(200, 1.2, 0.2) for i in 1:100])
println("$m1, $m2, $m3")

# exercise 8 (newtons method)

function newton(f, f_prime, x_0; tolerance=eps(), maxiter=3000)
    x_old = x_0
    iter = 0
    normdiff = Inf
    
    while iter < maxiter
        x_new = x_old - f(x_old) / f_prime(x_old)  # Newton's update step
        normdiff = norm(x_new - x_old)              # Use abs() for scalars
        
        if normdiff < tolerance
            break
        end
        
        x_old = x_new
        iter += 1
    end
    
    return (; value = x_old, normdiff, iter)
end

# Test with f(x) = (x - 1)^3
f(x) = (x - 1)^3
f_prime(x) = 3 * (x - 1)^2

result = newton(f, f_prime, 0.5)
println("Root: ", result.value)
println("Difference: ", result.normdiff)
println("Iterations: ", result.iter)

# Exercise 8(b)

using ForwardDiff

# Test with f(x) = (x - 1)^3
D(f) = x -> ForwardDiff.derivative(f, x)
f(x) = (x - 1)^3
ff_prime = D(f)

result = newton(f, ff_prime, 0.5)
println("Root: ", result.value)
println("Difference: ", result.normdiff)
println("Iterations: ", result.iter)
