"""
Partial out the fixed effects and lag controls with BLP sample
"""

using ReadStatTables
using DataFrames
using FilePathsBase
using FilePathsBase: /
using FixedEffectModels
using MAT

const work = p"data/work/BLP"
const elasdir = p"data/work/elas"

const suf = "_teti2"

function makesample(h::Int, df1)
    @time df = DataFrame(readstat(work/"data_horz$h$suf.dta"))
    df = innerjoin(df, df1, on=[:panel_id, :year])
    sort!(df, [:panel_id, :year])
    return df
end

function within(df, h::Int)
    println("Partialing out FE for horizon $h")
    tradevar = Symbol(:D, h, :ln_trade_val)
    tariffvar = Symbol(:D, h, :ln_tariff)
    iv = :iv_0_baseline
    lags = (:L1D0ln_trade_val, :L1D0ln_tariff, :L1iv_0_baseline)
    fes = (:fe_imp_hs4_yr, :fe_exp_hs4_yr, :fe_imp_exp_hs4)
    # ffe = FormulaTerm(Term.((tradevar,tariffvar,iv,lags...)), fe.(fes))
    # @time rfe = partial_out(df, ffe)
    dffe = df[:,[:panel_id, :year]]
    @time for var in (tradevar,tariffvar,iv,lags...)
        r = reg(df, FormulaTerm(Term(var), fe.(fes)), save=:residuals)
        # missing is already inserted for singletons that are dropped
        dffe[!,var] = r.residuals
    end
    dropmissing!(dffe)
    return dffe
end

function est(df, dffe, h::Int, secondstage::Bool=false)
    tradevar = Symbol(:D, h, :ln_trade_val)
    tariffvar = Symbol(:D, h, :ln_tariff)
    iv = :iv_0_baseline
    f1_0 = FormulaTerm(Term(tariffvar), Term(iv))
    iv1 = Term.((iv,:L1iv_0_baseline))

    f1_1 = FormulaTerm(Term(tariffvar), iv1+Term(:L1D0ln_trade_val))
    f2_1 = FormulaTerm(Term(:L1D0ln_tariff), iv1+Term(:L1D0ln_trade_val))

    dfr = dffe[!,[:panel_id, :year]]
    # No lag control
    @time r1_0 = reg(dffe, f1_0)
    # Get back fitted values
    dfr[!,:pDtariff_0] = predict(r1_0, dffe)

    # With 1-year lag as in baseline BLP
    @time r1_1 = reg(dffe, f1_1)
    dfr[!,:predtariff1_1] = predict(r1_1, dffe)
    @time r2_1 = reg(dffe, f2_1)
    dfr[!,:predtariff2_1] = predict(r2_1, dffe)

    dfr = leftjoin(dfr, df[!,[:panel_id,:year,:fe_imp_exp_hs4]], on=[:panel_id,:year])
    dfr = leftjoin(dfr, dffe[!,[:panel_id,:year,tradevar,:L1D0ln_trade_val]], on=[:panel_id,:year])

    # Partial out the lags including the predicted lag tariff
    f0_1 = FormulaTerm(Term(tradevar), Term(:L1D0ln_trade_val)+Term(:predtariff2_1))
    @time r0_1 = reg(dfr, f0_1, save=:residuals)
    dfr[!,:rDtrade_1] = r0_1.residuals

    ff1_1 = FormulaTerm(Term(:predtariff1_1), Term(:predtariff2_1))
    @time rr1_1 = reg(dfr, ff1_1, save=:residuals)
    dfr[!,:pDtariff_1] .= rr1_1.residuals

    r1s = r1_0, r0_1, r1_1, r2_1, rr1_1

    if secondstage
        # The full regression is run only to compare results with BLP

        #=
        # Make sure that the manual FWL results match the "one-command" results from BLP
        f1_1 = FormulaTerm(Term.((tariffvar, :L1D0ln_tariff)), iv1)
        f2_0 = FormulaTerm(Term(tradevar), f1_0)
        f2_1 = FormulaTerm(Term(tradevar), Term(:L1D0ln_trade_val)+f1_1)
        @time r2_0 = reg(dffe, f2_0, Vcov.cluster(:fe_imp_exp_hs4))
        @time r2_1 = reg(dffe, f2_1, Vcov.cluster(:fe_imp_exp_hs4))
        =#

        # The manual results based on FWL
        f2_0 = FormulaTerm(Term(tradevar), Term(:pDtariff_0))
        @time r2_0 = reg(dfr, f2_0, Vcov.cluster(:fe_imp_exp_hs4))
        f2_1 = FormulaTerm(Term(:rDtrade_1), Term(:pDtariff_1))
        @time r2_1 = reg(dfr, f2_1, Vcov.cluster(:fe_imp_exp_hs4))
        return (dfr, dffe, r1s..., r2_0, r2_1)
    else
        return dfr, dffe, r1s
    end
end

function main()
    blpest = matread(string(elasdir/"elasparam.mat"))["est_blp_baseline"] .- 1
    @time df1 = DataFrame(readstat(work/"data_lag$suf.dta"))
    for h in 0:10
        dfh = makesample(h, df1)
        dffe = within(dfh, h)
        r = est(dfh, dffe, h, true)
        @show r[end].coef[2]
        #abs(r[end].coef[2] - blpest[h+1]) < 1e-4 || error("Mismatch with BLP for horizon $h")
        @time writestat(work/"feresid_horz$h$suf.dta", r[2])
        tradevar = Symbol(:D, h, :ln_trade_val)
        dfr = r[1]
        select!(dfr, :panel_id, :year, tradevar=>:rDtrade_0, :pDtariff_0,
            :rDtrade_1, :pDtariff_1)
        @time writestat(work/"resid_horz$h$suf.dta", dfr)
    end
end

@time main()


