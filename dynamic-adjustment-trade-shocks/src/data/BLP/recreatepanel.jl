"""
Merge imputation results back to BLP sample by year
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

const imputeprf = true
const dropimputeprf = false
const dropimputedmfn = true

function main()
    year1, yearN = 1995, 2018

    pfillfulls = filter(readdir(outdir/"fill_full", join = true)) do f
        contains(f, Regex("^$outdir/fill_full.*\\.arrow\$"))
    end

    dfs = []
    for p in pfillfulls
        println("Loading ", p)
        push!(dfs, DataFrame(Arrow.Table(p), copycols=true))
    end

    byyear = []
    for y in year1:yearN
        println("Processing data for ", y)
        empty!(byyear)
        for df in dfs
            push!(byyear, df[df.year.==y,:])
        end
        dfy = vcat(byyear...)
        rename!(dfy, :MFN=>:mfn_st, :PRF=>:prf_st, :Reporter=>:importer,
            :Partner=>:exporter)

        # Create variables for effective applied tariff
        if imputeprf
            dfy[!,:ahs_st] = coalesce.(min.(dfy.prf_st, dfy.mfn_st), dfy.prf_st, dfy.mfn_st)
        else
            dfy[!,:ahs_st] = coalesce.(min.(dfy.prf_pre, dfy.mfn_st), dfy.prf_pre, dfy.mfn_st)
        end
        dfy[!,:ahs_pre] = coalesce.(min.(dfy.prf_pre, dfy.mfn_pre), dfy.prf_pre, dfy.mfn_pre)
        dfy = dfy[.~(ismissing.(dfy.ahs_st)),:]
        @show nrow(dfy)
        if dropimputeprf
            dfy = dfy[.~(isequal.(dfy.ahs_st,dfy.prf_st).&(.~(isequal.(dfy.prf_st,dfy.prf_pre)))),:]
            @show nrow(dfy)
            println()
        elseif dropimputedmfn
            dfy = dfy[.~(isequal.(dfy.ahs_st,dfy.mfn_st).&(.~(isequal.(dfy.mfn_st,dfy.mfn_pre)))),:]
            @show nrow(dfy)
            println()
        end

        # Handle missing values in string columns
        for col in columnnames(dfy)
            T = eltype(dfy[!,col])
            if T <: Union{Missing, AbstractString}
                dfy[!,col] .= coalesce.(dfy[!,col], "")
            end
        end
        #=
        if imputeprf
            writestat(outdir/"TF$(y).dta", dfy)
        else
            writestat(outdir/"TF$(y)_N.dta", dfy)
        end
        =#
        writestat(outdir/"TF$(y)_N.dta", dfy)
    end
end

@time main()
