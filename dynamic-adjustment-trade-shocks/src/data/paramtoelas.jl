using Arrow
using DataFrames
using ReadStatTables
using MAT
using LinearAlgebra
using FilePathsBase
using FilePathsBase: /
using StatsFuns
using TypedTables
using MethodOfMoments

const work = p"data/work/BLP"
const paneldir = p"data/work/BLP/panels"
const elasdir = p"data/work/elas"

include("../data/BLP/gmm.jl")


function estnl!(hs, suf, level)
    params = (θ=4.0, σ=2.0, ζ=0.2) # Initial values
    hmax = maximum(hs)
    fname = "panel_h$(hmax)$(suf)"
    df = Table(DataFrame(Arrow.Table(paneldir/"$fname.arrow"), copycols=true))
    iv = :rivbase
    hs = (hs...,)
    tradevars = map(h->Symbol(:rD, h, :trade), hs)
    tariffvars = map(h->Symbol(:rD, h, :tariff), hs)
    g = Moment(df, hs, tradevars, tariffvars, iv)
    dg = DMoment(df, hs, tradevars, tariffvars, iv)
    vce = ClusterVCE(df, :fe_imp_exp_hs4, length(params), length(hs))
    @time r = fit(IteratedGMM, Hybrid, vce, g, dg, params, length(hs), length(df),
        showtrace=true)
    b = toelas(coef(r), 1:10)
    J = jacptoe(coef(r), 1:10)
    V = J * vcov(r) * J'
    se = sqrt.(view(V, diagind(V)))
    scale = norminvcdf(1-(1-level)/2)
    lb = b .- scale .* se
    ub = b .+ scale .* se
    return r, b, se, lb, ub
end

function estlinear!(hs, suf)
    params = [Symbol(:e, h)=>-0.5 for h in hs] # Initial values
    hmax = maximum(hs)
    fname = "panel_h$(hmax)$(suf)"
    df = Table(DataFrame(Arrow.Table(paneldir/"$fname.arrow"), copycols=true))
    iv = :rivbase
    hs = (hs...,)
    tradevars = map(h->Symbol(:rD, h, :trade), hs)
    tariffvars = map(h->Symbol(:rD, h, :tariff), hs)
    g = MomentLinear(df, hs, tradevars, tariffvars, iv)
    dg = DMomentLinear(df, hs, tradevars, tariffvars, iv)
    vce = ClusterVCE(df, :fe_imp_exp_hs4, length(params), length(hs))
    @time r = fit(IteratedGMM, Hybrid, vce, g, dg, params, length(hs), length(df),
        showtrace=true)
    return r
end


function (g::DMoment{S,tradevars,tariffvars,iv})(p, r) where {S,tradevars,tariffvars,iv}
    θ, σ, ζ = p
    data = g.data
    tariff = gettariff(g, r)
    z = getproperty(data, iv)[r]::Float64
    out = hcat((1 .- (1-ζ).^g.hs), (1-ζ).^g.hs,
        θ .* g.hs.*(1-ζ).^(g.hs.-1) .+ (1-σ).*g.hs.*(1-ζ).^(g.hs.-1)) .* tariff .* z
    return out
end

function toelas(p, hs)
    θ, σ, ζ = p
    return -θ .* (1 .- (1-ζ).^hs) .+ (1-σ) .* (1-ζ).^hs
end

function jacptoe(p, hs)
    θ, σ, ζ = p
    J = zeros(length(hs), length(p))
    for h in hs
        J[h,:] .= (-(1 - (1-ζ)^h), -(1-ζ)^h, -θ * h * (1-ζ)^(h-1) - (1-σ) * h * (1-ζ)^(h-1))
    end
    return J
end

function main()
    level = 0.95
    rnl, bnl, senl, lbnl, ubnl = estnl!([1,5,10], "_fe2", level)
    lb, ub = confint(rnl)
    rl = estlinear!(1:10, "_fe2")
    lbl, ubl = confint(rl)
    out = Dict("b"=>coef(rnl), "se"=>stderror(rnl), "lb"=>lb, "ub"=>ub,
        "bnl"=>bnl, "senl"=>senl, "lbnl"=>lbnl, "ubnl"=>ubnl,
        "bl"=>coef(rl), "sel"=>stderror(rl), "lbl"=>lbl, "ubl"=>ubl)
    matwrite(string(elasdir/"gmmelasbase.mat"), out)
    return out
end

@time main()

