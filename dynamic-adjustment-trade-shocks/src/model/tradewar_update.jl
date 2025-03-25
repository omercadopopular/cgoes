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

function setshock!(p, mtau::Table, xtau::Table, dreg)
    iUS = dreg["USA"]
    for r in mtau
        # taumax19 is always the largest among a row
        r.taumax19 == 1 && continue
        s = dreg[r.iso3]
        #p.τ[r.i34,s,iUS,1] = r.tau18
        #p.τ[r.i34,s,iUS,2] = r.tau19
        p.τ[r.i34,s,iUS,1:end] .= r.taumax19
    end
    for r in xtau
        # taumax19 is always the largest among a row
        r.taumax19 == 1 && continue
        d = dreg[r.iso3]
        #p.τ[r.i34,iUS,d,1] = r.tau18
        #p.τ[r.i34,iUS,d,2] = r.tau19
        p.τ[r.i34,iUS,d,1:end] .= r.taumax19
    end
    # CHN/MEX is mapped to CN1/MX1 and hence need to handle CN2/MX2
    for s in ("CN", "MX")
        p.τ[:,dreg[string(s,2)],iUS,:] .= p.τ[:,dreg[string(s,1)],iUS,:]
        p.τ[:,iUS,dreg[string(s,2)],:] .= p.τ[:,iUS,dreg[string(s,1)],:]
    end
    # Remaining values should be handled by solve!
    p.τhat[:,:,:,1] .= view(p.τ, :, :, :, 1)
    return nothing
end

function geelasticity!(dres, p, itau, H, dreg)
    iUSA, iCN1, iCN2 = dreg["USA"], dreg["CN1"], dreg["CN2"]
    X = _reshape(p.X, p.S, p.N, p.T)
    S = length(itau)
    # The first horizon is the initial steady state
    MUSA = zeros(S, H+1, 2)
    MCHN = zeros(S, H+1, 2)
    for (n, c) in zip(1:2, (iCN1, iCN2))
        for i in itau
            MUSA[i,1,n] = p.Xss[i,iUSA] * p.λ0ss[i,c,iUSA]
            MCHN[i,1,n] = p.Xss[i,c] * p.λ0ss[i,iUSA,c]
        end
        for h in 1:H
            for i in itau
                MUSA[i,h+1,n] = X[i,iUSA,h] * p.λ[i,c,iUSA,h] #/ p.τ[i,c,iUSA,h]
                MCHN[i,h+1,n] = X[i,c,h] * p.λ[i,iUSA,c,h] #/ p.τ[i,iUSA,c,h]
            end
        end
    end
    # Imports include the increased tariffs
    # For the last dimension, the three slices are for CHN (total), CN1 and CN2
    # MUSA starts from the steady state but X does not (index differs by 1)
    dlgMUSA = zeros(1, H, 3)
    dlgMUSA[:,:,1] .= log.(sum(view(MUSA,:,2:H+1,:), dims=(1,3))) .-
        log.(sum(view(MUSA,:,1:1,:), dims=(1,3)))
    dlgMUSA[:,:,2:3] .= log.(sum(view(MUSA,:,2:H+1,:), dims=1)) .-
        log.(sum(view(MUSA,:,1:1,:), dims=1))
    dlgMCHN = zeros(1, H, 3)
    dlgMCHN[:,:,1] .= log.(sum(view(MCHN,:,2:H+1,:), dims=(1,3))) .-
        log.(sum(view(MCHN,:,1:1,:), dims=(1,3)))
    for (k, c) in zip(1:2, (iCN1, iCN2))
        dlgMCHN[:,:,k+1] .= log.(sum(view(MCHN,:,2:H+1,k), dims=1)) .-
            log.(sum(view(MCHN,:,1:1,k), dims=1))
    end
    dres["dlgMUSA"] = reshape(dlgMUSA, H, 3)
    dres["dlgMCHN"] = reshape(dlgMCHN, H, 3)
    dres["MUSA"] = MUSA
    dres["MCHN"] = MCHN
    return dres
end

function peelasticity!(dres, p, itau, H, dreg)
    iUSA, iCN1, iCN2 = dreg["USA"], dreg["CN1"], dreg["CN2"]
    S = length(itau)
    # The first horizon is the initial steady state
    MUSA = zeros(S, H+1)
    MCHN = zeros(S, H+1)
    # Elasticities are tariff-inclusive
    ela = -view(p.θ, itau) .* (1.0.-(1.0.-view(p.ζ, itau)).^(1:H)') .+
        (1.0.-view(p.σ, itau)) .* (1.0.-view(p.ζ, itau)).^(1:H)'# .- 1
    for i in itau
        MUSA[i,1] = p.Xss[i,iUSA] * (p.λ0ss[i,iCN1,iUSA] + p.λ0ss[i,iCN2,iUSA])
        MCHN[i,1] = p.Xss[i,iCN1] * p.λ0ss[i,iUSA,iCN1] +
            p.Xss[i,iCN2] * p.λ0ss[i,iUSA,iCN2]
        for h in 1:H
            MUSA[i,h+1] = log(MUSA[i,1]) + ela[i,h] * log(p.τ[i,iCN1,iUSA,1])
            MCHN[i,h+1] = log(MCHN[i,1]) + ela[i,h] * log(p.τ[i,iUSA,iCN1,1])
        end
        for h in 1:H-1
            MUSA[i,h+2] += ela[i,h] * log(p.τ[i,iCN1,iUSA,2]/p.τ[i,iCN1,iUSA,1])
            MCHN[i,h+2] += ela[i,h] * log(p.τ[i,iUSA,iCN1,2]/p.τ[i,iUSA,iCN1,1])
        end
        for h in 1:H-2
            MUSA[i,h+3] += ela[i,h] * log(p.τ[i,iCN1,iUSA,3]/p.τ[i,iCN1,iUSA,2])
            MCHN[i,h+3] += ela[i,h] * log(p.τ[i,iUSA,iCN1,3]/p.τ[i,iUSA,iCN1,2])
        end
        for h in 1:H
            MUSA[i,h+1] = exp(MUSA[i,h+1])
            MCHN[i,h+1] = exp(MCHN[i,h+1])
        end
    end
    dlgMUSA = zeros(1, H)
    dlgMUSA .= log.(sum(view(MUSA,:,2:H+1), dims=1)) .-
        log.(sum(view(MUSA,:,1:1), dims=1))
    dlgMCHN = zeros(1, H)
    dlgMCHN .= log.(sum(view(MCHN,:,2:H+1), dims=1)) .-
        log.(sum(view(MCHN,:,1:1), dims=1))
    dres["dlgMUSApe"] = reshape(dlgMUSA, H)
    dres["dlgMCHNpe"] = reshape(dlgMCHN, H)
    dres["MUSApe"] = MUSA
    dres["MCHNpe"] = MCHN
    return dres
end

function pickprices(p, regs, itau, H, secs, shortname)
    N = length(regs)
    lP = log.(p.P)
    P = view(lP, itau, :, 1:H)[:]
    # Normalize the prices with domestic wage
    Pw = (lP .- _reshape(view(p.W, :, 1:H), 1, N, H))[:]
    secsh = LabeledArray(repeat(itau, N*H), getvaluelabels(secs[!,shortname]))
    S = length(itau)
    df = DataFrame((sec=secsh,
        iso3=repeat(regs, inner=S, outer=H),
        h=repeat(0:H-1, inner=N*S), P=P, Pw=Pw))
    return df
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


function run!(p, elas, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β;
        noadj=false, fillηG=false, saveresult=true, tag="")
    calibrate!(p, elas, parajd, paraijd, paraisd, dreg, fillηG; noadj=noadj)
    fillηG && (p.ηG .= p.η)
    setshock!(p, mtau, xtau, dreg)
    @time solve!(p);

    iUSA, iCN1, iCN2 = dreg["USA"], dreg["CN1"], dreg["CN2"]

    dres = Dict{String, Any}()
    geelasticity!(dres, p, itau, H, dreg)
    peelasticity!(dres, p, itau, H, dreg)
    dfP = pickprices(p, regs, 1:32, H, secs, :i32short)
    i32 = LabeledArray(1:p.S, getvaluelabels(secs[!,:i32short]))
    dfw, dfwi, dfA = welfare(p, H, β, regs, i32)
    dfisd, dfid = pickvars(p, H, secs, regs)
    
    if saveresult
        writestat(modeldir/"tradewar_price_$(tag).dta", dfP)
        writestat(modeldir/"tradewar_welfare_$(tag).dta", dfw)
        writestat(modeldir/"tradewar_welfarei_$(tag).dta", dfwi)
        writestat(modeldir/"tradewar_welfareA_$(tag).dta", dfA)
        writestat(modeldir/"tradewar_isd_$(tag).dta", dfisd)
        writestat(modeldir/"tradewar_id_$(tag).dta", dfid)
        matwrite(string(modeldir/"tradewar_$(tag).mat"), dres, compress=true)
    end
    return p, dres, dfP, dfw
end

function main()
    sectag = "i32"
    S = 32
    H = 16
    parajd = readstat(iciodir/"parajd_$(sectag).dta")
    paraijd = readstat(iciodir/"paraijd_$(sectag).dta")
    paraisd = readstat(iciodir/"paraisd_$(sectag).dta")
    regs = parajd.dest_iso3[1:S:end]
    dreg = Dict(regs.=>1:length(regs))
    # Needed for setshock!
    dreg["CHN"] = dreg["CN1"]
    dreg["MEX"] = dreg["MX1"]
    secs = DataFrame(readstat(iciodir/"sectorlist.dta"))
    secs[!,:i34short] = LabeledArray(disallowmissing(unwrap.(secs[!,:i34short])),
        getvaluelabels(secs[!,:i34short]))
    mtau = DataFrame(readstat(iciodir/"mtau.dta"))
    # A work around before the issue with Missing is fixed
    mtau[!,:i34] = refarray(mtau.i34)
    disallowmissing!(mtau)
    mtau = Table(mtau)
    xtau = DataFrame(readstat(iciodir/"xtau.dta"))
    xtau[!,:i34] = refarray(xtau.i34)
    disallowmissing!(xtau)
    xtau = Table(xtau)

    # Sectors directly affected by tariffs
    itau = 1:19
    β = 0.96

    elasest = matread(string(elasdir/"gmmelasbase.mat"))
    elas = para = elasest["b"]

    H = 70
    p = Problem(T=H, sc=MaxPresentValue(T=H, TΨ=H-20))
    run!(p, para, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β,
            fillηG=true, tag="Gbase", saveresult=true)
    p1 = Problem(T=H, sc=MaxPresentValue(T=H, TΨ=H-20))
    run!(p1, para, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β,
            noadj=true, fillηG=true, tag="Glrbase", saveresult=true)
    p2 = Problem(T=H)
    run!(p2, para, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β,
            fillηG=true, tag="Gmyobase", saveresult=true)
    p3 = Problem(T=H)
    run!(p3, para, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β,
        noadj=true, fillηG=true, tag="Gmyolrbase", saveresult=true)

    dimportshare!(dres, p, H, dreg["CHN"], dreg["USA"])
    return p
end

@time p = main()
