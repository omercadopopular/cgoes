include("TradeAdj.jl")
using DataFrames
using LinearAlgebra: I
using ReadStatTables
using TypedTables
using MAT

const iciodir = "data/work/ICIO/"
const modeldir = "data/work/model/"

function calibrate!(p, parajd, paraijd, paraisd, dreg)
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
                MUSA[i,h+1,n] = X[i,iUSA,h] * p.λ[i,c,iUSA,h] / p.τ[i,c,iUSA,h]
                MCHN[i,h+1,n] = X[i,c,h] * p.λ[i,iUSA,c,h] / p.τ[i,iUSA,c,h]
            end
        end
    end
    # Imports do not include the increased tariffs
    # For the last dimension, the three slices are for CHN (total), CN1 and CN2
    dlgMUSA = zeros(1, H, 3)
    dlgMUSA[:,:,1] .= log.(sum(view(MUSA,:,2:H+1,:), dims=(1,3))) .-
        log.(sum(view(X,itau,iUSA,1:H), dims=1)) .-
        log.(sum(view(MUSA,:,1:1,:), dims=(1,3))) .+
        log.(sum(view(p.Xss,itau,iUSA)))
    dlgMUSA[:,:,2:3] .= log.(sum(view(MUSA,:,2:H+1,:), dims=1)) .-
        log.(sum(view(X,itau,iUSA,1:H), dims=1)) .-
        log.(sum(view(MUSA,:,1:1,:), dims=1)) .+
        log.(sum(view(p.Xss,itau,iUSA)))
    dlgMCHN = zeros(1, H, 3)
    dlgMCHN[:,:,1] .= log.(sum(view(MCHN,:,2:H+1,:), dims=(1,3))) .-
        log.(sum(view(X,itau,iCN1,1:H), dims=1) .+ sum(view(X,itau,iCN2,1:H), dims=1)) .-
        log.(sum(view(MCHN,:,1:1,:), dims=(1,3))) .+
        log.(sum(view(p.Xss,itau,iCN1)) .+ sum(view(p.Xss,itau,iCN2)))
    for (k, c) in zip(1:2, (iCN1, iCN2))
        dlgMCHN[:,:,k+1] .= log.(sum(view(MCHN,:,2:H+1,k), dims=1)) .-
            log.(sum(view(X,itau,c,1:H), dims=1)) .-
            log.(sum(view(MCHN,:,1:1,k), dims=1)) .+
            log.(sum(view(p.Xss,itau,c)))
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
    ela = -view(p.θ, itau) .* (1.0.-(1.0.-view(p.ζ, itau)).^(1:H)') .+
        (1.0.-view(p.σ, itau)) .* (1.0.-view(p.ζ, itau)).^(1:H)' .- 1
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

function pickprices(p, itau, H, secs, shortname, dreg)
    iUSA, iCN1, iCN2 = dreg["USA"], dreg["CN1"], dreg["CN2"]
    ds = [iUSA, iCN1, iCN2]
    # Normalize the prices with domestic wage
    P = (log.(view(p.P, itau, ds, 1:H)) .-
        log.(_reshape(view(p.W, ds, 1:H), 1, length(ds), H)))[:]
    secsh = LabeledArray(repeat(itau, 3*H), getvaluelabels(secs[!,shortname]))
    S = length(itau)
    df = DataFrame((sec=secsh,
        iso3=repeat(["USA","CN1","CN2"], inner=S, outer=H),
        h=repeat(0:H-1, inner=3*S), P=P))
    return df
end

function logacr0(p, H, d)
    ηA = (I - view(p.αM,:,:,d)') \ view(p.η,:,d)
    out = zeros(H, 4)
    acrflex = view(out, :, 1)
    # Just adjusted
    dist0 = view(out, :, 2)
    # Adjusted at least once
    distk = view(out, :, 3)
    # Never adjusted
    distn = view(out, :, 4)
    for h in 1:H
        for i in 1:p.S
            acrflex[h] += ηA[i] / p.θ[i] * (log(p.λ0ss[i,d,d]) - log(p.λk[1,i,d,d,h]))
            dist0[h] += ηA[i] / (p.σ[i] - 1) * p.ζ[i] * (log(p.λk[1,i,d,d,h]) - log(p.λ[i,d,d,h]))
            distki = 0.0
            for k in 1:h-1
                distki += (1 - p.ζ[i])^k * ((p.σ[i]-1)/p.θ[i] *
                    (log(p.λk[1,i,d,d,h]) - log(p.λk[1,i,d,d,h-k])) +
                    log(p.λk[1,i,d,d,h-k]) - log(p.λ[i,d,d,h]))
            end
            distk[h] += ηA[i] / (p.σ[i] - 1) * p.ζ[i] * distki
            distn[h] += ηA[i] / (p.σ[i] - 1) * (1 - p.ζ[i])^h * ((p.σ[i]-1)/p.θ[i] *
                (log(p.λk[1,i,d,d,h]) - log(p.λ0ss[i,d,d])) +
                log(p.λ0ss[i,d,d]) - log(p.λ[i,d,d,h]))
        end
    end
    return out
end


function logacr(p, H, d)
    Am = inv(I - view(p.αM,:,:,d))
    η = view(p.η,:,d)
    out = zeros(H, 5)
    acrflex = view(out, :, 1)
    # Just adjusted
    dist0 = view(out, :, 2)
    # Adjusted at least once
    distk = view(out, :, 3)
    # Never adjusted
    distn = view(out, :, 4)
    # All distortion (exact)
    dist = view(out, :, 5)
    for h in 1:H
        for j in 1:p.S
            for i in 1:p.S
                acrflex[h] += η[j] * Am[i,j] / p.θ[i] * (log(p.λ0ss[i,d,d]) - log(p.λk[1,i,d,d,h]))
                dist0[h] += η[j] * Am[i,j] / (p.σ[i] - 1) * p.ζ[i] * (log(p.λk[1,i,d,d,h]) - log(p.λ[i,d,d,h]))
                lgdistki = 0.0
                distki = 0.0
                for k in 1:h-1
                    lgdistki += (1 - p.ζ[i])^k * ((p.σ[i]-1)/p.θ[i] *
                        (log(p.λk[1,i,d,d,h]) - log(p.λk[1,i,d,d,h-k])) +
                        log(p.λk[1,i,d,d,h-k]) - log(p.λ[i,d,d,h]))
                    distki += (1 - p.ζ[i])^k *
                        (p.λk[1,i,d,d,h]/p.λk[1,i,d,d,h-k])^((p.σ[i]-1)/p.θ[i]) *
                        p.λk[1,i,d,d,h-k]/p.λ[i,d,d,h]
                end
                distk[h] += η[j] * Am[i,j] / (p.σ[i] - 1) * p.ζ[i] * lgdistki
                distn[h] += η[j] * Am[i,j] / (p.σ[i] - 1) * (1 - p.ζ[i])^h * ((p.σ[i]-1)/p.θ[i] *
                    (log(p.λk[1,i,d,d,h]) - log(p.λ0ss[i,d,d])) +
                    log(p.λ0ss[i,d,d]) - log(p.λ[i,d,d,h]))
                dist[h] += η[j] * Am[i,j] / (p.σ[i] - 1) * log(
                    p.ζ[i] * p.λk[1,i,d,d,h] / p.λ[i,d,d,h] +
                    p.ζ[i] * distki +
                    (1 - p.ζ[i])^h * (p.λk[1,i,d,d,h]/p.λ0ss[i,d,d])^((p.σ[i]-1)/p.θ[i]) * p.λ0ss[i,d,d] / p.λ[i,d,d,h])
            end
        end
    end
    acrlr = 0.0
    for j in 1:p.S
        for i in 1:p.S
            acrlr += η[j] * Am[i,j] / p.θ[i] * (log(p.λ0ss[i,d,d]) - log(p.λ[i,d,d,end]))
        end
    end
    return out, acrlr
end


function welfare!(dres, p, H, dreg)
    iUSA, iCN1, iCN2 = dreg["USA"], dreg["CN1"], dreg["CN2"]
    acr, lr = logacr(p, H, iUSA)
    dres["lgacrUSA"] = acr
    dres["lgacrlrUSA"] = lr
    acr, lr = logacr(p, H, iCN1)
    dres["lgacrCHN"] = acr
    dres["lgacrlrCHN"] = lr
    W = cumprod(p.what, dims=2)
    dres["lgWUSA"] = log.(view(W, iUSA, :))
    dres["lgWCHN"] = log.(view(W, iCN1, :))
    dres["lgwpUSA"] = log.(view(p.w, iUSA, :))
    dres["lgwpCHN"] = log.(view(p.w, iCN1, :))
    dres["lgPfUSA"] = log.(view(p.Pf, iUSA, :))
    dres["lgPfCHN"] = log.(view(p.Pf, iCN1, :))
end

function main()
    sectag = "i32"
    S = 32
    H = 30
    parajd = readstat(iciodir*"parajd_$(sectag).dta")
    paraijd = readstat(iciodir*"paraijd_$(sectag).dta")
    paraisd = readstat(iciodir*"paraisd_$(sectag).dta")
    regs = parajd.dest_iso3[1:S:end]
    dreg = Dict(regs.=>1:length(regs))
    # Needed for setshock!
    dreg["CHN"] = dreg["CN1"]
    dreg["MEX"] = dreg["MX1"]
    secs = DataFrame(readstat(iciodir*"sectorlist.dta"))
    secs[!,:i34short] = LabeledArray(disallowmissing(unwrap.(secs[!,:i34short])),
        getvaluelabels(secs[!,:i34short]))
    mtau = DataFrame(readstat(iciodir*"mtau.dta"))
    # A work around before the issue with Missing is fixed
    mtau[!,:i34] = refarray(mtau.i34)
    disallowmissing!(mtau)
    mtau = Table(mtau)
    xtau = DataFrame(readstat(iciodir*"xtau.dta"))
    xtau[!,:i34] = refarray(xtau.i34)
    disallowmissing!(xtau)
    xtau = Table(xtau)

    # Sectors directly affected by tariffs
    itau = 1:19

    p = Problem()
    #fill!(p.ζ, 0.2)
    calibrate!(p, parajd, paraijd, paraisd, dreg)
    #p.ηG .= p.η
    setshock!(p, mtau, xtau, dreg)

    @time solve!(p);

    priceindex!(p)
    realwage!(p)

    dres = Dict{String, Any}()
    geelasticity!(dres, p, itau, H, dreg)
    peelasticity!(dres, p, itau, H, dreg)
    P1 = pickprices(p, itau, H, secs, :i32short, dreg)
    P2 = pickprices(p, 20:S, H, secs, :i32short, dreg)
    writestat(modeldir*"priceUSACHNdirect.dta", P1)
    writestat(modeldir*"priceUSACHNother.dta", P2)

    welfare!(dres, p, H, dreg)

    matwrite(modeldir*"tradewar.mat", dres, compress=true)
    return dres
end

