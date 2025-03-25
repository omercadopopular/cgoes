"""
Compute tariff changes at the model sector level
"""

using DataFrames
using ReadStatTables

const iciodir = "data/work/ICIO/"
const rtpdir = "data/Fajgelbaum/"
const shdir = "data/work/shock/"
const concdir = "data/work/concordance/"

function main()
    census = DataFrame(readstat(concdir*"censusregion.dta"))
    conc = DataFrame(readstat(iciodir*"concordance.dta"))
    select!(conc, :naics12=>:naics, :i34)
    unique!(conc)
    reg = DataFrame(readstat(iciodir*"regionlist.dta"))
    reg = reg[.~(ismissing.(reg.censuscode)),:]
    mw = DataFrame(readstat(shdir*"importweight.dta"))
    mtau = DataFrame(readstat(rtpdir*"tariff_lines_2018_2019/us_import_tariffs.dta"))
    xw = DataFrame(readstat(shdir*"exportweight.dta"))
    xtau = DataFrame(readstat(rtpdir*"tariff_lines_2018_2019/retaliatory_tariffs.dta"))

    # A substantial amount of HS code is mapped to multiple industries
    # Manually reclassify to the primary industry based on initial digits
    amb = unique!(conc[nonunique(conc, :naics), :naics])
    amb2 = sort!(unique(SubString.(amb, Ref(1:2))))
    # amb2 = ["11", "21", "22", "23", "31", "32", "33", "44", "45", "48", "51", "52", "54", "56", "71", "72", "81", "92"]
    # Use 0 as placeholders for NAICS that won't be assigned based on first 2 digits
    ambmap2 = (naics2=amb2, i34a2=[1,2,20,21,0,0,0,22,22,23,25,26,28,29,33,24,34,30])
    # Manufacturing sectors need 3 digits
    amb3 = sort!(filter!(x->x[1]=='3', unique(SubString.(amb, Ref(1:3)))))
    # amb3 = ["311", "312", "313", "314", "315", "321", "322", "323", "324", "325", "326", "327", "331", "332", "333", "334", "335", "336", "337", "339"]
    ambmap3 = (naics3=amb3, i34a3=[3,3,4,4,4,5,6,6,7,0,10,11,12,13,16,14,15,0,19,19])
    # Cheminal products and transportation equipment need 4 digits
    amb4 = sort!(filter!(x->x[1:3]∈("325","336"), unique(SubString.(amb, Ref(1:4)))))
    # amb4 = ["3251", "3252", "3254", "3259", "3362", "3363", "3364", "3365", "3366", "3369"]
    ambmap4 = (naics4=amb4, i34a4=[8,8,9,8,17,17,18,18,18,18])

    for i in 2:4
        conc[!,Symbol(:naics,i)] = SubString.(conc.naics, Ref(1:i))
    end
    leftjoin!(conc, DataFrame(ambmap2), on=:naics2)
    conc[conc.naics.∈(amb,),:i34] .= conc[conc.naics.∈(amb,),:i34a2]
    unique!(conc)
    # Find the remaining ambiguous NAICS sectors
    amb = unique!(conc[refarray(conc.i34).==0,:naics])
    leftjoin!(conc, DataFrame(ambmap3), on=:naics3)
    conc[conc.naics.∈(amb,),:i34] .= conc[conc.naics.∈(amb,),:i34a3]
    unique!(conc)
    # Find the remaining ambiguous NAICS sectors
    amb = unique!(conc[refarray(conc.i34).==0,:naics])
    leftjoin!(conc, DataFrame(ambmap4), on=:naics4)
    conc[conc.naics.∈(amb,),:i34] .= conc[conc.naics.∈(amb,),:i34a4]
    unique!(conc)
    select!(conc, :naics, :i34)
    # Some NAICS code are not in concordance; handle manually
    # unique(mtau18[ismissing.(refarray(mtau18.i34)),:naics])
    # unique(mtau19[ismissing.(refarray(mtau19.i34)),:naics])
    # Those NAICS code starting with 9 are ignored
    append!(conc.naics, ["31181", "31131", "31135", "11211", "1123", "33641"])
    append!(refarray(conc.i34), [3,3,3,1,1,18])

    # Only two rows for Western Sahara (cty_code=7370) are not matched
    leftjoin!(mw, census, on=:cty_code=>:censuscode)
    mw = mw[.~(ismissing.(mw.iso3)),:]
    cols = [:iso3, :hs10, :tariff_max, :tariff_scaled]
    mtau18 = mtau[mtau.year.==2018, cols]
    mtau19 = mtau[mtau.year.==2019, cols]

    # Each NAICS code is mapped to only one sector now
    ms = []
    for df in (mtau18, mtau19)
        # Not all iso3-hs10 pairs in tariff data are in trade data
        df = leftjoin(mw, df, on=[:iso3, :hs10])
        imiss = ismissing.(df.tariff_max)
        df[imiss, :tariff_max] .= 0.0
        df[imiss, :tariff_scaled] .= 0.0
        leftjoin!(df, conc, on=:naics)
        # Only those NAICS code starting with 9 are dropped
        df = df[.~(ismissing.(refarray(df.i34))),:]
        rename!(df, :m_val=>:val)
        df[!,:tau] = (1.0 .+ df.tariff_scaled) .* df.val
        df[!,:taumax] = (1.0 .+ df.tariff_max) .* df.val
        dfi = combine(groupby(df, [:i34,:iso3]),
            [:val,:tau,:taumax].=>sum, renamecols=false)
        leftjoin!(dfi, reg[!,[:iso3,:region]], on=:iso3)
        dfi[ismissing.(refarray(dfi.region)),:iso3] .= "ROW"
        # Aggregate again just for ROW
        dfis = combine(groupby(dfi, [:i34,:iso3]),
            [:val,:tau,:taumax].=>sum, renamecols=false)
        dfis.tau ./= dfis.val
        dfis.taumax ./= dfis.val
        sort!(dfis, [:iso3, :i34])
        push!(ms, dfis)
    end

    leftjoin!(xw, census, on=:cty_code=>:censuscode)
    xw = xw[.~(ismissing.(xw.iso3)),:]
    cols = [:iso3, :hs8, :tariff_max, :tariff_scaled]
    xtau18 = xtau[xtau.year.==2018, cols]
    xtau19 = xtau[xtau.year.==2019, cols]

    xs = []
    for df in (xtau18, xtau19)
        # Not all iso3-hs10 pairs in tariff data are in trade data
        df = leftjoin(xw, df, on=[:iso3, :hs8])
        imiss = ismissing.(df.tariff_max)
        df[imiss, :tariff_max] .= 0.0
        df[imiss, :tariff_scaled] .= 0.0
        leftjoin!(df, conc, on=:naics)
        # Only those NAICS code starting with 9 are dropped
        df = df[.~(ismissing.(refarray(df.i34))),:]
        rename!(df, :x_val=>:val)
        df[!,:tau] = (1.0 .+ df.tariff_scaled) .* df.val
        df[!,:taumax] = (1.0 .+ df.tariff_max) .* df.val
        dfi = combine(groupby(df, [:i34,:iso3]),
            [:val,:tau,:taumax].=>sum, renamecols=false)
        leftjoin!(dfi, reg[!,[:iso3,:region]], on=:iso3)
        dfi[ismissing.(refarray(dfi.region)),:iso3] .= "ROW"
        # Aggregate again just for ROW
        dfis = combine(groupby(dfi, [:i34,:iso3]),
            [:val,:tau,:taumax].=>sum, renamecols=false)
        dfis.tau ./= dfis.val
        dfis.taumax ./= dfis.val
        sort!(dfis, [:iso3, :i34])
        push!(xs, dfis)
    end

    outs = []
    for (dfs, t) in zip((ms, xs), (:m, :x))
        select!(dfs[2], Not(:val))
        df = outerjoin(dfs..., on=[:iso3, :i34], renamecols="18"=>"19")
        rename!(df, Symbol(:val, 18)=>:val)
        push!(outs, df)
        df = ReadStatTable(df, ".dta")
        colmetadata!(df, :i34, "display_width", 55)
        writestat(iciodir*"$(t)tau.dta", df)
    end
    return outs[1], outs[2]
end

@time m, x = main()
