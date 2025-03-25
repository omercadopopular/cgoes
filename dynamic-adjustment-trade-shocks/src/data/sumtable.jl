#=
A summary table for tariff changes
=#

using DataFrames
using LaTeXTabulars
using LaTeXTabulars: latex_line
using ReadStatTables
using Printf
using Statistics

const iciodir = "data/work/ICIO/"

function main()
    mfull = DataFrame(readstat(iciodir*"mtau.dta"))
    xfull = DataFrame(readstat(iciodir*"xtau.dta"))
    isd = DataFrame(readstat(iciodir*"paraisd_i34.dta"))

    cols = [:i34, :val, :tau18, :tau19, :taumax19]
    m = mfull[mfull.iso3.=="CHN", cols]
    x = xfull[xfull.iso3.=="CHN", cols]
    # Drop the negligible values with utilities
    x = x[x.i34.!=20, :]
    for df in (m, x)
        df.val .= 100 .* df.val ./ sum(df.val)
        for col in (:tau18, :tau19, :taumax19)
            df[!,col] .= 100 .* (df[!,col] .- 1)
        end
    end
    m[!,:i34] = valuelabels(m.i34)
    mm = isd[(isd.sorc_iso3.∈(("CN1","CN2"),)).&(isd.dest_iso3.=="USA"), :]
    mm = combine(groupby(mm, :sorc_i34), :value=>sum=>:modelshare)
    mm[!,:sorc_i34] = valuelabels(mm.sorc_i34)
    leftjoin!(m, mm, on=:i34=>:sorc_i34)
    m.modelshare .= 100 .* m.modelshare ./ sum(m.modelshare)
    select!(m, :i34, :modelshare, :val, :tau18, :tau19, :taumax19)

    x[!,:i34] = valuelabels(x.i34)
    xm = isd[(isd.sorc_iso3.=="USA").&(isd.dest_iso3.∈(("CN1","CN2"),)), :]
    xm = combine(groupby(xm, :sorc_i34), :value=>sum=>:modelshare)
    xm[!,:sorc_i34] = valuelabels(xm.sorc_i34)
    leftjoin!(x, xm, on=:i34=>:sorc_i34)
    x.modelshare .= 100 .* x.modelshare ./ sum(x.modelshare)
    select!(x, :i34, :modelshare, :val, :tau18, :tau19, :taumax19)

    titleline2 = ["Affected Sector in Model", "\\multicolumn{1}{c}{OECD ICIO}",
        "\\multicolumn{1}{c}{US Census}", "\\multicolumn{1}{c}{2018}",
        "\\multicolumn{1}{c}{2019}", "\\multicolumn{1}{c}{2020--}"]

    lines = [
    ["", "\\multicolumn{2}{c}{2017 Imports in Total (\\%)}",
        "\\multicolumn{3}{c}{Cumulative Increases in Tariffs (\\%)}"],
    CMidRule("lr", 2, 3), CMidRule("lr", 4, 6),
    titleline2,
    CMidRule("lr", 1, 6),
    Matrix(m)]

    open("table/summtau.tex", "w") do io
        for line in lines
            latex_line(io, line)
        end
    end

    lines = [
    ["", "\\multicolumn{2}{c}{2017 Exports in Total (\\%)}",
        "\\multicolumn{3}{c}{Cumulative Increases in Tariffs (\\%)}"],
    CMidRule("lr", 2, 3), CMidRule("lr", 4, 6),
    titleline2,
    CMidRule("lr", 1, 6),
    Matrix(x)]

    open("table/sumxtau.tex", "w") do io
        for line in lines
            latex_line(io, line)
        end
    end

    return m, x
end

main()

