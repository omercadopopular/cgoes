function setF!(p::Problem, wold::AbstractArray, t::Int)
    wageold = view(wold, size(wold,1), :)
    if t == 1
        p.income .= wageold .* p.wL_ss .+ view(p.D, :, t)
    else
        p.income .= wageold .* view(p.wL, :, t-1) .+ view(p.D, :, t)
    end
    k = 1 # Counter
    for (i, d) in Base.product(1:p.S, 1:p.N)
        p.F[k] = p.income[d] * p.η[i,d]
        k += 1
    end
end

function setΩG!(p::Problem, t::Int)
    Ω = _reshape(p.Ω, p.S, p.N, p.S, p.N)
    Threads.@threads for d in 1:p.N
        for (s, j) in Base.product(1:p.N, 1:p.S)
            λ = p.λ[j,s,d]
            @inbounds for i in 1:p.S
                τ = p.τ[j,s,d,t]
                if s == d
                    λτsum = 0.0
                    for ss in 1:p.N
                        ττ = p.τ[j,ss,d,t]
                        λτsum += p.λ[j,ss,d] * (ττ - 1.0) / ττ
                    end
                    Ω[i,s,j,d] = λ * p.αM[i,j,s] / τ + p.ηG[i,s] * λτsum
                else
                    Ω[i,s,j,d] = λ * p.αM[i,j,s] / τ
                end
            end
    end
end


wLbase = t == 1 ? p.wL_ss : view(p.wL,:,t-1)
p.income .= wageold .* wLbase .+ view(p.D, :, t)

function setλ0own_tk!(p::Problem, t::Int)
    if t == 1
        @inbounds for (i, d) in Base.product(1:p.S, 1:p.N)
            p.λ0own_tk[i,d] = 1.0
        end
    else
        @inbounds for (i, d) in Base.product(1:p.S, 1:p.N)
            p.λ0own_tk[i,d] = p.P_el[i,d,1,t-1] / p.μ[i,1]
        end
    end
end

if t > 1
    init_x[1:p.S,:] .= view(p.Ps, :, :, t-1)
    init_x[end,:] .= view(p.what, :, t-1)
end

Plag = t-1 > 0 ? p.P_el[i,d,1,t-1]/ p.μ[i,1] : 1

function _setprice!(p::Problem, d::Int, t::Int)
    # k = 1 is handled separately
        @inbounds for (i, k) in Base.product(1:p.S, 2:p.K)
            λk_sum = p.λk_sum[i,d,k]
            if λk_sum > 0
                Plag = t-k+1 > 0 ? p.P_el[i,d,1,t-k+1]/ p.μ[i,1] : 1
                P_el = p.μ[i,k] * Plag * λk_sum
                p.P_el[i,d,k,t] = P_el
                p.Ps[i,d,t] += P_el
            else
                p.P_el[i,d,k,t] = 0.0
            end
        end
end

function solveX2!(p::Problem, t::Int)
    ldiv!(view(p.X,:,t), lu!(p.ΩG_I), view(p.F, :, t))
end


secs = DataFrame(readstat(iciodir*"sectorlist.dta"))
    sec32 = unique!(secs[1:45, [:i32,:i34]])
    mtau = DataFrame(readstat(iciodir*"mtau.dta"))
    xtau = DataFrame(readstat(iciodir*"xtau.dta"))
    mtau32 = leftjoin(mtau, sec32, on=:i34)

# Imports do not include the increased tariffs
    # For the last dimension, the three slices are for CHN (total), CN1 and CN2
    dlgMUSA = zeros(1, H, 3)
    dlgMUSA[:,:,1] .= log.(sum(view(MUSA,:,2:H+1,:), dims=(1,3))) .-
        log.(sum(view(MUSA,:,1:1,:), dims=(1,3)))
    dlgMUSA[:,:,2:3] .= log.(sum(view(MUSA,:,2:H+1,:), dims=1)) .-
        log.(sum(view(MUSA,:,1:1,:), dims=1))
    dlgMCHN = zeros(1, H, 3)
    dlgMCHN[:,:,1] .= log.(sum(view(MCHN,:,2:H+1,:), dims=(1,3))) .-
        log.(sum(view(MCHN,:,1:1,:), dims=(1,3)))
    dlgMCHN[:,:,2:3] .= log.(sum(view(MCHN,:,2:H+1,:), dims=1)) .-
        log.(sum(view(MCHN,:,1:1,:), dims=1))


function _settradeshare_k!(p::Problem, d::Int, t::Int)
    @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
        qhat = p.qhat[i,s,t]
        # Handle k = 1 separately
        λ0 = getλ0_tk(p, 1, i, s, d, t)
        if λ0 > 0
            λk_el = (p.qhat_tk[1,i,s,d] * qhat)^(-p.θ[i]) * λ0
            p.λk_el[1,i,s,d] = λk_el
            p.λksum[1,i,d] += λk_el
            for k in 2:min(p.K, t+1)
                λ0k = getλ0_tk(p, k, i, s, d, t)
                λk_el = (p.qhat_tk[k,i,s,d] * qhat)^(1-p.σ[i]) * λ0k
                p.λk_el[k,i,s,d] = λk_el
                p.λksum[k,i,d] += λk_el
            end
        else
            p.λk_el[:,i,s,d] .= 0.0
        end
    end
    @inbounds for (k, i) in Base.product(1:min(p.K, t+1), 1:p.S)
        λksum = p.λksum[k,i,d]
        if λksum > 0
            for s in 1:p.N
                p.λk[k,i,s,d,t] = p.λk_el[k,i,s,d] / λksum
            end
        else
            p.λk[k,i,s,d,t] = 0.0
        end
    end
end

function getλ0el_tk(p::Problem, k::Int, i::Int, s::Int, d::Int, t::Int)
    if t == 1 || k > t
        return p.λ0ss[i,s,d]
    elseif k == 1
        return p.λ0_el[i,s,d,t-1]
    else
        return p.λk[1,i,s,d,t-k+1]
    end
end


function plotrealwage(dres, H, fname)
    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title="US")
    x = 0:H-1
    ax1.xticks = 0:2:H-1
    col1, col2, col3 = Paired_8[[8,2,4]]
    lw1 = 2
    l1 = lines!(ax1, x, 100*view(dres["lgwpUSA"],1:H), color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*view(dres["lgWUSA"],1:H), color=col2, linestyle=:dash)
    l3 = lines!(ax1, x, 100*view(dres["lgPfUSA"],1:H), color=col3, linestyle=:dot)
    ax2 = Axis(f1[1, 2], xlabel="Year", title="China")
    ax2.xticks = 0:2:H-1
    l1 = lines!(ax2, x, 100*view(dres["lgwpCHN"],1:H), color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*view(dres["lgWCHN"],1:H), color=col2, linestyle=:dash)
    l3 = lines!(ax2, x, 100*view(dres["lgPfCHN"],1:H), color=col3, linestyle=:dot)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash),
        LineElement(color=col3, linestyle=:dot)]
    Legend(f1[2,1:2], ls, ["Real Wage", "Wage", "Aggregate Price"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(fig*"$fname.pdf", f1, pt_per_unit=1)
    return f1
end

function barprice(P, iso3, hlr, vertical::Bool, fname)
    f = Figure(; size= 72 .* (2*halfwidth, 3.5));
    secs = unique(P.i34short)
    S = length(secs)
    df = P[P.iso3.==iso3,:]
    _max(x) = maximum(abs, x)
    transform!(groupby(df,[:i34short,:iso3]), :dP=>_max=>:dPmax)

    if vertical
        df[!,:dodge] = ifelse.(df.h.==1, 1, ifelse.(df.h.==4, 3,
            ifelse.(df.h.==hlr, 5, -1))) # ifelse.(df.dP.==df.dPmax, 2,
        df = df[df.dodge.>0,:]
        cols = [Paired_8[2], 1, Paired_8[8], 1, Paired_8[4]]
        colors = getindex.(Ref(cols), df.dodge);
        ax = Axis(f[1,1], xticks = (1:S, valuelabels(secs)), xticklabelrotation=π/5,
            ylabel = "Price Index Relative to Initial Level (%)")
        barplot!(ax, refarray(df.i34short), df.dP, dodge=df.dodge, color=colors,
            direction=:y, label_size=11, gap=0.4)
        elements = [PolyElement(polycolor=cols[i]) for i in 1:2:5]
    else
        df[!,:dodge] = ifelse.(df.h.==1, 5, ifelse.(df.h.==4, 3,
            ifelse.(df.h.==hlr, 1, -1))) # ifelse.(df.dP.==df.dPmax, 2,
        df = df[df.dodge.>0,:]
        cols = [Paired_8[4], 1, Paired_8[8], 1, Paired_8[2]]
        colors = getindex.(Ref(cols), df.dodge);
        # The index for plot goes in the reverse order
        ax = Axis(f[1,1], yticks = (S:-1:1, valuelabels(secs)),
            xlabel = "Price Index Relative to Initial Level (%)")
        barplot!(ax, (S+1).-refarray(df.i34short), df.dP, dodge=df.dodge, color=colors,
            direction=:x, label_size=11, gap=0.4)
        elements = [PolyElement(polycolor=cols[i]) for i in 5:-2:1]
    end
    #=axislegend(ax,  elements, ["1", "4", string(hlr)], "Horizon", position=:rt,
        titleposition=:left, titlegap=10, nbanks=3, patchsize = (20,3))=#
    #=Legend(f[2,1], elements, ["1", "4", string(hlr)],
        "Horizon", tellheight=true, tellwidth=false,
        titleposition=:left, titlegap=10, nbanks=3, patchsize = (20,3))=#
    Legend(f[1,2], elements, ["1", "4", string(hlr-1)],
        "Horizon", tellheight=false, tellwidth=true,
        titleposition=:top, titlegap=10, nbanks=1, patchsize = (15,3))
    colgap!(f.layout, Relative(0.02))
    save(fig*"$fname.pdf", f, pt_per_unit=1)
    return f
end

    #barprice(P, "USA", 15, true, "priceUSA")
    #barprice(P, "CN1", 15, true, "priceCN1")
    #barprice(P, "CN2", 15, true, "priceCN2")


# Need to pick a numeraire for all prices
p.what[:,t] ./= p.what[1,t]
for s in 1:p.N
    @inbounds for i in 1:p.S
        wdiff[i,s] = p.Ps[i,s,t] - wold[i,s]
    end
    @inbounds wdiff[end,s] = p.what[s,t] - wold[end,s]
end

    # p.w .= p.w.^(view(sum(p.η, dims=1), :))


    function priceindex!(p::Problem)
        p.P .= p.Ps.^(1.0./(1.0 .- p.σ))
        for (d, t) in Base.product(1:p.N, 1:p.T)
            pf = 1.0
            @inbounds for j in 1:p.S
                pf *= p.P[j,d,t]^p.η[j,d]
            end
            p.Pf[d,t] = pf
        end
    end
    
    function realwage!(p::Problem)
        cumsum!(p.W, log.(p.what), dims=2)
        # Require sum(p.η, dims=1) being 1
        p.w .= p.W .- log.(p.Pf)
    end
    

    julia> log.(p.w[77,:])
10-element Vector{Float64}:
 -0.0007234856713561603
 -0.0017864217252584692
 -0.0023522381304380206
 -0.0023486084323507414
 -0.002344975403447935
 -0.002341339021947005
 -0.0023376992847281668
 -0.002334056188663925
 -0.0023304097144401046
 -0.002326759872273688


 julia> p.w[77,:]
 10-element Vector{Float64}:
  -0.0007234856713561162
  -0.0017864217252590233
  -0.0023522381304384096
  -0.002348608432350453
  -0.0023449754034479977
  -0.002341339021946358
  -0.0023376992847284847
  -0.0023340561886643343
  -0.0023304097144404004
  -0.002326759872274659

  julia> p.w[77,:]
10-element Vector{Float64}:
 -0.0007234856713560815
 -0.0017864217252590998
 -0.0023522381304381616
 -0.0023486084323502635
 -0.0023449754034481182
 -0.0023413390219463406
 -0.002337699284728338
 -0.0023340561886640437
 -0.0023304097144402937
 -0.0023267598722743824


 julia> p.w[77,:]
 30-element Vector{Float64}:
  -0.000723485775457254
  -0.0017864216735578719
  -0.0023522381865958
  -0.002348608313829393
  -0.0023449752081181993
  -0.0023413387471978467
  -0.002337698927240736
  -0.002334055744413316
  -0.002330409194877107
  -0.0023267592747896436
  -0.0023231059803031674
  -0.0023194493075636667
  -0.00231578925271257
  -0.0023121258118880736
  -0.0023084589812200694
  -0.002304788756835589
  -0.002301115134855245
  -0.002297438111394287
  -0.002293757682563758
  -0.002290074073776981
  -0.0022863869116483493
  -0.0022826963322403982
  -0.0022790023316155436
  -0.0022753049058308766
  -0.0022716040509386764
  -0.002267899762985402
  -0.002264192038014009
  -0.002260480872060063
  -0.0022567662611554344
  -0.002253048201327107


  for s in 1:p.N
    @inbounds for i in 1:p.S
        wdiff[i,s] = log(p.Ps[i,s,t]) - log(wold[i,s])
    end
    # The last term is a numeraire for all prices
    @inbounds wdiff[end,s] = log(p.what[s,t]) - log(wold[end,s])# - log(p.what[77,t]) + log(wold[end,77])
end

# Require sum(p.η, dims=1) being 1

# Need to change the sign of ΩG_I
function solveX2!(p::Problem, t::Int)
    ldiv!(view(p.X,:,t), lu!(p.ΩG_I), view(p.F, :, t))
end

    #p = Problem(T=H, verbosew=true, histw1=1, betaw2=0.3, betaw3=0.3, tolw=1e-8)


    function logacr!(out, rr, Am, am, Id, p, H, d)
        # Skip the computation if any domestic share is zero
        any(==(0), view(p.λ0ss,:,d,d)) && return nothing
        am .= Id .- view(p.αM,:,:,d)
        # All allocations are from qr!
        ldiv!(Am, qr!(am), Id)
        # Final use expenditure shares do not sum up to 1 because of tax
        ηs = sum(view(p.η, :, d))
        η = view(p.η,:,d) ./ ηs
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
        out[6][rr] .= acrlr
        out[7][rr] .= ηs
        return out
    end

    #=@inbounds for i in 1:p.S
        Υ = p.Υ[i,d,t]
        if Υ > 0
            for s in 1:p.N
                p.υ[i,s,d,t] /= Υ
            end
        end
    end=#

    struct Obj{P<:Problem, F}
        p::P
        f::F
        t::Int
    end
    
    (o::Obj)(out, x) = o.f(o.p, out, x, o.t)


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
        # Adjusted at least once
        distk = view(out[3], rr)
        # Never adjusted
        distn = view(out[4], rr)
        for h in 1:H
            for i in 1:p.S
                σθ = (p.σ[i] - 1)/p.θ[i] - 1
                acrflex[h] += Am[i] / p.θ[i] * (log(p.λ0ss[i,d,d]) - log(p.λ[i,d,d,h]))
                lgdistki = 0.0
                distki = 0.0
                for k in 0:h-1
                    lgdistki += (1 - p.ζ[i])^k * σθ * (log(p.λ[i,d,d,h]) - log(p.υ[i,d,d,h-k]))
                    distki += (1 - p.ζ[i])^k * (p.λ[i,d,d,h] / p.λk[1,i,d,d,h-k])^σθ
                end
                distk[h] += Am[i] / (p.σ[i] - 1) * p.ζ[i] * lgdistki
                distn[h] += Am[i] / (p.σ[i] - 1) * (1 - p.ζ[i])^h * σθ * (log(p.λ[i,d,d,h]) - log(p.λ0ss[i,d,d]))
                dist[h] += Am[i] / (p.σ[i] - 1) * log(
                    p.ζ[i] * distki +
                    (1 - p.ζ[i])^h * (p.λ[i,d,d,h] / p.λ0ss[i,d,d])^σθ)
            end
        end
        out[5][rr] .= ηs
        return out
    end


for d in 1:p.N
        λτsum = 0.0
        for s in 1:p.N
            τ = p.τ[1,s,d,1]
            λτsum += p.λ0ss[1,s,d] * (τ - 1.0) / τ
        end
        p.wLss[d] -= λτsum * p.Xss[1,d]
    end



    for d in 1:p.N
        λτsum = 0.0
        for s in 1:p.N
            τ = p.τ[1,s,d,1]
            λτsum += p.λ0ss[1,s,d] * (τ - 1.0) / τ
        end
        p.D[d] -= λτsum * p.Xss[1,d]
    end


function setprofit!(p::Problem, t::Int)
    if t > 1
        Threads.@threads for d in 1:p.N
            @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
                if p.λ0ss[i,s,d] > 0
                    σ = p.σ[i]
                    # Ψcache is for the term added in last period to the denominator
                    if t == p.T - 1 # Handle initial value for Ψcache
                        Ψcache = (p.τhat[i,s,d,end] * p.qhat[i,s,end])^(1-σ) *
                            (p.Ps[i,d,end]/p.Ps[i,d,end-1])^(σ/(1-σ)) *
                            p.X[i+p.S*(d-1),end]/p.X[i+p.S*(d-1),end-1] / p.Pf[d,end]
                    else
                        Ψcache = p.sc.Ψcache[i,s,d]
                    end
                    # The term for the last period is not in Ψsum2
                    # to make the number of terms for summation identical
                    p.sc.Ψsum1[i,s,d] = Ψsum1 =
                        p.sc.βf[i] * (1 - p.ζ[i]) * Ψcache * (1 + p.sc.Ψsum1[i,s,d])
                    # Ps contains P^(1-σ) instead of P
                    Ψcache = (p.τhat[i,s,d,t] * p.qhat[i,s,t])^(1-σ) *
                        (p.Ps[i,d,t]/p.Ps[i,d,t-1])^(σ/(1-σ)) *
                        p.X[i+p.S*(d-1),t]/p.X[i+p.S*(d-1),t-1] / p.Pf[d,t]
                    p.sc.Ψsum2[i,s,d] = Ψsum2 =
                        p.sc.βf[i] * (1 - p.ζ[i]) * Ψcache * (1 + p.sc.Ψsum2[i,s,d])
                    p.sc.Ψcache[i,s,d] = Ψcache
                    p.sc.Ψ[i,s,d,t] = (1 + p.Pf[d,t]*Ψsum1) / (1 + p.Pf[d,t-1]*Ψsum2)
                end
            end
        end
    else
        Threads.@threads for d in 1:p.N
            @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
                if p.λ0ss[i,s,d] > 0
                    σ = p.σ[i]
                    # Ψcache is for the term added in last period to the denominator
                    if t == p.T - 1 # Handle initial value for Ψcache
                        Ψcache = (p.τhat[i,s,d,end] * p.qhat[i,s,end])^(1-σ) *
                            (p.Ps[i,d,end]/p.Ps[i,d,end-1])^(σ/(1-σ)) *
                            p.X[i+p.S*(d-1),end]/p.X[i+p.S*(d-1),end-1] / p.Pf[d,end]
                    else
                        Ψcache = p.sc.Ψcache[i,s,d]
                    end
                    # The term for the last period is not in Ψsum2
                    # to make the number of terms for summation identical
                    p.sc.Ψsum1[i,s,d] = Ψsum1 =
                        p.sc.βf[i] * (1 - p.ζ[i]) * Ψcache * (1 + p.sc.Ψsum1[i,s,d])
                    # Ps contains P^(1-σ) instead of P
                    Ψcache = (p.τhat[i,s,d,t] * p.qhat[i,s,t])^(1-σ) *
                        (p.Ps[i,d,t])^(σ/(1-σ)) * p.X[i+p.S*(d-1),t]/p.Xss[i,d] / p.Pf[d,t]
                    p.sc.Ψsum2[i,s,d] = Ψsum2 =
                        p.sc.βf[i] * (1 - p.ζ[i]) * Ψcache * (1 + p.sc.Ψsum2[i,s,d])
                    p.sc.Ψcache[i,s,d] = Ψcache
                    p.sc.Ψ[i,s,d,t] = (1 + p.Pf[d,t]*Ψsum1) / (1 + Ψsum2)
                end
            end
        end
    end

    
function setprofit!(p::Problem, t::Int)
    Threads.@threads for d in 1:p.N
        for (i, s) in Base.product(1:p.S, 1:p.N)
            if p.λ0ss[i,s,d] > 0
                for k in 2:t+1
                    b = p.sc.βf[i] * (1 - p.ζ[i])
                    p.sc.Ψsum1[i,s,d,1] += b / p.Pf[d,t] *
                        p.Qs_el[k,i,s,d,t] / (p.λ0ss[i,s,d]*p.μ[k,i]) *
                        p.X[i+p.S*(d-1),t] / p.Xss[i,d]
                    for tp in 2:t-k+2
                        b *= p.sc.βf[i] * (1 - p.ζ[i])
                        temp = b / p.Pf[d,t] * p.Pf[d,tp-1] *
                            p.Qs_el[k,i,s,d,t] / p.Qs_el[1,i,s,d,tp-1] *
                            p.X[i+p.S*(d-1),t] / p.X[i+p.S*(d-1),tp-1]
                        p.sc.Ψsum1[i,s,d,tp] += temp
                        if tp < t-k+2
                            p.sc.Ψsum2[i,s,d,tp] += temp
                        end
                    end
                end
            end
        end
    end
end

b *= p.sc.βf[i] * (1 - p.ζ[i])
                    temp = b / p.Pf[d,t] *
                            p.Qs_el[t+1,i,s,d,t] / (p.λ0ss[i,s,d]*p.μ[t+1,i]) *
                            p.X[i+p.S*(d-1),t] / p.Xss[i,d]
                    if t < p.T
                        p.sc.Ψsum1[i,s,d,1] += temp
                    else
                        p.sc.Ψsum2[i,s,d] += temp
                    end

                    function setprofitratio!(p::Problem, t::Int)
                        if t > 1
                            Threads.@threads for d in 1:p.N
                                @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
                                    p.sc.Ψ[i,s,d,t] = (1 + p.sc.Ψsum1[i,s,d,t]+p.sc.Ψsum2[i,s,d]) / (1 + p.sc.Ψsum1[i,s,d,t-1])
                                end
                            end
                        else
                            Threads.@threads for d in 1:p.N
                                for i in 1:p.S
                                    Ψsum0 = (1 - (p.sc.βf[i] * (1 - p.ζ[i]))^(p.T+1)) /
                                        (1 - (p.sc.βf[i] * (1 - p.ζ[i])))
                                    @inbounds for s in 1:p.N
                                        p.sc.Ψ[i,s,d,t] = (1 + p.sc.Ψsum1[i,s,d,t]+p.sc.Ψsum2[i,s,d]) / Ψsum0
                                    end
                                end
                            end
                        end
                    end


                    function setprofit!(p::Problem, t::Int)
                        if t > 1
                            Threads.@threads for d in 1:p.N
                                for (i, s) in Base.product(1:p.S, 1:p.N)
                                    if p.λ0ss[i,s,d] > 0
                                        b = 1.0
                                        for k in 2:t
                                            b *= p.sc.βf[i] * (1 - p.ζ[i])
                                            tp = t - k + 1
                                            temp = b / p.Pf[d,t] * p.Pf[d,tp] *
                                                    p.Qs_el[k,i,s,d,t] / p.Qs_el[1,i,s,d,tp] *
                                                    p.X[i+p.S*(d-1),t] / p.X[i+p.S*(d-1),tp]
                                            if t < p.T
                                                p.sc.Ψsum1[i,s,d,tp] += temp
                                            else
                                                p.sc.Ψsum2[i,s,d,tp] += temp
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    function setprofitratio!(p::Problem, t::Int)
                        if t < p.T
                            Threads.@threads for d in 1:p.N
                                @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
                                    p.sc.Ψ[i,s,d,t] = (1 + p.sc.Ψsum1[i,s,d,t]+p.sc.Ψsum2[i,s,d,t]) / (1 + p.sc.Ψsum1[i,s,d,t-1])
                                end
                            end
                        end
                    end
            


                    function setcost!(p::Problem{CobbDouglasTech,<:Any,NoIO},
                        wold::AbstractArray, t::Int)
                    for d in 1:p.N
                        if d == p.N
                            w = (sum(p.wLss) - sum(view(p.wLss,1:p.N-1).*wold)) / p.wLss[end]
                        else
                            w = wold[end,d]
                        end
                        for j in 1:p.S
                            @inbounds p.qhat[j,d,t] = w
                        end
                    end
                end



                function setF!(p::Problem{<:Any,<:Any,NoIO}, wold::AbstractArray, t::Int)
                    wageold = view(wold, size(wold,1), :)
                    #p.income[1] = p.wLss[1] + p.D[1,t]
                    p.income[end] = sum(p.wLss) + p.D[end,t] - wageold .* view(p.wLss, 1:p.N-1)
                    if t == 1
                        p.income .= wageold .* view(p.wLss, 1:p.N-1) .+ view(p.D, 1:p.N-1, t)
                    else
                        p.income .= wageold .* view(p.wL, 1:p.N-1, t-1) .+ view(p.D, 1:p.N-1, t)
                    end
                    F = _reshape(view(p.F, :, t), p.S, p.N)
                    F .= p.income' .* p.η
                end





function wLdiffscale!(p::Problem{<:Any, <:MaxPresentValue}, Xsc)
    t = 1
    F = view(p.F,:,1)
    @show p.sc.Xscale[] = Xsc
    F = view(p.F,:,1)
    Xss = _reshape(p.Xss, p.S*p.N)
    fill!(F, 0)
    mul!(F, p.ΩG_I, Xss, -p.sc.Xscale[], 1.0)

    F = _reshape(F, p.S, p.N)
    for d in 1:p.N
        inc = 0.0
        for j in 1:p.S
            inc += F[j,d]
        end
        inc /= sum(view(p.η, :, d))
        for j in 1:p.S
            p.sc.Fadj[j,d] = F[j,d] - inc * p.η[j,d]
        end
        p.wLss[d] = inc - p.D[d,1]
    end
    p.X[:,1] .= view(p.Xss,:) .* p.sc.Xscale[]
    setY!(p, 1)

    fill!(view(p.wL, :, t), 0.0)
    @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
        p.wL[s,t] += p.α[i,s] * p.Y[i,s,t]
    end
    # Handle special regions where factor income needs to be aggregated
    for (s, d) in pairs(p.wLshift)
        if s != d
            p.wL[d,t] += p.wL[s,t]
            p.wL[s,t] = 0.0
        end
    end
    diffwL = 0.0
    for s in 1:p.N
        diffwL += (p.wL[s,1] - p.wLss[s])^2
    end
    return diffwL
end


function dprofit!(p::Problem{<:Any, <:MaxPresentValue})
    p.sc.dΠ .= log.(p.sc.Π) .- log.(sum(reshape(p.Xss, p.S, p.N) ./ p.σ, dims=1)') .-
        log.(p.Pf) ./ view(sum(p.η, dims=1),:)
end





function wLdiffscale!(p::Problem{<:Any, <:MaxPresentValue}, Xsc)
    t = 1
    F = view(p.F,:,1)
    @show p.sc.Xscale[] = Xsc
    F = view(p.F,:,1)
    Xss = _reshape(p.Xss, p.S*p.N)
    fill!(F, 0)
    mul!(F, p.ΩG_I, Xss, -p.sc.Xscale[], 1.0)

    F = _reshape(F, p.S, p.N)
    for d in 1:p.N
        inc = p.wLss[d] + p.D[d,1]
        for j in 1:p.S
            p.sc.Fadj[j,d] = F[j,d] - inc * p.η[j,d]
        end
    end
    p.X[:,1] .= view(p.Xss,:) .* p.sc.Xscale[]
    setY!(p, 1)

    fill!(view(p.wL, :, t), 0.0)
    @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
        p.wL[s,t] += p.α[i,s] * p.Y[i,s,t]
    end
    # Handle special regions where factor income needs to be aggregated
    for (s, d) in pairs(p.wLshift)
        if s != d
            p.wL[d,t] += p.wL[s,t]
            p.wL[s,t] = 0.0
        end
    end
    diffwL = 0.0
    for s in 1:p.N
        diffwL += (p.wL[s,1] - p.wLss[s])^2
    end
    return diffwL
end

function reconcile!(p::Problem{<:Any, <:MaxPresentValue}, Xsc;
        solverargs=((0.1, 0.9), Roots.Brent()))
    # Ensure no shock is set
    fill!(p.τhat, 1)
    fill!(p.qhat_tk, 1)
    fill!(p.winit, 1)
    t = 1
    setcost!(p, p.winit, t)
    settradeshare_k!(p, t)
    setchoice!(p, t)
    setprice!(p, t)
    settradeshare!(p, t)
    any(>(0), p.ηG) && setGcache!(p, t)
    setΩG_I!(p, t)
    #f(x, g) = wLdiffscale!(p, x[1])
    #p.sc.Xscale[] = find_zero(f, solverargs...)
    #=opt = NLopt.Opt(:LN_COBYLA, 1)
    NLopt.lower_bounds!(opt, [0.5])
    NLopt.upper_bounds!(opt, [1.0])
    NLopt.min_objective!(opt, f)
    sol = [0.8]
    NLopt.optimize!(opt, sol)
    p.sc.Xscale[] = sol[1]
    =#
    #for k in 1:5
        @show wLdiffscale!(p, Xsc)
        p.wLss .+= view(p.wL, :, 1) .- p.wLss
        p.D .-= (view(p.wL, :, 1) .- p.wLss)
    #end
    @show wLdiffscale!(p, Xsc)
    #wLdiffscale!(p, Xsc)

    #p.Xss .*= p.sc.Xscale[]
end


function plottariff(dmtau, dxtau, fname)
    H = length(dmtau)
    f1 = Figure(; size=72 .* (1.1halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="Change in Average Tariff (%)")
    x = 0:H-1
    ax1.xticks = 0:2:H-1
    col1, col2 = Paired_8[8], Paired_8[2]
    lw1, lw2 = 2, 2
    l1 = lines!(ax1, x, dmtau, color=col1, linewidth=lw1, label="US Tariffs on China")
    l2 = lines!(ax1, x, dxtau, color=col2, linestyle=:dash, linewidth=lw2,
        label="Retaliatory Tariffs on US")
    axislegend(ax1, position=:rb)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"$fname.pdf"), f1, pt_per_unit=1)
    return f1
end


wm = view(mtau, mtau.iso3.=="CHN", :val)
    wm ./= sum(wm)
    dmtau = [sum(wm .* view(mtau,mtau.iso3.=="CHN",n)) for n in (:tau18, :tau19, :taumax19)]
    dmtau .= 100 .* (dmtau .- 1)
    wx = view(xtau, xtau.iso3.=="CHN", :val)
    wx ./= sum(wx)
    dxtau = [sum(wx .* view(xtau,xtau.iso3.=="CHN",n)) for n in (:tau18, :tau19, :taumax19)]
    dxtau .= 100 .* (dxtau .- 1)
    resize!(dmtau, H)
    resize!(dxtau, H)
    for i in 4:H
        dmtau[i] = dmtau[3]
        dxtau[i] = dxtau[3]
    end
    plottariff(dmtau, dxtau, "tradewaraggtau")