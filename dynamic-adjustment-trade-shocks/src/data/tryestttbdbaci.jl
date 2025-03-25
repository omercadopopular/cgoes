using DataFrames
using DiffinDiffs
using ReadStatTables
using FilePathsBase
using FilePathsBase: /

const ttbddir = p"data/work/TTBD"
const haishidir = p"data/Haishi/share with marc/work folder"
const iciodir = p"data/work/ICIO"

function main()
    hs1toicio = DataFrame(readstat(iciodir/"hs1toicio.dta"))
    df96 = DataFrame(readstat(ttbddir/"baci96base.dta"))
    dfh = DataFrame(readstat(haishidir/"replicate.dta"))
    dfh = select(df, :i_iso=>:dest, :e_iso=>:sorc, :co_ncm_h0=>:hs)
    ids = unique(dfh)
    df2 = innerjoin(df96, ids, on=[:dest,:sorc,:hs])
    
    @time r = @did(Reg, data=df96, dynamic(:year, -1), nevertreated(Int16(-1)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year_nt,
        treatintensity=:duty, cohortinteracted=false,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)),
        weightname=:vlag1, subset=df96.sorc.=="CHN")
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), nevertreated(Int16(-1)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year_nt,
        treatintensity=:duty, cohortinteracted=false,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)),
        weightname=:vlag1)
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), nevertreated(Int16(-1)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year_nt,
        treatintensity=:duty, cohortinteracted=false,
        xterms=(fe(:hsyear)+fe(:hsdest)+fe(:rel)),
        weightname=:vlag1, subset=df96.sorc.=="RUS")
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), nevertreated(Int16(-1)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year_nt,
        treatintensity=:duty, cohortinteracted=false,
        xterms=(fe(:hsyear)+fe(:hsdest)+fe(:rel)),
        subset=df96.sorc.=="RUS")
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), nevertreated(Int16(-1)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year_nt,
        treatintensity=:duty, cohortinteracted=false,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)),
        subset=df96.duty.<0.1)
    a = agg(r, :rel)

    @time r = @did(Reg, data=df2, dynamic(:year, -1), nevertreated(Int16(-1)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year_nt,
        treatintensity=:duty, cohortinteracted=false,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df2, dynamic(:year, -1), nevertreated(Int16(-1)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year_nt,
        treatintensity=:duty, cohortinteracted=false,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)),
        subset=df2.duty.<0.1)


    @time r = @did(Reg, data=df96, dynamic(:year, -1), notyettreated(Int16(2017)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:cohortrel)),
        subset=(df96.duty.>0.2).&(df96.duty.<1))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), notyettreated(Int16(2017)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:cohortrel)),
        subset=(df96.duty.>0.2))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:cohortrel)),
        subset=(df96.duty.>0.1).&(df96.duty.<2.0), weightname=:vlag1)
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:cohortrel)), weightname=:vlag1,
        subset=(df96.duty.<1.0))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:sorcdesths)+fe(:cohortrel)), #weightname=:vlag1,
        #xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:cohortrel)), weightname=:vlag1,
        subset=(df96.duty.<0.3).&(df96.rel.>=-5).&(df96.rel.<=8))#.&(df96.sorc.=="CHN") )#.&(.~(df96.cohort_year.∈((2008,),))))
        #))
    a = agg(r, :rel)
    a = agg(r, :rel, subset=:cohort_year=>(x->(x∈(2013,))))
    a = agg(r, :rel, subset=:cohort_year=>(x->!(x∈(2003,2006,2008))))
    # r.coef[findall(x->x[14:17]=="2005", r.coefnames)]

    @time r1 = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:sorcdesths), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:sorcdesths)+fe(:cohortrel)), weightname=:vlag1,
        subset=(df96.duty.<0.6).&(df96.cohort_year.==2005).&(df96.rel.>=-5).&(df96.rel.<=8))
    a1 = agg(r1)


    @time r1 = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:sorcdesths), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:sorcdesths)+fe(:cohortrel)), weightname=:vlag1,
        subset=(df96.duty.<0.6).&(df96.cohort_year.==2005).&(df96.rel.>=-3).&(df96.rel.<=7))
    a1 = agg(r1, :rel)


    df1 = unique!(df96[(df96.duty.>0).&(df96.duty.<0.6),[:sorc,:dest,:hs,:cohort_year,:duty]])
    transform!(groupby(df1, :cohort_year), :duty=>mean)

    df1 = unique!(df96[(df96.duty.>0).&(df96.duty.<0.6),[:sorc,:dest,:hs,:cohort_year,:duty]])
    combine(groupby(combine(groupby(df1, [:sorc,:dest,:hs,:cohort_year]), nrow),  :cohort_year), nrow=>:nflow)


    i1 = hs1toicio[hs1toicio.i32.==9,[:hs96,:i32]]
    df96_1 = innerjoin(df96, i1, on=:hs=>:hs96)
    overlap = combine(groupby(combine(groupby(df96_1, [:cohortrel, :affirmative]), nrow), [:cohortrel]), nrow)
    df96_1 = innerjoin(df96_1, overlap[overlap.nrow.==2,[:cohortrel]], on=:cohortrel)

    df96_i = leftjoin(unique(df96[!,[:hs]]), hs1toicio[!,[:hs96,:i32]], on=:hs=>:hs96)

    @time r = @did(Reg, data=df96_1, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:sorcdesths)+fe(:cohortrel)), #weightname=:vlag1,
        #xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:cohortrel)), weightname=:vlag1,
        subset=(df96_1.duty.<0.3).&(df96_1.rel.>=-5).&(df96_1.rel.<=8))
    


    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintterms=(term(:affirmative),),
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)), weightname=:vlag1,
        subset=(df96.duty.<0.6).&(df96.rel.>=-3).&(df96.rel.<=7))
    a = agg(r, :rel)

    df1 = df96[(df96.duty.<0.6).&(df96.rel.>=-3).&(df96.rel.<=3),:]
    transform!(groupby(df1, [:sorc,:dest,:year,:cohort_year]), :affirmative=>length∘unique=>:overlap)
    @time r = @did(Reg, data=df1, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintterms=(term(:affirmative),),
        xterms=(fe(:sorcdesths),), weightname=:vlag1, subset=df1.overlap.==2)

    a = agg(r, (:rel, :affirmative))
    nrel = length(unique(r.treatcells.rel))
    ncoef = length(coef(a))
    M = zeros(nrel, ncoef)
    for i in 1:nrel
        M[i,2*i-1] = -1
        M[i,2*i] = 1
    end
    lincom(a, M, 2:2:ncoef)
    

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty, cohortinteracted=true,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:cohortrel)), weightname=:vlag1,
        subset=(df96.duty.<0.6).&(df96.rel.>=-5).&(df96.rel.<=7))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty, cohortinteracted=true,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:cohortrel)), weightname=:vlag1,
        subset= (df96.duty.>0.1).&(df96.duty.<0.6).&(df96.rel.>=-5).&(df96.rel.<=7))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:cohortrel)), weightname=:vlag1,
        subset=(df96.duty.<0.5))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty, cohortinteracted=false,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)), weightname=:vlag1,
        subset=(df96.duty.<0.6))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:hsyear)+fe(:hsdest)+fe(:cohortrel)), weightname=:vlag1,
        subset=(df96.duty.<0.8).&(df96.sorc.=="CHN"))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:hs)+fe(:hsdest)+fe(:cohortrel)), weightname=:vlag1,
        subset=(0.2.<df96.duty.<1).&(df96.sorc.=="CHN"))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty, cohortinteracted=false,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)), weightname=:vlag1,
        subset=(df96.duty.<1.0))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), unspecifiedpr(),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:year)+fe(:hsdest)+fe(:cohortrel)),
        subset=(df96.duty.>0.1).&(df96.sorc.=="CHN"))
    a = agg(r, :rel)

    @time r = @did(Reg, data=df96, dynamic(:year, -1), notyettreated(Int16(2017)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintensity=:duty,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)),
        subset=(df96.duty.>0.01).&(df96.sorc.=="CHN").&(df96.duty.<0.5))
    a = agg(r, :rel)


    @time r = @did(Reg, data=df96, dynamic(:year, -1), nevertreated(Int16(-1)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year_nt,
        treatintensity=:duty, cohortinteracted=true,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)),
        subset=df96.duty.<0.1)
    a = agg(r, :rel)
        
    @time r = @did(Reg, data=df96, dynamic(:year, -1), nevertreated(Int16(-1)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year_nt,
        treatintensity=:duty,
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)+fe(:rel)))





    @time r = @did(Reg, data=df96, dynamic(:year, -1), notyettreated(Int16(2017)),
        vce=Vcov.cluster(:hsdest), yterm=term(:lgv), treatname=:cohort_year,
        treatintterms=(:affirmative,),
        xterms=(fe(:destyear)+fe(:sorcyear)+fe(:hsyear)+fe(:hssorc)+fe(:hsdest)))
    a = agg(r, (:rel, :affirmative))
    nrel = length(unique(r.treatcells.rel))
    ncoef = length(coef(a))
    M = zeros(nrel, ncoef)
    for i in 1:nrel
        M[i,2*i-1] = -1
        M[i,2*i] = 1
    end
    lincom(a, M, 2:2:ncoef)
end


