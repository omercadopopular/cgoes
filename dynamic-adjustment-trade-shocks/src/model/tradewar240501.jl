include("TradeAdj.jl")
using DataFrames
using LinearAlgebra: I, qr!, ldiv!
using ReadStatTables
using TypedTables
using MAT
using FilePathsBase
using FilePathsBase: /

const iciodir = p"data/work/ICIO"
const elasdir = p"data/work/elas"
const modeldir = p"data/work/model/240501"

function calibrate!(p, elas, parajd, paraijd, paraisd, dreg; noadj::Bool)
    fill!(p.θ, elas["theta"])
    fill!(p.σ, elas["sigma"])
    fill!(p.ζ, noadj ? 1.0 : elas["zeta"])
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

function setshock!(p, mtau::Table, xtau::Table, dreg)
    iUS = dreg["USA"]
    for r in mtau
        # taumax19 is always the largest among a row
        r.taumax19 == 1 && continue
        s = dreg[r.iso3]
        p.τ[r.i34,s,iUS,1] = r.tau18
        p.τ[r.i34,s,iUS,2] = r.tau19
        p.τ[r.i34,s,iUS,3:end] .= r.taumax19
    end
    for r in xtau
        # taumax19 is always the largest among a row
        r.taumax19 == 1 && continue
        d = dreg[r.iso3]
        p.τ[r.i34,iUS,d,1] = r.tau18
        p.τ[r.i34,iUS,d,2] = r.tau19
        p.τ[r.i34,iUS,d,3:end] .= r.taumax19
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
    P = view(p.P, itau, :, 1:H)[:]
    # Normalize the prices with domestic wage
    Pw = (view(p.P, itau, :, 1:H) .-
        _reshape(view(p.W, :, 1:H), 1, N, H))[:]
    secsh = LabeledArray(repeat(itau, N*H), getvaluelabels(secs[!,shortname]))
    S = length(itau)
    df = DataFrame((sec=secsh,
        iso3=repeat(regs, inner=S, outer=H),
        h=repeat(0:H-1, inner=N*S), P=P, Pw=Pw))
    return df
end

function logacr!(out, rr, Am, am, Id, p, H, d)
    # Skip the computation if any domestic share is zero
    any(==(0), view(p.λ0ss,:,d,d)) && return nothing
    am .= Id .- view(p.αM,:,:,d)
    # Final use expenditure shares do not sum up to 1 because of tax
    ηs = sum(view(p.η, :, d))
    # Rescale so that results are comparable with Wp
    η = view(p.η,:,d) ./ ηs
    # All allocations are from qr!
    ldiv!(Am, qr!(am), η)
    acrflex = view(out[1], rr)
    # All distortion (exact)
    dist = view(out[2], rr)
    # Just adjusted
    dist0 = view(out[3], rr)
    # Adjusted at least once
    distk = view(out[4], rr)
    # Never adjusted
    distn = view(out[5], rr)
    for h in 1:H
        for i in 1:p.S
            σθ = (p.σ[i] - 1)/p.θ[i] - 1
            acrflex[h] += Am[i] / p.θ[i] * (log(p.λ0ss[i,d,d]) - log(p.λ[i,d,d,h]))
            dist0[h] += Am[i] / (p.σ[i] - 1) * p.ζ[i] * σθ * (log(p.λ[i,d,d,h]) - log(p.λk[1,i,d,d,h]))
            lgdistki = 0.0
            distki = 0.0
            for k in 1:h-1
                lgdistki += (1 - p.ζ[i])^k * σθ * (log(p.λ[i,d,d,h]) - log(p.λk[1,i,d,d,h-k]))
                distki += (1 - p.ζ[i])^k * (p.λ[i,d,d,h] / p.λk[1,i,d,d,h-k])^σθ
            end
            distk[h] += Am[i] / (p.σ[i] - 1) * p.ζ[i] * lgdistki
            distn[h] += Am[i] / (p.σ[i] - 1) * (1 - p.ζ[i])^h * σθ * (log(p.λ[i,d,d,h]) - log(p.λ0ss[i,d,d]))
            dist[h] += Am[i] / (p.σ[i] - 1) * log(
                p.ζ[i] * (p.λ[i,d,d,h] / p.λk[1,i,d,d,h])^σθ +
                p.ζ[i] * distki +
                (1 - p.ζ[i])^h * (p.λ[i,d,d,h] / p.λ0ss[i,d,d])^σθ)
        end
    end
    out[6][rr] .= ηs
    return out
end

function welfare(p, H, β, regs)
    out = [zeros(p.N*H) for _ in 1:6]
    Am = zeros(p.S)
    am = zeros(p.S, p.S)
    Id = I(p.S)
    for d in 1:p.N
        logacr!(out, 1+(d-1)*H:d*H, Am, am, Id, p, H, d)
    end
    df = DataFrame(out, [:flex, :dist, :dist0, :distk, :distn, :etasum])
    df[!,:wp] = view(view(p.w', 1:H, :), :)
    df[!,:W] = view(view(p.W', 1:H, :), :)
    df[!,:Pf] = view(view(p.Pf', 1:H, :)./ sum(p.η, dims=1), :)
    df[!,:wpcum] = view(cumsum(view(p.w', 1:H, :) .* β.^(0:H-1), dims=1), :)
    df[!,:flexcum] = view(cumsum(reshape(df.flex, H, p.N) .* β.^(0:H-1), dims=1), :)
    insertcols!(df, 1, :h=>repeat(0:H-1, p.N), :iso3=>repeat(regs, inner=H))
    return df
end

function run!(p, elas, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β;
        noadj=false, fillηG=false, saveresult=true, tag="")    
    calibrate!(p, elas, parajd, paraijd, paraisd, dreg; noadj=noadj)
    fillηG && (p.ηG .= p.η)
    setshock!(p, mtau, xtau, dreg)
    @time solve!(p);

    priceindex!(p)
    realwage!(p)

    if saveresult
        dres = Dict{String, Any}()
        geelasticity!(dres, p, itau, H, dreg)
        peelasticity!(dres, p, itau, H, dreg)
        dfP = pickprices(p, regs, 1:32, H, secs, :i32short)
        writestat(modeldir/"price_$(tag).dta", dfP)
        dfw = welfare(p, H, β, regs)
        writestat(modeldir/"welfare_$(tag).dta", dfw)
        matwrite(string(modeldir/"tradewar_$(tag).mat"), dres, compress=true)
        return p, dres, dfP, dfw
    else
        return p
    end
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
    elas = Dict("theta"=>3.16, "sigma"=>1.11, "zeta"=>0.09)
    ζs = [0.09, 0.2, 0.4, (0.09 for _ in 1:2)...]
    θs = [(3.16 for _ in 1:3)..., 2.0, 5.0]
    sufs = ["", "_zeta02", "_zeta04", "_theta2", "_theta5"]
    for (ζ, θ, suf) in zip(ζs, θs, sufs)
        elas["zeta"] = ζ
        elas["theta"] = θ

        #=
        p = Problem(T=H)
        run!(p, elas, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β,
            tag="base"*suf);
        p = Problem(T=H)
        run!(p, elas, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β,
            noadj=true, tag="baselr"*suf)
        =#

        p = Problem(T=H)
        run!(p, elas, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β,
            fillηG=true, tag="G"*suf)
        p = Problem(T=H)
        run!(p, elas, parajd, paraijd, paraisd, mtau, xtau, dreg, regs, secs, itau, H, β,
            noadj=true, fillηG=true, tag="Glr"*suf)
    end
    return nothing
end

@time main()
