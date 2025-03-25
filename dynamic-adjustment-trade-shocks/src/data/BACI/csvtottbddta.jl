"""
Collect raw BACI data that are relevant to the TTBD estimation
"""

using CSV
using DataFrames
using ReadStatTables
using FilePathsBase
using FilePathsBase: /

const rawdir = p"data/BACI/download/240525"
const bacidir = p"data/work/BACI"
const ttbddir = p"data/work/TTBD"
const maxyear = 2018

function collectdir(dir, ids, dtypes)
    dfs = []
    for f in walkpath(dir)
        n = basename(f)
        println("Reading ", n)
        if n[end-3:end] == ".csv" && n[1:4] == "BACI"
            df = CSV.read(f, DataFrame, types=dtypes, missingstring="NA",
                stripwhitespace=true)
            df = df[df.t.<=maxyear, :]
            df = innerjoin(df, ids, on=[:i, :j, :k])
            select!(df, :sorc, :dest, :k=>:hs, :t=>:year, :v, :q)
            push!(dfs, df)
        else
            continue
        end
    end
    df = vcat(dfs...)
    return df
end

function main()
    hs92dir = rawdir/"BACI_HS92_V202401b"
    hs96dir = rawdir/"BACI_HS96_V202401b"
    hs02dir = rawdir/"BACI_HS02_V202401b"
    hs07dir = rawdir/"BACI_HS07_V202401b"

    ttbd = DataFrame(readstat(ttbddir/"adcvdbase.dta"))
    # Prepare a list of all sorc-dest-hs combinations in processed TTBD
    ids = unique(ttbd[!,[:dest,:sorc,:hs]])
    # 85 sorc and 44 dest
    nsorc = length(unique(ids.sorc))
    ndest = length(unique(ids.dest))
    reg = CSV.read(hs92dir/"country_codes_V202401b.csv", DataFrame, stripwhitespace=true)
    # The same iso3 may have multiple code
    reg = reg[!,[:country_code,:country_iso3]]
    ids = innerjoin(ids, reg, on=:sorc=>:country_iso3)
    rename!(ids, :country_code=>:i)
    ids = innerjoin(ids, reg, on=:dest=>:country_iso3)
    rename!(ids, :country_code=>:j, :hs=>:k)
    length(unique(ids.sorc)) == nsorc && length(unique(ids.dest)) == ndest ||
        @warn "not all iso3 code is matched"
    ids[!,:inttbd] .= true

    dtypes = Dict(:t=>Int16, :i=>Int16, :j=>Int16, :k=>String7, :v=>Float32, :q=>Float32)
    @time df92 = collectdir(hs92dir, ids, dtypes)
    writestat(bacidir/"baci92ttbd.dta", df92)

    @time df96 = collectdir(hs96dir, ids, dtypes)
    writestat(bacidir/"baci96ttbd.dta", df96)

    @time df02 = collectdir(hs02dir, ids, dtypes)
    writestat(bacidir/"baci02ttbd.dta", df02)

    @time df07 = collectdir(hs07dir, ids, dtypes)
    writestat(bacidir/"baci07ttbd.dta", df07)

    return df96
end

@time df = main()
