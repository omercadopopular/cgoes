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

const eu15 = ["AUT", "BEL", "DNK", "FIN", "FRA", "DEU", "GRC", "IRL", "ITA", "LUX", "NLD",
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

#=
function setshock!(p, eutau::Table, dreg; year0=1994)
    ieu15 = [dreg[n] for n in eu15]
    for r in eutau
        t = r.year - year0
        i = unwrap(r.sorc_i32)
        s = dreg[r.sorc_iso3]
        for d in ieu15
            p.τ[i,s,d,t] = r.dtariff
        end
        # 2004 is the year where tariff is removed
        if p.T > 2004-year0 && r.year==2004 
            for tp in t+1:p.T
                for d in ieu15
                    p.τ[i,s,d,tp] = r.dtariff
                end
            end
        end
    end
    # Remaining values should be handled by solve!
    p.τhat[:,:,:,1] .= view(p.τ, :, :, :, 1)
    return nothing
end
=#

function setshock!(p, eutau::Table, dreg; year0=1994)
    for r in eutau
        t = r.year - year0
        i = unwrap(r.sorc_i32)
        s = dreg[r.sorc_iso3]
        d = dreg[r.dest_iso3]
        p.τ[i,s,d,t] = r.dtariff
        # 2004 is the year where tariff is removed
        if p.T > 2004-year0 && r.year==2004 
            for tp in t+1:p.T
                p.τ[i,s,d,tp] = r.dtariff
            end
        end
    end
    # Remaining values should be handled by solve!
    p.τhat[:,:,:,1] .= view(p.τ, :, :, :, 1)
    return nothing
end

function dimportshare!(dres, p, H, iEU, iNMS)
    # The first horizon is the initial steady state
    λEU = zeros(p.S, H+1)
    λNMS = zeros(p.S, H+1)
    Xtoteu = zeros(p.S, H+1)
    Xtotnms = zeros(p.S, H+1)
    λEUagg = zeros(H+1)
    λNMSagg = zeros(H+1)
    Xtoteuagg = zeros(H+1)
    Xtotnmsagg = zeros(H+1)
    for d in iEU
        for i in 1:p.S
            Xeu0 = p.Xss[i,d]
            Xtoteu[i,1] += Xeu0
            for s in iNMS
                # Markup is canceled out
                λEU[i,1] += Xeu0 * p.λ0ss[i,s,d]
            end
            λEUagg[1] += λEU[i,1]
            Xtoteuagg[1] += Xeu0
            for h in 1:H
                Xeu = p.X[i+(d-1)*p.S,h]
                Xtoteu[i,h+1] += Xeu
                for s in iNMS
                    λEU[i,h+1] += Xeu * p.λ[i,s,d,h]
                end
                λEUagg[h+1] += λEU[i,h+1]
                Xtoteuagg[h+1] += Xeu
            end
        end
    end
    for d in iNMS
        for i in 1:p.S
            Xnms0 = p.Xss[i,d]
            Xtotnms[i,1] += Xnms0
            for s in iEU
                # Markup is canceled out
                λNMS[i,1] += Xnms0 * p.λ0ss[i,s,d]
            end
            λNMSagg[1] += λNMS[i,1]
            Xtotnmsagg[1] += Xnms0
            for h in 1:H
                Xnms = p.X[i+(d-1)*p.S,h]
                Xtotnms[i,h+1] += Xnms
                for s in iEU
                    λNMS[i,h+1] += Xnms * p.λ[i,s,d,h]
                end
                λNMSagg[h+1] += λNMS[i,h+1]
                Xtotnmsagg[h+1] += Xnms
            end
        end
    end
    for h in 1:H+1
        for i in 1:p.S
            λEU[i,h] /= Xtoteu[i,h]
            λNMS[i,h] /= Xtotnms[i,h]
        end
        λEUagg[h] /= Xtoteuagg[h]
        λNMSagg[h] /= Xtotnmsagg[h]
    end
    dres["lambdaEU"] = λEU
    dres["lambdaNMS"] = λNMS
    dres["lambdaEUagg"] = λEUagg
    dres["lambdaNMSagg"] = λNMSagg
    return dres
end

function pickvars(p, H, secs, regs; shortname=:i32short)
    S, N = p.S, p.N
    υ = view(view(p.sc.υ, :, :, :, 1:H), :)
    υagg = view(view(p.sc.υagg, :, :, :, 1:H), :)
    λ = view(view(p.λ, :, :, :, 1:H), :)
    Ψ = view(view(p.sc.Ψ, :, :, :, 1:H), :)
    P = view(log.(view(p.Ps, :, :,1:H)) ./ (1.0.-p.σ), :)
    wL = view(view(p.wL, :, 1:H), :)
    Π = view(view(p.sc.Π, :, 1:H), :)
    Pf = view(view(p.Pf, :, 1:H), :)
    drealincome = view(view(p.drealincome, :, 1:H), :)
    sec1 = LabeledArray(repeat(Int8(1):Int8(S), N^2*H), getvaluelabels(secs[!,shortname]))
    sec2 = LabeledArray(repeat(Int8(1):Int8(S), N*H), getvaluelabels(secs[!,shortname]))
    dfisd = DataFrame((sorc_i32=sec1, sorc_iso3=repeat(regs, inner=S, outer=N*H),
        dest_iso3=repeat(regs, inner=S*N, outer=H),
        horz=repeat(Int8(1):Int8(H), inner=S*N^2),
        upsilon=υ, upsilonagg=υagg, lambda=λ, option=Ψ))
    dfid = DataFrame((dest_i32=sec2, dest_iso3=repeat(regs, inner=S, outer=H),
        horz=repeat(Int8(1):Int8(H), inner=S*N), lgP=P))
    dfd = DataFrame((dest_iso3=repeat(regs, H),
        horz=repeat(Int8(1):Int8(H), inner=N), wL=wL, profit=Π, Pf=Pf,
        drealincome=drealincome))
    return dfisd, dfid, dfd
end

function run!(p, elas, parajd, paraijd, paraisd, eutau, dreg, regs, secs, H, β;
        noadj=false, fillηG=false, saveresult=true, savemore=false, tag="",
        year0=1994)
    calibrate!(p, elas, parajd, paraijd, paraisd, dreg, fillηG; noadj=noadj)
    fillηG && (p.ηG .= p.η)
    year0 > 1994 && (eutau = eutau[eutau.year.>year0])
    setshock!(p, eutau, dreg; year0=year0)
    @time solve!(p);

    i32 = LabeledArray(1:p.S, getvaluelabels(secs[!,:i32short]))
    dfw, dfwi, dfA = welfare(p, H, β, regs, i32)
    if saveresult
        writestat(modeldir/"euenlarge_welfare_$(tag).dta", dfw)
        writestat(modeldir/"euenlarge_welfarei_$(tag).dta", dfwi)
        writestat(modeldir/"euenlarge_welfareA_$(tag).dta", dfA)
    end
    if savemore
        dfisd, dfid, dfd = pickvars(p, H, secs, regs)
        writestat(modeldir/"euenlarge_isd_$(tag).dta", dfisd)
        writestat(modeldir/"euenlarge_id_$(tag).dta", dfid)
        writestat(modeldir/"euenlarge_d_$(tag).dta", dfd)
    end
    return p, dfw
end

function main()
    sectag = "i32"
    S = 32
    H = 16
    fsuf = "_1995"
    #elas = matread(string(elasdir/"elasparam_blp_cp.mat"))
    parajd = readstat(iciodir/"parajd_$(sectag)$(fsuf).dta")
    paraijd = readstat(iciodir/"paraijd_$(sectag)$(fsuf).dta")
    paraisd = readstat(iciodir/"paraisd_$(sectag)$(fsuf).dta")
    regs = parajd.dest_iso3[1:S:end]
    dreg = Dict(regs.=>1:length(regs))
    secs = DataFrame(readstat(iciodir/"sectorlist.dta"))
    secs[!,:i32short] = LabeledArray(disallowmissing(unwrap.(secs[!,:i32short])),
        getvaluelabels(secs[!,:i32short]))

    eutau = DataFrame(readstat(iciodir/"eutariff1.dta"))
    eutau[!,:year] .= 2004
    disallowmissing!(eutau)
    oneshock = true
    oneshock && (eutau = eutau[eutau.year.==2004,:])
    eutau = Table(eutau)
    NMS = unique(eutau.sorc_iso3)
    iNMS = [dreg[n] for n in NMS]
    iEU = [dreg[n] for n in eu15]

    topnms = matread(string(iciodir/"nmstoptrade.mat"))
    itopnms = topnms["sorc_i32"]
    stopnms = [dreg[n] for n in topnms["sorc_iso3"]]
    dtopnms = [dreg[n] for n in topnms["dest_iso3"]]


    # Sectors directly affected by tariffs
    β = 0.96

    elasest = matread(string(elasdir/"gmmelasbase.mat"))
    elas = para = elasest["b"]

    H = 70
    p = Problem(T=H, sc=MaxPresentValue(T=H, TΨ=H-20))
    run!(p, para, parajd, paraijd, paraisd, eutau, dreg, regs, secs, H, β,
            fillηG=true, tag="base", saveresult=true, savemore=true)
    p1 = Problem(T=H, sc=MaxPresentValue(T=H, TΨ=H-20))
    run!(p1, para, parajd, paraijd, paraisd, eutau, dreg, regs, secs, H, β,
            noadj=true, fillηG=true, tag="lrbase")
    p2 = Problem(T=H)
    run!(p2, para, parajd, paraijd, paraisd, eutau, dreg, regs, secs, H, β,
            fillηG=true, tag="myobase", saveresult=true)
    p3 = Problem(T=H)
    run!(p3, para, parajd, paraijd, paraisd, eutau, dreg, regs, secs, H, β,
        noadj=true, fillηG=true, tag="myolrbase", saveresult=true)

    pt1 = Problem(T=H, sc=MaxPresentValue(T=H, TΨ=H-20))
    run!(pt1, para, parajd, paraijd, paraisd, eutau, dreg, regs, secs, H, β,
            fillηG=true, tag="y0_2002", saveresult=true, savemore=true, year0=2002)

    H = 20
    dres = Dict{String,Any}()
    dimportshare!(dres, p, H, iEU, iNMS)

    return p
end

main()

#=
plot()
for (i, n) in enumerate(NMS)
    plot!(1994 .+ (1:20), 100 .* p.w[iNMS[i],1:20], label=n)
end
title!("Change in Real Wage Among NMS (%)\nForward-Looking")
xlabel!("Year")
savefig("figtemp/dwNMS2.pdf")

plot()
for (i, n) in enumerate(eu15)
    plot!(1994 .+ (1:20), 100 .* p.w[dreg[n],1:20], label=n)
end
title!("Change in Real Wage Among EU15 (%)\nForward-Looking")
xlabel!("Year")
savefig("figtemp/dwEU152.pdf")


plot()
for (i, n) in enumerate(NMS)
    plot!(1994 .+ (1:20), 100 .* p2.w[iNMS[i],1:20], label=n)
end
title!("Change in Real Wage Among NMS (%)\nMyopic")
xlabel!("Year")
savefig("figtemp/dwNMS1_myopic.pdf")

plot()
for (i, n) in enumerate(eu15)
    plot!(1994 .+ (1:20), 100 .* p2.w[dreg[n],1:20], label=n)
end
title!("Change in Real Wage Among EU15 (%)\nMyopic")
xlabel!("Year")
savefig("figtemp/dwEU151_myopic.pdf")


plot()
for (i, n) in enumerate(NMS)
    plot!(1994 .+ (1:20), 100 .* p3.w[iNMS[i],1:20], label=n)
end
title!("Change in Real Wage Among NMS (%)\nNo Friction")
xlabel!("Year")
savefig("figtemp/dwNMS1_nofriction.pdf")

plot()
for (i, n) in enumerate(eu15)
    plot!(1994 .+ (1:20), 100 .* p3.w[dreg[n],1:20], label=n)
end
title!("Change in Real Wage Among EU15 (%)\nNo Friction")
xlabel!("Year")
savefig("figtemp/dwEU151_nofriction.pdf")

plot(leg=:bottomright)
for (i, s, d) in zip(itopnms, stopnms, dtopnms)
    plot!(1994 .+ (1:50), 100 .* (log.(p.λ[i,s,d,1:50]) .- log.(p.λ[i,s,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Trade Shares\nTop Inudstry from Each NMS (%)")

plot(leg=:topleft)
for (i, s, d) in zip(itopnms, stopnms, dtopnms)
    plot!(1994 .+ (1:20), 100 .* (log.(p.sc.υ[i,s,d,1:20]) .- log.(p.sc.υ[i,s,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Sourcing Probability υ\nSelected Inudstries from Each NMS (%)")
savefig("figtemp/dupsilonnms.pdf")

plot(leg=:topleft)
for (i, s, d) in zip(itopnms, stopnms, dtopnms)
    plot!(1994 .+ (1:20), 100 .* (log.(p.λ[i,s,d,1:20]) .- log.(p.λ[i,s,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Trade Shares\nSelected Inudstries from Each NMS (%)")
savefig("figtemp/dlambdanms.pdf")

plot(leg=:bottomright)
for (i, s, d) in zip(itopnms, stopnms, dtopnms)
    plot!(1994 .+ (1:20), 100 /(1.0.-p.σ[i]) .* (log.(p.Ps[i,d,1:20]) .- log.(p.Ps[i,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Prices\nSelected Inudstries from Each NMS (%)")
savefig("figtemp/dPnms.pdf")

plot(100 .* (dfw[dfw.iso3.=="HUN",:flex]), label="ACR Term")
plot!(100 .* (dfw[dfw.iso3.=="HUN",:dist]), label="Distortion Term")
title!("Decomposition of Real Wage Changes in HUN\nBased on Prop 4 (%)")
savefig("figtemp/dwhun.pdf")


plot(leg=:topleft)
for (i, s, d) in Base.product(1:19, iNMS, iEU)
    plot!(1994 .+ (1:20), 100 .* (log.(p.λ[i,s,d,1:20]) .- log.(p.λ[i,s,d,1])), label=string(regs[s], "-", regs[d]))
end
title!("Change in Trade Shares\nSelected Inudstries from Each NMS (%)")

=#

