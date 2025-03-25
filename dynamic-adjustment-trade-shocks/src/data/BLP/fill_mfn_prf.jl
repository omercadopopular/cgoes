"""
Impute tariffs based on WTO membership and regional trade agreements

Results are saved by reporter country
"""

using Arrow
using Dates
using ReadStatTables
using DataFrames
using FilePathsBase
using FilePathsBase: /

const rootdir = @p_str(get(ARGS, 1, "data/work"))
const work = rootdir/"lev/temp_files"
const outdir = rootdir/"lev/temp_files/out"
const wtodir = rootdir/"WTO"

const column_mapping = ["importer"=>"Reporter", "exporter"=>"Partner",
    "mfn_st"=>"MFN", "prf_st"=>"PRF"]

# Load BLP data from each year
function lev_full(year1, yearN)
    cols = ["importer", "exporter", "hs6", "nomen", "year", "mfn_st", "prf_st"]
    dfullT = Dict{Int,Any}()
    allyear = year1:yearN
    for year in allyear
        fpath = work/"fullT$(year).dta"
        println("Loading ", fpath)
        df = DataFrame(readstat(fpath, usecols=cols))
        rename!(df, column_mapping)
        dfullT[year] = df
    end

    allreporter = union((unique(dfullT[y].Reporter) for y in allyear)...)
    allprods = []
    for y in allyear
        push!(allprods, unique(dfullT[y][!,[:hs6,:nomen]]))
    end
    allprod = unique!(vcat(allprods))
    println("lev_full: Found ", length(allreporter), " countries from ", year1, " to ", yearN)
    println("lev_full: Found ", length(allprod), " HS6-nomen from ", year1, " to ", yearN)
    sort!(allreporter)
    return dfullT, allreporter, allprod
end

function getreporterdata(dfullT, reporter, year1, yearN)
    thredstr = string("Thread ", Threads.threadid(), ": ")
    dfs = []
    partnerhss = []
    for y in year1:yearN
        dfy = dfullT[y]
        dfy = dfy[dfy.Reporter.==reporter,:]
        # Not all countries are reporter
        nrow(dfy) == 0 && continue

        dfy[!,:mfn] = coalesce(dfy.MFN, -Inf)
        dfy[!,:prf] = coalesce(dfy.PRF, -Inf)
        transform!(groupby(dfy, [:Partner,:hs6,:nomen]), [:mfn, :prf].=>maximum,
            renamecols=false)
        # Drop groups without MFN or PRF
        ir = (isequal.((dfy.mfn.>0), true)) .| (isequal.((dfy.prf.>0), true))
        push!(partnerhss, unique(view(dfy, ir, [:Partner,:hs6,:nomen])))
        push!(dfs, dfy)
    end
    if isempty(dfs)
        println(thredstr, "No data found for ", reporter, " as a reporter")
        return nothing
    end
    partnerhs = unique!(vcat(partnerhss...))
    allyear = year1:yearN
    N = nrow(partnerhs)
    println(thredstr, "Found ", N, " valid partner-product pairs for ", reporter)
    # Build a balanced full panel for the reporter
    df = repeat(partnerhs, inner=length(allyear))
    df[!,:year] = repeat(allyear, N)
    # Bring in remaining data from dfullT for the constructed panel
    dffull = vcat(dfs...)
    leftjoin!(df, dffull, on=[:Partner,:hs6,:nomen,:year])
    df[!,:Reporter] .= reporter
    df = df[!,[:Reporter,:Partner,:hs6,:nomen,:year,:MFN,:PRF]]
    return df
end

# Apply forward fill within partner-product groups if wto_eligible
# The columns must have been sorted with years iterating across each row
function _impute_mfn!(wto_eligible, MFN, year)
    N = length(wto_eligible)
    @inbounds for i in 2:N
        if wto_eligible[i] && (year[i] > year[i-1])
            MFN[i] = coalesce(MFN[i], MFN[i-1])
        end
    end
end

function get_rta_lookup(year1, yearN)
    rta = DataFrame(readstat(wtodir/"wto_rta.dta"))
    dropmissing!(rta)
    # ! Important to sort first
    sort!(rta, [:start_year, :signatories])
    drta = Dict{Tuple{String3,String3,Int16},Tuple{Int16,Int16,Int16}}()
    # The same rta may appear multiple times with different start_year
    for (k, g) in pairs(groupby(rta, [:rta,:start_year]))
        signs = g.signatories
        N = length(signs)
        y1 = g.start_year[1]
        y2 = g.end_impl_year[1]
        # ! signatories must be sorted
        for n1 in 1:N-1
            s = signs[n1]
            for n2 in n1+1:N
                d = signs[n2]
                for y in max(year1, y1):min(yearN, y1)
                    # Identify the RTA with the code in wto_rta.dta
                    # Newer RTAs overwrite older ones
                    drta[(s,d,y)] = (unwrap(k.rta), y1, y2)
                end
            end
        end
    end
    return drta
end

_nonmissing(x) = !ismissing(x)

function _interpolate!(x)
    i0 = findfirst(_nonmissing, x)
    i0 === nothing && return x
    im = findnext(ismissing, x, i0)
    im === nothing && return x
    i0 = im - 1
    i1 = findnext(_nonmissing, x, im)
    while i1 !== nothing
        N = i1 - i0
        v0 = x[i0]
        v1 = x[i1]
        step = (v1 - v0) / N
        for n in 1:N-1
            x[i0+n] = v0 + n * step
        end
        im = findnext(ismissing, x, i1)
        im === nothing && return x
        i0 = im - 1
        i1 = findnext(_nonmissing, x, im)
    end
    return x
end

function process_tariffs(dfullT, reporter, year1, yearN; verbose=false)
    T = yearN - year1 + 1
    thredstr = string("Thread ", Threads.threadid(), ": ")
    println(thredstr, "Processing tariffs for ", reporter)
    df = getreporterdata(dfullT, reporter, year1, yearN)
    df === nothing && return nothing
    df[!,:mfn_pre] = copy(df.MFN)
    df[!,:prf_pre] = copy(df.PRF)
    wtoyear = DataFrame(readstat(wtodir/"wto_mem_date.dta", usecols=[:ISO3,:wto_mem_date]))
    leftjoin!(df, wtoyear, on=:Partner=>:ISO3)
    df[!,:wto_eligible] = year.(coalesce.(df.wto_mem_date, Date(3000))) .<= df.year
    # ! Important to sort
    sort!(df, [:Partner, :hs6, :nomen, :year])
    _impute_mfn!(df.wto_eligible, df.MFN, df.year)

    df[!,:rta] .= zero(Int16)
    drta = get_rta_lookup(year1, yearN)
    for (k1, g1) in pairs(groupby(df, :Partner))
        partner = k1.Partner
        rp = (min(reporter, partner), max(reporter, partner))
        # Keep track of the rta that has been encountered before
        irtalast = 0
        for yr in year1:yearN
            # Check whether there is an RTA in year y
            v = get(drta, (rp[1], rp[2], yr), nothing)
            v === nothing && continue
            irta, y1, y2 = v
            # Skip if encountering the same RTA that has been handled
            irta == irtalast && continue
            irtalast = irta
            r1, r2 = y1-year1+1, y2-year1+1
            # Make sure the RTA overlaps with the tariff sample
            r1 < T || continue
            verbose && println(thredstr,
                "Filling preferential tariffs for Reporter=$reporter Partner=$partner RTA=$irta year=$yr")
            for g2 in groupby(g1, [:hs6,:nomen])
                nrow(g2) == yearN-year1+1 || error()
                prf = g2.PRF
                ir = max(r1,1):min(r2,T)
                _interpolate!(view(prf, ir))
                # Record the RTA the imputation is based on
                rta = g2.rta
                rta[ir] .= irta
                # Impute using the last observation
                for r in r2+1:T
                    prf[r] = coalesce(prf[r], prf[r-1])
                end
                rta[r2+1:T] .= irta
            end
        end
    end
    return df
end

function main()
    ntasks = Threads.nthreads()
    year1, yearN = 1995, 2018
    @time dfullT, allreporter, allprod = lev_full(year1, yearN)
    dfs = Vector{Union{DataFrame,Nothing}}(undef, length(allreporter))
    @time begin
        @sync for itask in 1:ntasks
            Threads.@spawn for i in itask:ntasks:length(allreporter)
                reporter = allreporter[i]
                dfs[i] = process_tariffs(dfullT, reporter, year1, yearN)
            end
        end
    end
    dir = outdir/"fill_full"
    isdir(dir) || mkdir(dir)
    @time for (i, df) in enumerate(dfs)
        fpath = dir/"fill_full_$(allreporter[i]).arrow"
        println("Saving ", fpath)
        Arrow.write(fpath, df; compress=:lz4)
    end
    return dfs
end

@time main()
