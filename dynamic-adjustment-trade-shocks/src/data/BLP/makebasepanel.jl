"""
Make a balanced panel from BLP sample with the minimum number of horizons to be considered

The output file is in Arrow format to allow the file be read fast
every time an actual estimation sample is being constructed
"""

using Arrow
using ReadStatTables
using DataFrames
using FilePathsBase
using FilePathsBase: /

const work = p"data/work/BLP"
const elasdir = p"data/work/elas"

const hmax = 7
const hmin = 1

# Construct a balanced panel with the smallest number of horizons
function main()
    suf = ""
    df = DataFrame(readstat(work/"data_lag$(suf).dta"))
    fes = (:fe_imp_hs4_yr, :fe_exp_hs4_yr, :fe_imp_exp_hs4)
    for h in hmax:-1:hmin
        tradevar = Symbol(:D, h, :ln_trade_val)
        tariffvar = Symbol(:D, h, :ln_tariff)
        if h == 1
            cols = [:year, :panel_id, tradevar, tariffvar, :iv_0_baseline, fes...]
        else
            cols = [:year, :panel_id, tradevar, tariffvar]
        end
        @time dfh = DataFrame(readstat(work/"data_horz$h$(suf).dta", usecols=cols))
        df = innerjoin(df, dfh, on=[:panel_id, :year])
    end
    sort!(df, [:panel_id, :year])
    @time Arrow.write(work/"basepanel$(suf).arrow", df, compress=:lz4)
    return df
end

@time main()
