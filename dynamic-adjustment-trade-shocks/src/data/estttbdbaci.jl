using DataFrames
using DiffinDiffs
using MAT
using ReadStatTables
using FilePathsBase
using FilePathsBase: /
using Statistics

const ttbddir = p"data/work/TTBD"
const iciodir = p"data/work/ICIO"
const elasdir = p"data/work/elas"

function main()
    hs1toicio = DataFrame(readstat(iciodir/"hs1toicio.dta"))
    df = DataFrame(readstat(ttbddir/"bacibase.dta"))
    dres = Dict{String,Any}()

    # Cohort-specific estimates should match results from subsamples with single cohort
    @time r = @did(Reg, data=df, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:sorcdesths), yterm=term(:lgv), treatname=:cohort,
        treatintensity=:duty,
        xterms=(fe(:sorcdesths)+fe(:cohortrel)),
        subset=(df.duty.<0.4).&(df.rel.>=-5).&(df.rel.<=8))
    a = agg(r, :rel)

    dres["b_base"] = insert!(copy(a.coef), 5, 0)
    lb, ub = confint(a)
    dres["lb_base"] = insert!(lb, 5, NaN)
    dres["ub_base"] = insert!(ub, 5, NaN)

    matwrite(string(elasdir/"estttbdbaci.mat"), dres, compress=true)


    df1 = unique!(df[(df.duty.<0.4),[:sorc,:dest,:hs,:cohort,:duty,:affirmative]])
    dfy = combine(groupby(df1, [:cohort,:affirmative]), :duty=>mean, nrow=>:ncase)




    
#=
    i1 = hs1toicio[hs1toicio.i32.==13,[:hs96,:i32]]
    df_1 = leftjoin(df, i1, on=:hs=>:hs96)
    overlap = combine(groupby(combine(groupby(df_1, [:cohortrel, :affirmative]), nrow), [:cohortrel]), nrow)
    df_1 = innerjoin(df_1, overlap[overlap.nrow.==2,[:cohortrel]], on=:cohortrel)

    df_i = leftjoin(unique(df[!,[:hs]]), hs1toicio[!,[:hs96,:i32]], on=:hs=>:hs96)

    @time r = @did(Reg, data=df_1, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort,
        treatintensity=:duty,
        xterms=(fe(:sorcdesths)+fe(:cohortrel)), #weightname=:vlag1,
        #xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:cohortrel)), weightname=:vlag1,
        subset=(df_1.duty.<0.3).&(df_1.rel.>=-5).&(df_1.rel.<=8).&(
            (df_1.affirmative.==0).|(.~(ismissing.(df_1.i32)))))
    =#

end


