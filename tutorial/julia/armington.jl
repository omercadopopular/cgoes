function armington(S::Integer, σ::Integer, L::Vector,  A::Vector, τ::Matrix, tol0 = 10e-7)

    w = rand(S)
    w = w ./ ( L .* sum(w .* L) ) 
    diff0 = 10^2
    MatCost = zeros(S,S)

    while diff0 > tol0

        # Rows (i) are origins, destinations (j) are columns
        MatCost = ( (repeat(w,1,S) .* τ) ./ repeat(A,1,S) ) .^ (1-σ)

        # Trade volumes = Cost(i,j)^(1-σ) * (w(j) * L(j)  / P(j)
        Numerator = MatCost .* repeat(w', S, 1) .* repeat(L', S, 1) # repeat(w', S, 1) .* repeat(L', S, 1) are equal for every destination
        Denominator = repeat(sum(MatCost, dims=1), S, 1) # Prices are also specific to each destination, summing costs from every origin (i) -- dims=1 denote summing across rows

        # Income at origin (i) sums across all destinations (j) -- dims=2 denote summing across columns
        Income = sum(Numerator ./ Denominator, dims=2)

        # By market clearing, w_n = Income / L
        w_n = Income ./L

        # See difference between new implied wage and previous guess
        diff0 = maximum( abs.(w - w_n) )
        
        # Update guess
        w = 0.8 .* w + 0.2 .* w_n

        w = w ./ ( L .* sum(w .* L) )
    end

    return w
end

using LinearAlgebra

S = 10
σ = 2
L = ones(S)
A =  vcat(LinRange(1,10,S)...)

τ = ones(S,S).*2 .- I(S).*(2) .+ I(S)
wr = armington(S, σ, L,  A, τ)
MC = ( (repeat(wr,1,S) .* τ) ./ repeat(A,1,S) ) .^ (1-σ)
π = MC ./ repeat( sum(MC, dims=1), S, 1)
P = sum(MC, dims=1)

W = (wr./P') ./ sum(wr./P')
# New \tau
τ2 = ones(S,S)
          
wr2 = armington(S, σ, L,  A, τ2)
MC2 = ( repeat(wr2,1,S) .* τ2 ./ repeat(A,1,S) ) .^ (1-σ)
π2 = MC2 ./ repeat( sum(MC2, dims=1), S, 1)
P2 = sum(MC2, dims=1)

W2 = (wr2./P2') ./ sum(wr2./P2')

using Plots
using LaTeXStrings

gr(display_type=:inline)
fig = plot(layout=(1,2), size=(800,400))
# Left hand side
plot!(A, W,
     color=:black,
     linewidth=2,
     legend=false,
     xlabel=latexstring(raw"A_i"),
     ylabel=latexstring(raw"w_i / P_i"),
     sp=1,
     left_margin = 7Plots.mm,
     bottom_margin = 7Plots.mm)
plot!(A, W2,
     color=:red,
     linewidth=2,
     legend=false,
     sp=1,
     left_margin = 7Plots.mm,
     bottom_margin = 7Plots.mm)
# Right hand side
plot!(A, diag(π),
          color=:black,
          linewidth=2,
          legend=false,
          xlabel=latexstring(raw"A_i"),
          ylabel=latexstring(raw"\pi_{ii}"),
          sp=2,
          left_margin = 7Plots.mm,
          bottom_margin = 7Plots.mm)     
plot!(A, diag(π2),
          color=:red,
          linewidth=2,
          legend=false,
          sp=2,
          left_margin = 7Plots.mm,
          bottom_margin = 7Plots.mm)     

# Calculate wefare in each scenario

# Gains from trade = Welfare under Free Trade / Welfare under Trade Costs
GT = (wr./P') ./ (wr2./P2')
GT = GT ./ GT[end]

# Analytical gains from trade
GT2 = (diag(π)./diag(π2)).^(-1/(1-σ))
GT2 = GT2 ./ GT2[end]
