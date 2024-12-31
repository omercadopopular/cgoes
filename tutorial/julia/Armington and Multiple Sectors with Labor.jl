function armington(S::Integer, σ::Integer, L::Array,  A::Matrix, τ::Array, J::Array, β::Array, ν=.05, tol0 = 10e-7)

    w = rand(S)
    w = w ./ w[1]
    diff0 = 10^2
    MatCost = zeros(S,S)

    while diff0 > tol0

        # Rows (i) are origins, destinations (j) are columns
        MatCost = (τ) .^ (1-σ) .* (w ./ A ) .^(1-σ)

        # Trade volumes = Cost(i,j)^(1-σ) * (w(j) * L(j)  / P(j))
        Numerator = MatCost .* w' .* L' # repeat(w', S, 1) .* repeat(L', S, 1) are equal for every destination
        Denominator = sum(MatCost, dims=1) # Prices are also specific to each destination, summing costs from every origin (i) -- dims=1 denote summing across rows

        # Income at origin (i) sums across all destinations (j) -- dims=2 denote summing across columns
        Income = sum(Numerator ./ Denominator, dims=2)

        # Excess demand function
        z = (Income .- w.*L) ./ (w.*L)
      
        # Update guess
        w_n = w .* ( 1 .+ ν .* z )
        
        # See difference between new implied wage and previous guess
        diff0 = maximum( abs.(w - w_n) )

        # Normalize updated guess
        w = w_n ./ w_n[1]
    end

    P = sum(MatCost, dims=1) .^ (1/(1-σ))

    return w, P'
end

function space(S::Integer, σ::Integer, θ::Integer, A::Matrix, τ::Array, L0::Array, T::Array, J::Array, β::Array,  tol0 = 10e-5)

    L = L0
    diff0 = 10^2
    MatU = zeros(S,S)

    while diff0 > tol0

        # Recover initial prices
        w, P = armington(S, σ, L,  A, τ)

        # Rows (i) are origins, destinations (j) are columns
        MatU = T .* ( w ./ P) .^ (θ)

        # Migration flows
        Numerator = MatU .* sum(L) # repeat(w', S, 1) .* repeat(L', S, 1) are equal for every destination
        Denominator = sum(MatU, dims=1) # Denominators are different

        # Vector of new populations
        L_n = sum(Numerator ./ Denominator, dims=2)

        # See change in labor allocation from previous guess
        diff0 = maximum( abs.(L - L_n) )

        # Update guess
        L = 0.8 .* L + 0.2 .* L_n
        
    end

    w, P = armington(S, σ, L,  A, τ)

    return L, w, P

end 

using LinearAlgebra

S = 10
J = 10
β = 
σ = 2
θ = 1
L0 = ones(S)
T = vcat(LinRange(10,1,S)...)
A = repeat(vcat(LinRange(1,10,J)...), 1, S)
τ = ones(S,S).*2 .- I(S)


L, w, P = space(S, σ, θ, A, τ, L0, T, J)

τ = ones(S,S)
L2, w2, P2 = space(S, σ, θ, A, τ, L0, T)

using Plots
using LaTeXStrings

gr(display_type=:inline)
fig = plot(layout=(1,1), size=(400,400))
# Left hand side
plot(A, L .- L2,
     color=:purple,
     linewidth=2,
     legend=false,
     ylabel=latexstring(raw"\Delta L_i"),
     xlabel=latexstring(raw"A_i"),
     sp=1,
     left_margin = 7Plots.mm,
     bottom_margin = 7Plots.mm)
