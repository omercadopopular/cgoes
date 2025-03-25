using DataFrames
using DiffinDiffs
using ReadStatTables
using FilePathsBase
using FilePathsBase: /

const haishidir = p"data/Haishi/share with marc/work folder"
const ttbddir = p"data/work/TTBD"

function main()
    df = DataFrame(readstat(haishidir/"replicate.dta"))
    df[!,:cohort] = Int.(df.year_treatment)
    df[df.ever_treated.==0,:cohort] .= -1
    df[!,:co_ano] = Int.(df.co_ano)
    #df[ismissing.(df.dumping_tariff_real),:dumping_tariff_real] .= 0
    #df.dumping_tariff_real .= log.(1 .+ df.dumping_tariff_real)

    @time r = @did(Reg, data=df, dynamic(:co_ano, -1), nevertreated(-1),
        vce=Vcov.cluster(:prod_dest_FE), yterm=term(:log_vl_fob), treatname=:cohort,
        treatintensity=:dumping_tariff, cohortinteracted=false,
        xterms=(fe(:prod_time_FE)+fe(:prod_ori_FE)+fe(:prod_dest_FE)+fe(:ori_time_FE)+fe(:dest_time_FE)+fe(:dist_time_committee)))


    @time r = @did(Reg, data=df, dynamic(:co_ano, vcat(-1,19:22)), nevertreated(-1),
        vce=Vcov.cluster(:prod_dest_FE), yterm=term(:log_vl_fob), treatname=:cohort,
        treatintensity=:dumping_tariff, cohortinteracted=false,
        xterms=(fe(:prod_time_FE)+fe(:prod_ori_FE)+fe(:prod_dest_FE)+fe(:ori_time_FE)+fe(:dest_time_FE)+fe(:dist_time_committee)))
    a = agg(r, :rel)
        



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




    df96 = DataFrame(readstat(ttbddir/"baci96base.dta"))

    dfh = select(df, :i_iso=>:dest, :e_iso=>:sorc, :co_ncm_h0=>:hs, :co_ano=>:year, :log_vl_fob, :dumping_tariff, :cohort)
    dfm = innerjoin(df96, dfh, on=[:dest, :sorc, :hs, :cohort_year=>:cohort, :year])

end


