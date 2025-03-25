using Arrow
using Combinatorics
using ReadStatTables
using DataFrames
using FilePathsBase
using FilePathsBase: /
using MAT
using MethodOfMoments
using StaticArrays
using TypedTables

const work = p"data/work/BLP"
const paneldir = p"data/work/BLP/panels"

include("../BLP/gmm.jl")

function est!(out, hs, ivthres, suf)
    params = (θ=4.0, σ=2.0, ζ=0.2) # Initial values
    hmax = max(maximum(hs), 6)
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
        showtrace=true, maxiter=3)
    ci = confint(r)
    ses = stderror(r)
    push!(out, (file=fname, horzs=join(hs, ", "), ivthres=ivthres,
        theta=coef(r)[1], setheta=ses[1], lbtheta=ci[1][1], ubtheta=ci[2][1],
        sigma=coef(r)[2], sesigma=ses[2], lbsigma=ci[1][2], ubsigma=ci[2][2],
        zeta=coef(r)[3], sezeta=ses[3], lbzeta=ci[1][3], ubzeta=ci[2][3],
        Jstat=Jstat(r)))
end

function main()
    out1 = Table((file=String[], horzs=String[], ivthres=Float64[],
        theta=Float64[], setheta=Float64[], lbtheta=Float64[], ubtheta=Float64[],
        sigma=Float64[], sesigma=Float64[], lbsigma=Float64[], ubsigma=Float64[],
        zeta=Float64[], sezeta=Float64[], lbzeta=Float64[], ubzeta=Float64[],
        Jstat=Float64[]))

    for nhorz in 10:-1:8
        for hs in combinations(1:10, nhorz)
            for (ivthres, suf) in zip((0.0, 0.1, 0.075), ("", "_iv1", "_iv75").*"_fe2")
                println("nhorz = ", nhorz, "  hs = ", hs, "  ivthres = ", ivthres)
                est!(out1, hs, ivthres, suf)
            end
        end
    end
    writestat(work/"panelests8_10.dta", DataFrame(out1))

    #=
    out2 = Table((file=String[], horzs=String[], ivthres=Float64[],
        theta=Float64[], setheta=Float64[], lbtheta=Float64[], ubtheta=Float64[],
        sigma=Float64[], sesigma=Float64[], lbsigma=Float64[], ubsigma=Float64[],
        zeta=Float64[], sezeta=Float64[], lbzeta=Float64[], ubzeta=Float64[],
        Jstat=Float64[]))
    =#

        #=
    for nhorz in 2:3
        for hs in combinations(2:10, nhorz)
            hs1 = (1, hs...)
            for (ivthres, suf) in zip((0.0,), ("",).*"_fe2")
                println("nhorz = ", nhorz, "  hs = ", hs1, "  ivthres = ", ivthres)
                est!(out2, hs1, ivthres, suf)
            end
        end
    end
    writestat(work/"panelests2_3.dta", DataFrame(out2))
    =#
    #=
    for nhorz in 3:3
        for hs in combinations(1:10, nhorz)
            for (ivthres, suf) in zip((0.0,), ("",).*"_fe2")
                println("nhorz = ", nhorz, "  hs = ", hs, "  ivthres = ", ivthres)
                est!(out2, hs, ivthres, suf)
            end
        end
    end
    writestat(work/"panelests3.dta", DataFrame(out2))
    return nothing
    =#
end

@time main()
