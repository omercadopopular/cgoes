"""
Construct concordance files across NAICS, HS, ISIC Rev. 4 and model sectors

This file is used for mapping trade and tariff data to model sectors
"""

using CSV
using DataFrames
using ReadStatTables
using XLSX
using FilePathsBase
using FilePathsBase: /

const concdir = p"data/work/concordance"
const iciodir = p"data/work/ICIO"
const iciosecs = [:i32, :i34]

function main()
    # Model sectors
    sec = DataFrame(readstat(iciodir/"sectorlist.dta"))
    sec = sec[sec.isic4.!="",:]
    # Replace the ranges for splitting
    sec[!,:isic4] = String.(sec.isic4)
    sec[38,:isic4] = join(69:75, ", ")
    sec[39,:isic4] = join(77:82, ", ")
    sec[!,:isic4] = split.(sec.isic4, ", ")
    sec = flatten(sec, :isic4)

    # Concordance for matching trade war tariff changes to ICIO model sectors
    # The older concordance files cover fewer NAICS from trade data
    naics = DataFrame(XLSX.readtable(string(concdir/"2012 NAICS_to_ISIC_4.xlsx"),
        "NAICS 12 to ISIC 4 technical", "A:D", header=true, infer_eltypes=true,
        stop_in_empty_row=true))
    rename!(naics, ["naics12", "naics12name", "isic4", "isic4name"])
    naics[!,:naics12] = lpad.(naics.naics12, 6, '0')
    naics[!,:isic4] = lpad.(naics.isic4, 4, '0')
    naics[!,:isic4_2] = SubString.(naics.isic4, Ref(1:2))

    df = innerjoin(naics, sec[!,[:isic4,iciosecs...]], on=:isic4_2=>:isic4)
    sort!(df, :naics12)
    for col in (:naics12name, :isic4name)
        df[!,col] = LabeledArray(df[!,col], Int16)
    end
    select!(df, Not(:isic4_2))

    # Concordance for matching trade data to ICIO model sectors
    hs1toisic3 = CSV.read(concdir/"Concordance_H1_to_I3/JobID-19_Concordance_H1_to_I3.CSV",
        DataFrame, types=[String7, String, String7, String])
    rename!(hs1toisic3, [:hs96, :hs96name, :isic3, :isic3name])
    isic3toisic31 = CSV.read(concdir/"ISIC_Rev_3-ISIC_Rev_3_1_correspondence.txt",
        DataFrame, types=[String7, Int8, String7, Int8, String])
    rename!(isic3toisic31, [:isic3, :partial3, :isic31, :partial31, :isic31name])
    select!(isic3toisic31, Not(:partial3, :partial31))
    isic31toisic4 = CSV.read(concdir/"ISIC31_ISIC4.txt", DataFrame,
        types=[String7, Int8, String7, Int8, String])
    rename!(isic31toisic4, [:isic31, :partial31, :isic4, :partial4, :isic4name])
    select!(isic31toisic4, Not(:partial31, :partial4))

    hs1toicio = innerjoin(hs1toisic3, isic3toisic31, on=:isic3)
    hs1toicio = innerjoin(hs1toicio, isic31toisic4, on=:isic31)
    hs1toicio[!,:isic4_2] = SubString.(hs1toicio.isic4, Ref(1:2))
    hs1toicio = innerjoin(hs1toicio, sec[!,[:isic4,:i32,:i34]], on=:isic4_2=>:isic4)
    select!(hs1toicio, [:hs96, :hs96name, :i32, :i34])
    unique!(hs1toicio)
    hs1toicio[!,:hs96name] = LabeledArray(hs1toicio[!,:hs96name], Int16)
    transform!(groupby(hs1toicio, :hs96), nrow=>:nmatch)
    hs1toicio[!,:nmatch] = Int8.(hs1toicio[!,:nmatch])

    writestat(iciodir*"concordance.dta", df)
    writestat(iciodir/"hs1toicio.dta", hs1toicio)
    return df
end

@time df = main()
