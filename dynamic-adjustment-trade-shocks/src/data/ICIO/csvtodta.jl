"""
Convert raw ICIO data into long format and save as Stata .dta file

In the raw file, row number = 81 region * 45 industry + 3 special (TLS, VA, OUT) = 3648
column number = 81 region * 45 industry (intermediate use) +
    77 region * 45 industry (final use)
There is no need for separate final use for CN1, CN2, MX1, MX2 (they all go to CHN/MEX)
Only CN1/MX1 have domestic final use
Final use for CN2/MX2 are all abroad
e.g., sum(icio[(icio.sorc_iso3.=="CN2").&(icio.dest_iso3.=="CHN").&(icio.dest_ind.>45),:value]) is 0
"""

using CSV
using DataFrames
using ReadStatTables
using PooledArrays

const rawdir = "data/ICIO/240126/ICIO-2016-2020-extended/"
const iciodir = "data/work/ICIO/"

function _split(x, dest="")
    out = split(x, "_", limit=2)
    length(out) == 1 && pushfirst!(out, dest)
    return out
end

function main()
    # Ensure that value labels share the same integer values across files
    seclist = DataFrame(readstat(iciodir*"sectorlist.dta"))
    seclist[!,:codestr] = valuelabels(seclist.code)
    select!(seclist, :codestr, :code)
    for y in [2017]
        dfwide = CSV.read(rawdir*string(y)*".CSV", DataFrame)
        select!(dfwide, Not(:OUT))
        df = stack(dfwide, Not(:V1), variable_name=:dest)
        transform!(df, :dest => ByRow(_split) => [:dest_iso3, :dest_ind])
        transform!(df, [:V1, :dest_iso3] => ByRow(_split) => [:sorc_iso3, :sorc_ind])
        select!(df, [:sorc_ind, :sorc_iso3, :dest_ind, :dest_iso3, :value])
        # This allows using value labels to save file size
        leftjoin!(df, seclist, on=:sorc_ind=>:codestr)
        select!(df, :code=>:sorc_ind, :sorc_iso3, :dest_ind, :dest_iso3, :value)
        leftjoin!(df, seclist, on=:dest_ind=>:codestr)
        select!(df, :sorc_ind, :sorc_iso3, :code=>:dest_ind, :dest_iso3, :value)
        writestat(iciodir*"$y.dta", df)
    end
end

@time main()
