"""
Construct balanced panels and partial out the fixed effects and lag controls from BLP sample
"""

using Arrow
using ReadStatTables
using DataFrames
using FilePathsBase
using FilePathsBase: /
using FixedEffectModels
using MAT

const work = p"data/work/BLP"
const elasdir = p"data/work/elas"

const basehmax = 7

function makesample(hmax::Int, ivthres, insuf)
    df = DataFrame(Arrow.Table(work/"basepanel$(insuf).arrow"), copycols=true)
    for h in hmax:-1:basehmax+1
        tradevar = Symbol(:D, h, :ln_trade_val)
        tariffvar = Symbol(:D, h, :ln_tariff)
        cols = [:year, :panel_id, tradevar, tariffvar]
        @time dfh = DataFrame(readstat(work/"data_horz$(h)$(insuf).dta", usecols=cols))
        df = innerjoin(df, dfh, on=[:panel_id, :year])
    end
    df[!,:nzeroiv] = df.iv_0_baseline.!=0
    ivthres==Inf || (df = df[abs.(df.iv_0_baseline).<ivthres,:])
    return df
end

function within!(df, hrange, fenames)
    println("Partialing out FEs")
    tradevars = (Symbol(:D, h, :ln_trade_val) for h in hrange)
    tariffvars = (Symbol(:D, h, :ln_tariff) for h in hrange)
    ivs = (:iv_0_baseline,)
    lags = (:L1D0ln_trade_val, :L1D0ln_tariff, :L1iv_0_baseline)
    fes = fe.(fenames)
    for var in (tradevars...,tariffvars...,ivs...,lags...)
        r = reg(df, FormulaTerm(Term(var), fes), save=:residuals)
        # missing is already inserted for singletons that are dropped
        # The original column is directly replaced
        df[!,var] = r.residuals
    end
    dropmissing!(df)
    disallowmissing!(df)
    return df
end

function partialout!(df, hrange)
    iv = :iv_0_baseline
    lags = Term(:L1D0ln_trade_val) + Term(:L1D0ln_tariff)
    for h in hrange
        tradevar = Symbol(:D, h, :ln_trade_val)
        tariffvar = Symbol(:D, h, :ln_tariff)
        f1 = FormulaTerm(Term(tradevar), lags)
        f2 = FormulaTerm(Term(tariffvar), lags)
        r1 = reg(df, f1, save=:residuals)
        df[!,Symbol(:rD, h, :trade)] = r1.residuals
        r2 = reg(df, f2, save=:residuals)
        df[!,Symbol(:rD, h, :tariff)] = r2.residuals
    end
    f3 = FormulaTerm(Term(iv), Term(:L1iv_0_baseline))
    r3 = reg(df, f3, save=:residuals)
    df[!,Symbol(:rivbase)] = r3.residuals
    disallowmissing!(df)
end

function makepanel(fenames, hmax::Int, ivthres, ivsuf, insuf)
    println("Making the panel with maximum horizon ", hmax, " and iv thres ", ivthres)
    df = makesample(hmax, ivthres, insuf)
    @time within!(df, 1:hmax, fenames)
    @time partialout!(df, 1:hmax)
    fname = "panel_h$(hmax)$(ivsuf)$(insuf)"
    println("Saving results to ", work/"panels/$fname.arrow")
    #@time writestat(work/"$fname.dta", df)
    Arrow.write(work/"panels/$fname.arrow", df, compress=:lz4)
    return df
end

function main()
    insuf = ""
    fenames2 = (:fe_imp_hs4_yr, :fe_exp_hs4_yr)
    for nhorz in 7:10
        for (iv, suf) in zip((Inf, 0.1), ("", "_iv1").*"_fe2")
            @time makepanel(fenames2, nhorz, iv, suf, insuf)
        end
    end
end

@time main()
