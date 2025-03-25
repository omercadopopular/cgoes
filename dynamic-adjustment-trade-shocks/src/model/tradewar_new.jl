include("TradeAdj.jl")
using DataFrames
using ReadStatTables
using TypedTables
using MAT
using FilePathsBase
using FilePathsBase: /

const iciodir = p"data/work/ICIO"
const elasdir = p"data/work/elas"
const modeldir = p"data/work/model"

const CHN15 = ["AUT", "BEL", "DNK", "FIN", "FRA", "DCHN", "GRC", "IRL", "ITA", "LUX", "NLD",
    "PRT", "ESP", "SWE", "GBR"]

function calibrate!(p, elas, parajd, paraijd, paraisd, dreg, fillηG; noadj::Bool)
    fill!(p.θ, elas[1])
    fill!(p.σ, elas[2])
    fill!(p.ζ, noadj ? 1.0 : elas[3])
    #=smap = Dict("Plastics"=>10, "Wood"=>5, "Paper"=>6, "Textile"=>4,
        "Stone"=>11, "Basemetals"=>12, "Machinery"=>16)
    for (n, k) in pairs(smap)
        p.θ[k] = elas["theta"*n]
        p.σ[k] = elas["sigma"*n]
        p.ζ[k] = elas["zeta"*n]
    end=#

    p.μ[1:end-1,:] .= p.ζ' .* (1.0 .- p.ζ').^(0:p.K-2)
    p.μ[end:end,:] .= 1.0 .- sum(view(p.μ,1:p.K-1,:), dims=1)
    copyto!(p.η, parajd.fuseinincome)
    copyto!(p.α, parajd.vainoutput)
    copyto!(p.αM, paraijd.inputshare)
    p.D .= parajd.deficit[1:p.S:end]
    p.wLss .= parajd.va_d[1:p.S:end]
    p.wLshift[dreg["CN2"]] = dreg["CN1"]
    p.wLshift[dreg["MX2"]] = dreg["MX1"]
    copyto!(p.λ0ss, paraisd.inshare)
    copyto!(p.Xss, parajd.exp)
    # Needed for solver initial values
    p.X .= parajd.exp
    return p
end

function calibrate!(p::Problem{<:Any, <:MaxPresentValue},
        elas, parajd, paraijd, paraisd, dreg, fillηG; noadj::Bool)
    fill!(p.θ, elas[1])
    fill!(p.σ, elas[2])
    fill!(p.ζ, noadj ? 1.0 : elas[3])
    fillηG && copyto!(p.ηG, parajd.fuseinincome)

    p.μ[1:end-1,:] .= p.ζ' .* (1.0 .- p.ζ').^(0:p.K-2)
    p.μ[end:end,:] .= 1.0 .- sum(view(p.μ,1:p.K-1,:), dims=1)

    copyto!(p.η, parajd.fuseinincome);
    copyto!(p.α, parajd.vainoutput);
    copyto!(p.αM, paraijd.inputshare);
    p.D .= parajd.deficit[1:p.S:end];
    copyto!(p.λ0ss, paraisd.inshare);
    copyto!(p.Xss, parajd.exp);
    # p.wLss .= parajd.va_d[1:p.S:end]
    p.wLshift[dreg["CN2"]] = dreg["CN1"];
    p.wLshift[dreg["MX2"]] = dreg["MX1"];
    reconcile!(p)
    # Needed for solver initial values
    p.X .= view(p.Xss, :)
    p.sc.Πss .= sum(reshape(p.Xss, p.S, p.N) ./ p.σ, dims=1)'
    for n in ("CN", "MX")
        p.sc.Πss[dreg[n*"1"]] += p.sc.Πss[dreg[n*"2"]]
        p.sc.Πss[dreg[n*"2"]] = 0
    end
    p.realincomess .= p.wLss .+ p.sc.Πss
    return p
end

function setshock!(p, CHNtau::Table, dreg; year0=1994)
    iCHN15 = [dreg[n] for n in CHN15]
    for r in CHNtau
        t = r.year - year0
        i = unwrap(r.sorc_i32)
        s = dreg[r.sorc_iso3]
        for d in iCHN15
            p.τ[i,s,d,t] = r.dtariff
        end
        # 2004 is the year where tariff is removed
        if p.T > 2004-year0 && r.year==2004 
            for tp in t+1:p.T
                for d in iCHN15
                    p.τ[i,s,d,tp] = r.dtariff
                end
            end
        end
    end
    # Remaining values should be handled by solve!
    p.τhat[:,:,:,1] .= view(p.τ, :, :, :, 1)
    return nothing
end

function dimportshare!(dres, p, H, iCHN, iUSA)
    # The first horizon is the initial steady state
    λCHN = zeros(p.S, H+1)
    λUSA = zeros(p.S, H+1)
    XtotCHN = zeros(p.S, H+1)
    XtotUSA = zeros(p.S, H+1)
    λCHNagg = zeros(H+1)
    λUSAagg = zeros(H+1)
    XtotCHNagg = zeros(H+1)
    XtotUSAagg = zeros(H+1)
    for d in iCHN
        for i in 1:p.S
            XCHN0 = p.Xss[i,d]
            XtotCHN[i,1] += XCHN0
            for s in iUSA
                # Markup is canceled out
                λCHN[i,1] += XCHN0 * p.λ0ss[i,s,d]
            end
            λCHNagg[1] += λCHN[i,1]
            XtotCHNagg[1] += XCHN0
            for h in 1:H
                XCHN = p.X[i+(d-1)*p.S,h]
                XtotCHN[i,h+1] += XCHN
                for s in iUSA
                    λCHN[i,h+1] += XCHN * p.λ[i,s,d,h]
                end
                λCHNagg[h+1] += λCHN[i,h+1]
                XtotCHNagg[h+1] += XCHN
            end
        end
    end
    for d in iUSA
        for i in 1:p.S
            XUSA0 = p.Xss[i,d]
            XtotUSA[i,1] += XUSA0
            for s in iCHN
                # Markup is canceled out
                λUSA[i,1] += XUSA0 * p.λ0ss[i,s,d]
            end
            λUSAagg[1] += λUSA[i,1]
            XtotUSAagg[1] += XUSA0
            for h in 1:H
                XUSA = p.X[i+(d-1)*p.S,h]
                XtotUSA[i,h+1] += XUSA
                for s in iCHN
                    λUSA[i,h+1] += XUSA * p.λ[i,s,d,h]
                end
                λUSAagg[h+1] += λUSA[i,h+1]
                XtotUSAagg[h+1] += XUSA
            end
        end
    end
    for h in 1:H+1
        for i in 1:p.S
            λCHN[i,h] /= XtotCHN[i,h]
            λUSA[i,h] /= XtotUSA[i,h]
        end
        λCHNagg[h] /= XtotCHNagg[h]
        λUSAagg[h] /= XtotUSAagg[h]
    end
    dres["lambdaCHN"] = λCHN
    dres["lambdaUSA"] = λUSA
    dres["lambdaCHNagg"] = λCHNagg
    dres["lambdaUSAagg"] = λUSAagg
    return dres
end

function pickvars(p, H, secs, regs; shortname=:i32short)
    S, N = p.S, p.N
    υ = view(view(p.sc.υ, :, :, :, 1:H), :)
    υagg = view(view(p.sc.υagg, :, :, :, 1:H), :)
    λ = view(view(p.λ, :, :, :, 1:H), :)
    P = view(log.(view(p.Ps, :, :,1:H)) ./ (1.0.-p.σ), :)
    sec1 = LabeledArray(repeat(Int8(1):Int8(S), N^2*H), getvaluelabels(secs[!,shortname]))
    sec2 = LabeledArray(repeat(Int8(1):Int8(S), N*H), getvaluelabels(secs[!,shortname]))
    dfisd = DataFrame((sorc_i32=sec1, sorc_iso3=repeat(regs, inner=S, outer=N*H),
        dest_iso3=repeat(regs, inner=S*N, outer=H),
        horz=repeat(Int8(1):Int8(H), inner=S*N^2),
        upsilon=υ, upsilonagg=υagg, lambda=λ))
    dfid = DataFrame((dest_i32=sec2, dest_iso3=repeat(regs, inner=S, outer=H),
        horz=repeat(Int8(1):Int8(H), inner=S*N),lgP=P))
    return dfisd, dfid
end

function run!(p, elas, parajd, paraijd, paraisd, CHNtau, dreg, regs, secs, H, β;
        noadj=false, fillηG=false, saveresult=true, savemore=false, tag="",
        year0=2018)
    calibrate!(p, elas, parajd, paraijd, paraisd, dreg, fillηG; noadj=noadj)
    fillηG && (p.ηG .= p.η)
    year0 > 2018 && (CHNtau = CHNtau[CHNtau.year.>year0])
    setshock!(p, CHNtau, dreg; year0=year0)
    @time solve!(p);

    i32 = LabeledArray(1:p.S, getvaluelabels(secs[!,:i32short]))
    dfw, dfwi, dfA = welfare(p, H, β, regs, i32)
    if saveresult
        writestat(modeldir/"CHNenlarge_welfare_$(tag).dta", dfw)
        writestat(modeldir/"CHNenlarge_welfarei_$(tag).dta", dfwi)
        writestat(modeldir/"CHNenlarge_welfareA_$(tag).dta", dfA)
    end
    if savemore
        dfisd, dfid = pickvars(p, H, secs, regs)
        writestat(modeldir/"CHNenlarge_isd_$(tag).dta", dfisd)
        writestat(modeldir/"CHNenlarge_id_$(tag).dta", dfid)
    end
    return p, dfw
end

function main()
    sectag = "i32"
    S = 32
    H = 16
    fsuf = "_2017"
    #elas = matread(string(elasdir/"elasparam_blp_cp.mat"))
    parajd = readstat(iciodir/"parajd_$(sectag)$(fsuf).dta")
    paraijd = readstat(iciodir/"paraijd_$(sectag)$(fsuf).dta")
    paraisd = readstat(iciodir/"paraisd_$(sectag)$(fsuf).dta")
    regs = parajd.dest_iso3[1:S:end]
    dreg = Dict(regs.=>1:length(regs))
    secs = DataFrame(readstat(iciodir/"sectorlist.dta"))
    secs[!,:i32short] = LabeledArray(disallowmissing(unwrap.(secs[!,:i32short])),
        getvaluelabels(secs[!,:i32short]))

    CHNtau = DataFrame(readstat(iciodir/"CHNtariff.dta"))
    disallowmissing!(CHNtau)
    oneshock = true
    oneshock && (CHNtau = CHNtau[CHNtau.year.==2004,:])
    CHNtau = Table(CHNtau)
    USA = unique(CHNtau.sorc_iso3)
    iUSA = [dreg[n] for n in USA]
    iCHN = [dreg[n] for n in CHN15]

    topUSA = matread(string(iciodir/"USAtoptrade.mat"))
    itopUSA = topUSA["sorc_i32"]
    stopUSA = [dreg[n] for n in topUSA["sorc_iso3"]]
    dtopUSA = [dreg[n] for n in topUSA["dest_iso3"]]


    # Sectors directly affected by tariffs
    β = 0.96

    elasest = matread(string(elasdir/"gmmelasbase.mat"))
    elas = para = elasest["b"]

    H = 70
    p = Problem(T=H, sc=MaxPresentValue(T=H, TΨ=H-20))
    run!(p, para, parajd, paraijd, paraisd, CHNtau, dreg, regs, secs, H, β,
            fillηG=true, tag="base", saveresult=true, savemore=true)
    p1 = Problem(T=H, sc=MaxPresentValue(T=H, TΨ=H-20))
    run!(p1, para, parajd, paraijd, paraisd, CHNtau, dreg, regs, secs, H, β,
            noadj=true, fillηG=true, tag="lrbase")
    p2 = Problem(T=H)
    run!(p2, para, parajd, paraijd, paraisd, CHNtau, dreg, regs, secs, H, β,
            fillηG=true, tag="myobase", saveresult=true)
    p3 = Problem(T=H)
    run!(p3, para, parajd, paraijd, paraisd, CHNtau, dreg, regs, secs, H, β,
        noadj=true, fillηG=true, tag="myolrbase", saveresult=true)

    pt1 = Problem(T=H, sc=MaxPresentValue(T=H, TΨ=H-20))
    run!(pt1, para, parajd, paraijd, paraisd, CHNtau, dreg, regs, secs, H, β,
            fillηG=true, tag="y0_2002", saveresult=true, savemore=true, year0=2002)

    H = 20
    dres = Dict{String,Any}()
    dimportshare!(dres, p, H, iCHN, iUSA)

    return p
end

main()

#=
plot()
for (i, n) in enumerate(USA)
    plot!(1994 .+ (1:20), 100 .* p.w[iUSA[i],1:20], label=n)
end
title!("Change in Real Wage Among USA (%)\nForward-Looking")
xlabel!("Year")
savefig("figtemp/dwUSA2.pdf")

plot()
for (i, n) in enumerate(CHN15)
    plot!(1994 .+ (1:20), 100 .* p.w[dreg[n],1:20], label=n)
end
title!("Change in Real Wage Among CHN15 (%)\nForward-Looking")
xlabel!("Year")
savefig("figtemp/dwCHN152.pdf")


plot()
for (i, n) in enumerate(USA)
    plot!(1994 .+ (1:20), 100 .* p2.w[iUSA[i],1:20], label=n)
end
title!("Change in Real Wage Among USA (%)\nMyopic")
xlabel!("Year")
savefig("figtemp/dwUSA1_myopic.pdf")

plot()
for (i, n) in enumerate(CHN15)
    plot!(1994 .+ (1:20), 100 .* p2.w[dreg[n],1:20], label=n)
end
title!("Change in Real Wage Among CHN15 (%)\nMyopic")
xlabel!("Year")
savefig("figtemp/dwCHN151_myopic.pdf")


plot()
for (i, n) in enumerate(USA)
    plot!(1994 .+ (1:20), 100 .* p3.w[iUSA[i],1:20], label=n)
end
title!("Change in Real Wage Among USA (%)\nNo Friction")
xlabel!("Year")
savefig("figtemp/dwUSA1_nofriction.pdf")

plot()
for (i, n) in enumerate(CHN15)
    plot!(1994 .+ (1:20), 100 .* p3.w[dreg[n],1:20], label=n)
end
title!("Change in Real Wage Among CHN15 (%)\nNo Friction")
xlabel!("Year")
savefig("figtemp/dwCHN151_nofriction.pdf")

plot(leg=:bottomright)
for (i, s, d) in zip(itopUSA, stopUSA, dtopUSA)
    plot!(1994 .+ (1:50), 100 .* (log.(p.λ[i,s,d,1:50]) .- log.(p.λ[i,s,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Trade Shares\nTop Inudstry from Each USA (%)")

plot(leg=:topleft)
for (i, s, d) in zip(itopUSA, stopUSA, dtopUSA)
    plot!(1994 .+ (1:20), 100 .* (log.(p.sc.υ[i,s,d,1:20]) .- log.(p.sc.υ[i,s,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Sourcing Probability υ\nSelected Inudstries from Each USA (%)")
savefig("figtemp/dupsilonUSA.pdf")

plot(leg=:topleft)
for (i, s, d) in zip(itopUSA, stopUSA, dtopUSA)
    plot!(1994 .+ (1:20), 100 .* (log.(p.λ[i,s,d,1:20]) .- log.(p.λ[i,s,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Trade Shares\nSelected Inudstries from Each USA (%)")
savefig("figtemp/dlambdaUSA.pdf")

plot(leg=:bottomright)
for (i, s, d) in zip(itopUSA, stopUSA, dtopUSA)
    plot!(1994 .+ (1:20), 100 /(1.0.-p.σ[i]) .* (log.(p.Ps[i,d,1:20]) .- log.(p.Ps[i,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Prices\nSelected Inudstries from Each USA (%)")
savefig("figtemp/dPUSA.pdf")

plot(100 .* (dfw[dfw.iso3.=="HUN",:flex]), label="ACR Term")
plot!(100 .* (dfw[dfw.iso3.=="HUN",:dist]), label="Distortion Term")
title!("Decomposition of Real Wage Changes in HUN\nBased on Prop 4 (%)")
savefig("figtemp/dwhun.pdf")


plot(leg=:topleft)
for (i, s, d) in Base.product(1:19, iUSA, iCHN)
    plot!(1994 .+ (1:20), 100 .* (log.(p.λ[i,s,d,1:20]) .- log.(p.λ[i,s,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Trade Shares\nSelected Inudstries from Each USA (%)")

=#

