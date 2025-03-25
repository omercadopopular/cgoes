"""
Select model parameters governing trade elasticities by fitting empirical estimates
"""

using DataFrames
using ReadStatTables
using NonlinearSystems
using NonlinearSystems: value_jacobian!!
using MAT
using LinearAlgebra
using FilePathsBase
using FilePathsBase: /

#const estdir = p"data/BLP/output"
const estdir = p"/u/main/tradeadj/lev/output/temp_files"
#const elasdir = p"data/work/elas"
const elasdir = p"/u/main/tradeadj/data/work/elas"

# Objective function given targeted estimates and square-roots of weights
struct Obj
    est::Vector{Float64}
    w::Matrix{Float64}
    elas::Vector{Float64}
end

# The three elements in x are θ, σ and ζ
function (obj::Obj)(F, x)
    θ, σ, ζ = x
    H = length(F)
    # Empirical estimates are tariff-exclusive and hence adjust by 1
    @. obj.elas = -θ * (1 - (1-ζ)^(1:H)) + (1-σ) * (1-ζ)^(1:H) - obj.est - 1
    mul!(F, obj.w, obj.elas)
    return F
end

function main()
    maxiter = 10
    tol = 1e-5
    est = DataFrame(readstat(estdir/"iv_0_baseline_elasticity_ln_trade_val_l1.dta"))
    # Do not use estimates for the year 0
    est = est[est[!,1].!=0,:]
    H = nrow(est)
    # Use estimate variance as initial weight
    # Elements in w are square roots of actual weight matrix
    w = diagm(0=>Float64.(est.se))
    # Cache for computing variance-covariance matrix
    Vca = zeros(H, 3)
    V = zeros(3, 3)
    x0 = [5.0, 0.6, 0.3]
    _F = zeros(H)
    _x = zeros(3)
    # The lower bounds are attained in a couple of cases
    lb = [0.01, 0.1, 0.1]
    ub = [20.0, 10.0, 0.9]
    dres = Dict{String,Any}()

    elas = zeros(H)
    xold = zeros(3)
    dist = zeros(3)
    x = nothing
    W = nothing
    J = nothing

    for i in 1:maxiter
        println("iter = ", i)
        _f! = Obj(est.b, w, elas)
        f = OnceDifferentiable(_f!, _x, _F)
        r = solve(Hybrid{LeastSquares}, f, x0, xtol=1e-3, lower=lb, upper=ub, showtrace=10)
        m, J = value_jacobian!!(f, r.x)
        fill!(w, 0)
        view(w, diagind(w, 0)) .= est.se.^2
        BLAS.ger!(1.0, m, m, w)
        W = cholesky!(w)
        w .= W.U
        dist .= r.x .- xold
        if sum(abs2, dist) < tol
            x = r.x
            break
        end
        xold .= r.x
    end

    # Compute standard error
    ldiv!(Vca, W, J)
    mul!(V, J', Vca)
    V = inv(V)
    se = sqrt.(diag(V))

    tag = "baseline"
    dres["est_"*tag] = est.b .+ 1
    θ, σ, ζ = x
    printstyled(tag, ": θ = $θ σ = $σ ζ = $ζ\n", bold=true, color=:green)
    println()
    dres["fit"*tag] = @.(-θ * (1 - (1-ζ)^(1:H)) + (1-σ) * (1-ζ)^(1:H))
    dres["theta"*tag] = θ
    dres["sigma"*tag] = σ
    dres["zeta"*tag] = ζ
    dres["se"*tag] = se


    H = 3
    # The AD estimates start with pretrends
    est = matread(string(elasdir/"estttbdbaci.mat"))
    b = est["b_base"][7:7+H-1]
    se = est["ub_base"][7:7+H-1] .- est["lb_base"][7:7+H-1]
    w = diagm(0=>Float64.(se))
    _F = zeros(H)
    _x = zeros(3)
    elas = zeros(H)

    x = nothing
    W = nothing
    J = nothing

    for i in 1:maxiter
        println("iter = ", i)
        _f! = Obj(b, w, elas)
        f = OnceDifferentiable(_f!, _x, _F)
        r = solve(Hybrid{LeastSquares}, f, x0, xtol=1e-3, lower=lb, upper=ub, showtrace=10)
        m, J = value_jacobian!!(f, r.x)
        fill!(w, 0)
        view(w, diagind(w, 0)) .= se.^2
        BLAS.ger!(1.0, m, m, w)
        W = cholesky!(w)
        w .= W.U
        dist .= r.x .- xold
        if sum(abs2, dist) < tol
            x = r.x
            break
        end
        xold .= r.x
        x = r.x
    end

    θ, σ, ζ = x
    printstyled(tag, ": θ = $θ σ = $σ ζ = $ζ\n", bold=true, color=:green)
    println()
    dres["fit"*tag] = @.(-θ * (1 - (1-ζ)^(1:H)) + (1-σ) * (1-ζ)^(1:H))

    matwrite(string(elasdir/"elasparam.mat"), dres, compress=true)
    return dres
end

@time dres = main()
