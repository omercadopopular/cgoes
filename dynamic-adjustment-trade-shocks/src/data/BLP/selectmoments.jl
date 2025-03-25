using Arrow
using Combinatorics
using ReadStatTables
using DataFrames
using FilePathsBase
using FilePathsBase: /
using MAT
using MethodOfMoments
using MethodOfMoments: chisqccdf
using StaticArrays
using TypedTables

const work = p"data/work/BLP"
const paneldir = p"data/work/BLP/panels"

include("../BLP/gmm.jl")

function est!(out, hs, ivthres, suf)
    params = (θ=4.0, σ=2.0, ζ=0.2) # Initial values
    hmax = max(maximum(hs), 7)
    fname = "panel_h$(hmax)$(suf)"
    df = Table(DataFrame(Arrow.Table(paneldir/"$fname.arrow"), copycols=true))
    iv = :rivbase
    hs = (hs...,)
    tradevars = map(h->Symbol(:rD, h, :trade), hs)
    tariffvars = map(h->Symbol(:rD, h, :tariff), hs)
    g = Moment(df, hs, tradevars, tariffvars, iv)
    dg = DMoment(df, hs, tradevars, tariffvars, iv)
    vce = ClusterVCE(df, :fe_imp_exp_hs4, length(params), length(hs))
    r = fit(IteratedGMM, Hybrid, vce, g, dg, params, length(hs), length(df), initonly=true)
    for nmaxiter in (1, 4)
        # Weight is irrelevant for just-identified cases
        length(hs) == 3 && nmaxiter > 1 && break
        @time fit!(r, showtrace=true, maxiter=nmaxiter)
        ci = confint(r)
        ses = stderror(r)
        mk = nmoment(r) - nparam(r)
        J = Jstat(r)
        pv = mk > 0 ? chisqccdf(mk, J) : NaN
        mmscbic = mk > 0 ? J - mk * log(nobs(r)) : NaN
        push!(out, (file=fname, horzs=join(hs, ", "), ivthres=ivthres,
            nstep=Int16(nmaxiter),
            theta=coef(r)[1], setheta=ses[1], lbtheta=ci[1][1], ubtheta=ci[2][1],
            sigma=coef(r)[2], sesigma=ses[2], lbsigma=ci[1][2], ubsigma=ci[2][2],
            zeta=coef(r)[3], sezeta=ses[3], lbzeta=ci[1][3], ubzeta=ci[2][3],
            Jstat=J, pv=pv, mmscbic=mmscbic))
    end
end

function main()
    out = Table((file=String[], horzs=String[], ivthres=Float64[], nstep=Int16[],
        theta=Float64[], setheta=Float64[], lbtheta=Float64[], ubtheta=Float64[],
        sigma=Float64[], sesigma=Float64[], lbsigma=Float64[], ubsigma=Float64[],
        zeta=Float64[], sezeta=Float64[], lbzeta=Float64[], ubzeta=Float64[],
        Jstat=Float64[], pv=Float64[], mmscbic=Float64[]))

    for nhorz in 10:-1:3
        for hs in combinations(1:10, nhorz)
            hmin, hmax = extrema(hs)
            hmin < 4 && hmax > 6 || continue
            for (ivthres, suf) in zip((0.0, 0.1), ("", "_iv1").*"_fe2")
                println("nhorz = ", nhorz, "  hs = ", hs, "  ivthres = ", ivthres)
                est!(out, hs, ivthres, suf)
            end
        end
    end
    writestat(work/"panelests3_10.dta", DataFrame(out))
    return nothing
end

@time main()
