# A short-hand for typing
const A{N} = Array{Float64,N}

"""
For each concrete type of `AbstractTechnology`,
there should be a method of `set_cost!` that
computes the changes in unit cost `qhat` given price changes.
"""
abstract type AbstractTechnology end

struct CobbDouglasTech <: AbstractTechnology end

abstract type SourcingCriterion end

struct MinCurrentCost <: SourcingCriterion end

mutable struct MaxPresentValue{CΨ} <: SourcingCriterion
    "Number of beginning periods used for assessing convergence in Ψ"
    TΨ::Int
    "Tolerance of convergence for solving EPV of profits"
    tolΨ::Float64
    "Maximum number of iterations for EPV of profits"
    maxiterΨ::Int
    "Factor for solver"
    betaΨ::Float64
    "Number of past solutions used for solver"
    histΨ::Int
    "Print more solver status when solving EPV of profits"
    verboseΨ::Bool
    "Solver cache for EPV of profits"
    solvercacheΨ::CΨ
    "Discount rate for traders"
    βf::A{1}
    "Sum in the numerator of Ψ"
    Ψsum1::A{4}
    "Expected present values of profits as ratios over current level"
    Ψ::A{4}
    "Probability of choosing a sourcing country when adjusting"
    υ::A{4}
    "Sum of probability of choosing a sourcing country"
    Υ::A{3}
    "Aggregate shares of varieties among sourcing countries among all legacy varieties"
    υagg::A{4}
    "Aggregate profits for traders in destination countries"
    Π::A{2}
    "Initial steady-state profits in each country"
    Πss::A{1}
    "Log changes in profits relative to initial level"
    dΠ::A{2}
    "Residuals from initial steady state that allow matching IO data"
    Fadj::A{2}
end

function MaxPresentValue(;
    S = 32,
    N = 79,
    T = 30,
    TΨ = 20,
    tolΨ = 1e-5,
    maxiterΨ = 100,
    betaΨ = 0.6,
    histΨ = 1,
    verboseΨ = true)

    solvercacheΨ = initAndersonCache(histΨ, S, N, N, TΨ)
    βf = fill(0.95, S)
    Ψsum1 = zeros(S, N, N, T)
    Ψ = ones(S, N, N, T)
    υ = zeros(S, N, N, T)
    Υ = zeros(S, N, T)
    υagg = zeros(S, N, N, T)
    Π = ones(N, T)
    Πss = ones(N)
    dΠ = ones(N, T)
    Fadj = zeros(S, N)
    return MaxPresentValue{typeof(solvercacheΨ)}(
        TΨ, tolΨ, maxiterΨ, betaΨ, histΨ, verboseΨ, solvercacheΨ,
        βf, Ψsum1, Ψ, υ, Υ, υagg, Π, Πss, dΠ, Fadj)
end

abstract type IOTrade end

struct WithIO <: IOTrade end

struct NoIO <: IOTrade end

# Define a type for parameters and containers
# All intermediate steps reuse the same arrays whenever possible
# See also the constructor below
mutable struct Problem{PT<:AbstractTechnology, SC<:SourcingCriterion, IT<:IOTrade,
        CP, CP0, CX}
    # Dimensions
    "Number of production sectors"
    S::Int
    "Number of production regions (factor market boundaries may be different)"
    N::Int
    "Number of time periods"
    T::Int
    "Number of periods in history (time to last adjustment)"
    K::Int

    # Solver parameters
    "Tolerance of convergence for solving price changes"
    tolw::Float64
    "Maximum number of iterations for price changes"
    maxiterw::Int
    "Maximum number of iteration for price changes in round 1"
    iterw1::Int
    "Factor for solver in round 1"
    betaw1::Float64
    "Number of past solutions used for solver"
    histw1::Int
    "Maximum number of iteration for price changes in round 2"
    iterw2::Int
    "Factor for solver in round 2"
    betaw2::Float64
    "Factor for solver in round 3"
    betaw3::Float64
    "Print more solver status when solving factor prices"
    verbosew::Bool
    "Tolerance of convergence for solving total expenditure"
    tolX::Float64
    "Maximum number of iterations for total expenditure"
    maxiterX::Int
    "Factor for solver"
    betaX::Float64
    "Number of past solutions used for solver"
    histX::Int
    "Print more solver status when solving total expenditure"
    verboseX::Bool
    "Solver cache for factor income"
    solvercachew::CP
    "Solver cache for factor income"
    solvercachew0::CP0
    "Solver cache for total expenditure"
    solvercacheX::CX

    # Model parameters
    "Elasticity of substitution across varieties"
    σ::A{1}
    "Long-run trade elasticity from Frechet"
    θ::A{1}
    "Probability of adjusting trade relations in a period"
    ζ::A{1}
    "Share of producers by the time since last adjustment"
    μ::A{2}
    "Household expenditure shares across sectors"
    η::A{2}
    "Government expenditure shares across sectors"
    ηG::A{2}
    "Expenditure share of valued added"
    α::A{2}
    "Expenditure share of intermediate inputs (in total cost)"
    αM::A{3}
    "Productiono technology"
    pt::PT

    # Variables
    "Gross level of tariffs in each period (1 means no tariff)"
    τ::A{4}
    "Shocks as ratios over last-period level"
    τhat::A{4}
    "Changes in production cost as ratios over last-period level (excluding shocks)"
    qhat::A{3}
    "Changes in production cost as ratios over the level at the time of last adjustment;
        excluding the contemporaneous change in factor price"
    qhat_tk::A{4}
    "Exogenous trade deficits"
    D::A{2}
    "Steady-state labor income"
    wLss::A{1}
    "Labor income by period"
    wL::A{2}
    "Labor income reassign rule for aggregation (target indices of wL)"
    wLshift::Vector{Int}
    "Steady-state trade shares"
    λ0ss::A{3}
    "Trade shares within varieties with trade relations adjusted k periods ago"
    λk::A{5}
    "Numerator for λk (before divided by λksum)"
    λk_el::A{4}
    "Numerator for λ0 (before divided by λksum); levels are ratios over initial steady state"
    λ0_el::A{4}
    "Sum of λk across source regions"
    λksum::A{3}
    "Elements for aggregate trade shares"
    Qs_el::A{5}
    "Aggregate trade shares across k"
    λ::A{4}
    "Intermediate results for computing government revenue from tariffs"
    λτsum::A{2}
    "Elements for aggregate price indices"
    P_el::A{4}
    "Sum of P_el; level of price indices relative to steady state before taking the exponent"
    Ps::A{3}
    "Changes in Ps as ratios over the last period"
    Pshat::A{2}
    "Country-level total expenditure"
    income::A{1}
    "Expenditure on country-sector specific final use (stacked)"
    F::A{2}
    "Steady-state total expenditure on country-sector specific goods"
    Xss::A{2}
    "Total expenditure on country-sector specific goods (stacked)"
    X::A{2}
    "A matrix that maps total expenditure to sum of intermediate use and government spending"
    ΩG_I::A{2}
    "Total production of country-sector specific goods"
    Y::A{3}
    "Initial values for change in factor prices for the solver"
    winit::A{2}
    "Changes in factor prices as ratios over the last period"
    what::A{2}
    "Price index for each sector relative to the steady state in log"
    P::A{3}
    "Aggregate price index for final use bundle relative to the steady state in log"
    Pf::A{2}
    "Cumulative changes of nominal wages (what) in log"
    W::A{2}
    "Real wages relative to the steady state in log"
    w::A{2}
    realincomess::A{1}
    "Change in total wage income and possibly profit adjusted by aggregate price index relative to initial steady state in log"
    drealincome::A{2}
    "Additional parameters and variables depending on sourcing criterion"
    sc::SC
end

# Values are all placeholders
function Problem(;
    S = 32,
    N = 79,
    T = 30,
    K = T+1,
    tolw = 1e-9,
    maxiterw = 100,
    iterw1 = 50,
    betaw1 = 0.9,
    histw1 = 4,
    iterw2 = 50,
    betaw2 = 0.5,
    betaw3 = 0.5,
    verbosew = false,
    tolX = 1e-9,
    maxiterX = 100,
    betaX = 0.9,
    histX = 3,
    verboseX = false,
    sc = MinCurrentCost(),
    it = WithIO()
    )

    if it == WithIO()
        solvercachew = initAndersonCache(histw1, S+1, N)
        solvercachew0 = initAndersonCache(0, S+1, N)
        solvercacheX = initAndersonCache(histX, S*N)
    else
        solvercachew = initAndersonCache(histw1, 1, N-1)
        solvercachew0 = initAndersonCache(0, 1, N-1)
        solvercacheX = nothing
    end

    σ = fill(1.14, S)
    θ = fill(3.16, S)
    ζ = fill(0.09, S)
    μ = zeros(K, S)
    η = fill(1/S, S, N)
    ηG = zeros(S, N)
    α = zeros(S, N)
    αM = zeros(S, S, N)
    pt = CobbDouglasTech()

    τ = ones(S, N, N, T)
    τhat = ones(S, N, N, T)
    qhat = ones(S, N, T)
    qhat_tk = ones(K, S, N, N)
    D = zeros(N, T)
    wLss = ones(N)
    wL = ones(N, T)
    wLshift = collect(1:N)

    λ0ss = fill(1/N, S, N, N)
    λk = fill(1/N, K, S, N, N, T)
    λk_el = fill(1/N, K, S, N, N)
    λ0_el = fill(1/N, S, N, N, T)
    λksum = fill(1/N, K, S, N)
    Qs_el = ones(K, S, N, N, T)
    λ  = fill(1/N, S, N, N, T)
    λτsum = zeros(S, N)
    P_el = ones(K, S, N, T)
    Ps = ones(S, N, T)
    Pshat = ones(S, N)
    income = ones(N)
    F = zeros(S * N, T)
    Xss = zeros(S, N)
    X = zeros(S * N, T)
    ΩG_I = zeros(S * N, S * N)
    Y = zeros(S, N, T)
    winit = it == WithIO() ? ones(S+1, N) : ones(1, N-1)
    what = ones(N, T)

    P = ones(S, N, T)
    Pf = ones(N, T)
    W = ones(N, T)
    w = ones(N, T)
    realincomess = ones(N)
    drealincome = ones(N, T)

    return Problem{typeof(pt), typeof(sc), typeof(it), typeof(solvercachew), typeof(solvercachew0),
        typeof(solvercacheX)}(S, N, T, K,
        tolw, maxiterw, iterw1, betaw1, histw1, iterw2, betaw2, betaw3, verbosew,
        tolX, maxiterX, betaX, histX, verboseX,
        solvercachew, solvercachew0, solvercacheX,
        σ, θ, ζ, μ, η, ηG, α, αM, pt,
        τ, τhat, qhat, qhat_tk, D, wLss, wL, wLshift,
        λ0ss, λk, λk_el, λ0_el, λksum, Qs_el, λ, λτsum, P_el, Ps, Pshat,
        income, F, Xss, X, ΩG_I, Y, winit, what, P, Pf, W, w, realincomess, drealincome, sc)
end

# Pretty-printing
show(io::IO, p::Problem) =
    print(io, "Parameters and variables for a problem")

