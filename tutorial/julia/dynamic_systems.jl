using LinearAlgebra
using Plots
using LaTeXStrings

function expconst(a, b, x0=1, T=10)

    x = zeros(T)
    x[1] = x0
    
    for i in 2:T
        x[i] = a * x[i-1] + b
    end
        
    return x
end

y = expconst(3, -1)

plot(y)

function oscillation(A, Y0=[1,1], T=100)

    dim = floor(Int, length(A) / 2)

    Y = zeros(T, dim)
    Y[1,:] = Y0

    for i in 2:T
        Y[i,:] = (A * Y[i-1,:])
    end

    return Y
end

Z = oscillation(A)
plot(Z) # time series
plot(Z[:,1],Z[:,2]) # phase plane

function expconvergence(a, K, x0=1, T=100)
    x = zeros(T)
    x[1] = x0
    
    for i in 2:T
        x[i] = -( (a - 1)/K * x[i-1] - a ) * x[i-1]
    end

    return x
end

y = expconvergence(1.2, 100)

plot(y)

function phase(A, Y0=[1,1], T=100)

    dim = floor(Int, length(A) / 2)

    Y = zeros(T, dim)
    Y[1,:] = Y0

    for i in 2:T
        Y[i,:] = (A * Y[i-1,:])
    end

    return Y
end

A = [0.5 1; -0.4 1]
Z = oscillation(A)
plot(Z[:,1],Z[:,2]) # phase plane

## cobweb

r = 2.5
K = 10

grid = [i for i in 0:0.1:20]
x = grid
y = grid .+ r .*  grid .* ( 1 .- grid ./ K )

plot(x,y)
plot!(x,x)


############ Continuous time

function expconvergence_cont(r, K, x0=1, steps=1000, delta=0.03)
    x = zeros(steps)
    x[1] = x0
    periods = [t*delta for t in 1:1:steps]
    
    for i in 2:steps
        x[i] = x[i-1] + r * x[i-1] * ( 1 - x[i-1] / K ) * delta
    end

    return x, periods
end

xx, pp = expconvergence_cont(0.5, 100)
xx2, pp2 = expconvergence_cont(0.5, 100, 1, floor(Int, 1000 * 0.03/0.1),0.1)
xx3, pp3 = expconvergence_cont(0.5, 100, 1, floor(Int, 1000 * 0.03/0.25), 0.25)
xx4, pp4 = expconvergence_cont(0.5, 100, 1, floor(Int, 1000 * 0.03/0.5), 0.5)
xx5, pp5 = expconvergence_cont(0.5, 100, 1, floor(Int, 1000 * 0.03/1), 1)

plot(pp,xx)
plot!(pp2,xx2)
plot!(pp3,xx3)
plot!(pp4,xx4)
plot!(pp5,xx5)