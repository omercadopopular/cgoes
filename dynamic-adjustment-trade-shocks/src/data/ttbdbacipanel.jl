using DataFrames
using ReadStatTables
using FilePathsBase
using FilePathsBase: /

const bacidir = p"data/work/BACI"
const ttbddir = p"data/work/TTBD"
const iciodir = p"data/work/ICIO"

function _maxmiss(x)
    if length(x) == 2
        return ismissing(x[1]) ? x[2] : x[1]
    else
        return x[1]
    end
end

function main()
    adcvdbase = DataFrame(readstat(ttbddir/"adcvdbase.dta"))
    df = adcvdbase[adcvdbase.nrepeat.<2,:]
    @show size(unique(adcvdbase[(adcvdbase.eundest.==0).&(adcvdbase.eunsorc.==0),[:dest,:sorc,:hs]]), 1)

    df = combine(groupby(df, [:dest,:sorc,:hs,:cohort_year,:affirmative]),
        :duty=>sum, :ncase=>first, renamecols=false)
    df = combine(groupby(df, [:dest,:sorc,:hs,:cohort_year]),
        :affirmative=>maximum, :duty=>_maxmiss, :ncase=>_maxmiss, renamecols=false)

    baci96 = DataFrame(readstat(bacidir/"baci96ttbd.dta"))
    df96 = innerjoin(df, baci96, on=[:dest,:sorc,:hs])
    baci02 = DataFrame(readstat(bacidir/"baci02ttbd.dta"))
    df02 = innerjoin(df, baci02, on=[:dest,:sorc,:hs])
    baci07 = DataFrame(readstat(bacidir/"baci07ttbd.dta"))
    df07 = innerjoin(df, baci07, on=[:dest,:sorc,:hs])

    df = vcat(df96[(df96.cohort_year.<=2006).&(df96.year.<=2014),:],
        df02[(2007 .<=df02.cohort_year.<=2011),:],
        df07[(2012 .<=df07.cohort_year),:], source=:baci=>["96","02","12"])
    rename!(df, :cohort_year=>:cohort)

    df[!,:cohort_nt] = copy(df.cohort)
    df[df.affirmative.==0, :cohort_nt] .= -1
    df[df.affirmative.==0, :duty] .= 0
    df.duty .= df.duty ./ 100
    df[!,:lgv] = log.(Float64.(df.v))
    df[!,:rel] = df.year .- df.cohort

    dfrel = df[(df.rel.>=-3).&(df.rel.<=3),:]
    dfrel = combine(groupby(dfrel, [:dest,:sorc,:hs,:cohort]), nrow=>:nrel)
    dfrel = dfrel[dfrel.nrel.==7,:]
    df = innerjoin(df, dfrel, on=[:dest,:sorc,:hs,:cohort])

    transform!(groupby(df, [:dest, :year]), groupindices => :destyear)
    transform!(groupby(df, [:sorc, :year]), groupindices => :sorcyear)
    transform!(groupby(df, [:hs, :year]), groupindices => :hsyear)
    transform!(groupby(df, [:hs, :sorc]), groupindices => :hssorc)
    transform!(groupby(df, [:hs, :dest]), groupindices => :hsdest)
    transform!(groupby(df, [:cohort, :rel]), groupindices => :cohortrel)
    transform!(groupby(df, [:sorc, :dest, :hs]), groupindices => :sorcdesths)

    rel1 = df[df.rel.==-1, [:dest,:sorc,:hs,:cohort,:v]]
    rename!(rel1, :v=>:vlag1)
    df = innerjoin(df, rel1, on=[:dest,:sorc,:hs,:cohort])

    writestat(ttbddir/"bacibase.dta", df)
    return df
end

@time df = main()
