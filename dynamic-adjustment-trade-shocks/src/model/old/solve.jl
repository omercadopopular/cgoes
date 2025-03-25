function setcost!(p::Problem{CobbDouglasTech,<:Any,WithIO},
        wold::AbstractArray, t::Int)
    # Need ratios between adjacent periods
    Pshat = t == 1 ? wold : (p.Pshat .= view(wold,1:p.S,:) ./ view(p.Ps,:,:,t-1))
    Threads.@threads for d in 1:p.N
        for j in 1:p.S
            @inbounds p.qhat[j,d,t] = wold[end,d]^p.α[j,d]
            for i in 1:p.S
                αM = p.αM[i,j,d]
                if αM > 0
                    # Need 1-σ because wold contains P^(1-σ) instead of P
                    @inbounds p.qhat[j,d,t] *= Pshat[i,d]^(αM/(1.0.-p.σ[i]))
                end
            end
        end
    end
end

function setcost!(p::Problem{CobbDouglasTech,<:Any,NoIO},
        wold::AbstractArray, t::Int)
    for d in 1:p.N-1
        w = wold[end,d]
        for j in 1:p.S
            @inbounds p.qhat[j,d,t] = w
        end
    end
end

function _settradeshare_k!(p::Problem{<:Any, <:MinCurrentCost}, d::Int, t::Int)
    @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
        qhat = p.qhat[i,s,t]
        # Handle k = 1 separately
        λ0el = t == 1 ? p.λ0ss[i,s,d] : p.λ0_el[i,s,d,t-1]
        if λ0el > 0
            λk_el = (p.qhat_tk[1,i,s,d] * qhat)^(-p.θ[i]) * λ0el
            p.λk_el[1,i,s,d] = λk_el
            # The level of λ0_el (instead of just the shares) matters for prices
            p.λ0_el[i,s,d,t] = λk_el
            p.λksum[1,i,d] += λk_el
            for k in 2:min(p.K, t+1)
                λ0k = k > t ? p.λ0ss[i,s,d] : p.λk[1,i,s,d,t-k+1]
                λk_el = (p.qhat_tk[k,i,s,d] * qhat)^(1-p.σ[i]) * λ0k
                p.λk_el[k,i,s,d] = λk_el
                p.λksum[k,i,d] += λk_el
            end
        else
            p.λk_el[:,i,s,d] .= 0.0
            p.λ0_el[i,s,d,t] = 0.0
        end
    end
    @inbounds for (k, i) in Base.product(1:min(p.K, t+1), 1:p.S)
        λksum = p.λksum[k,i,d]
        if λksum > 0
            for s in 1:p.N
                p.λk[k,i,s,d,t] = p.λk_el[k,i,s,d] / λksum
            end
        else
            p.λk[k,i,:,d,t] .= 0.0
        end
    end
end

function _settradeshare_k!(p::Problem{<:Any, <:MaxPresentValue}, d::Int, t::Int)
    @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
        qhat = p.qhat[i,s,t]
        # Handle k = 1 separately
        λ0el = t == 1 ? p.λ0ss[i,s,d] : p.λ0_el[i,s,d,t-1]
        σ, θ = p.σ[i], p.θ[i]
        if λ0el > 0
            λk_el = λ0el * (p.qhat_tk[1,i,s,d] * qhat)^(-θ) *
                p.sc.Ψ[i,s,d,t]^(θ/(σ-1)-1)
            p.λk_el[1,i,s,d] = λk_el
            # The level of λ0_el (instead of just the shares) matters for prices
            p.λ0_el[i,s,d,t] = λk_el
            p.λksum[1,i,d] += λk_el
            for k in 2:min(p.K, t+1)
                λ0k = k > t ? p.λ0ss[i,s,d] : p.λk[1,i,s,d,t-k+1]
                λk_el = (p.qhat_tk[k,i,s,d] * qhat)^(1-σ) * λ0k
                p.λk_el[k,i,s,d] = λk_el
                p.λksum[k,i,d] += λk_el
            end
        else
            p.λk_el[:,i,s,d] .= 0.0
            p.λ0_el[i,s,d,t] = 0.0
        end
    end
    @inbounds for (k, i) in Base.product(1:min(p.K, t+1), 1:p.S)
        λksum = p.λksum[k,i,d]
        if λksum > 0
            for s in 1:p.N
                p.λk[k,i,s,d,t] = p.λk_el[k,i,s,d] / λksum
            end
        else
            p.λk[k,i,:,d,t] .= 0.0
        end
    end
end

function settradeshare_k!(p::Problem, t::Int)
    fill!(p.λksum, 0.0)
    Threads.@threads for d in 1:p.N
        _settradeshare_k!(p, d, t)
    end
end

setchoice!(p::Problem{<:Any, <:MinCurrentCost}, t::Int) = nothing

function _setchoice!(p::Problem{<:Any, <:MaxPresentValue}, d::Int, t::Int)
    @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
        qhat = p.qhat[i,s,t]
        # Handle k = 1 separately
        υel = t == 1 ? p.λ0ss[i,s,d] : p.sc.υ[i,s,d,t-1]
        σ, θ = p.σ[i], p.θ[i]
        if υel > 0
            p.sc.υ[i,s,d,t] = υ = υel * (p.τhat[i,s,d,t] * qhat)^(-θ) *
                p.sc.Ψ[i,s,d,t]^(θ/(σ-1))
            p.sc.Υ[i,d,t] += υ
        else
            p.sc.υ[i,s,d,t] = 0.0
        end
    end
end

function setchoice!(p::Problem{<:Any, <:MaxPresentValue}, t::Int)
    fill!(view(p.sc.Υ,:,:,t), 0.0)
    Threads.@threads for d in 1:p.N
        _setchoice!(p, d, t)
    end
end

function _setprice!(p::Problem{<:Any, <:MinCurrentCost}, d::Int, t::Int)
    # k = 1 is handled separately
    @inbounds for i in 1:p.S
        λksum1 = p.λksum[1,i,d]
        if λksum1 > 0
            μ1 = p.μ[1,i]
            μsum = μ1
            P_el = μ1 * λksum1^((p.σ[i]-1)/p.θ[i])
            p.P_el[1,i,d,t] = P_el
            p.Ps[i,d,t] += P_el
            for k in 2:min(p.K, t+1)
                μ = p.μ[k,i]
                # The last k abosrbs all remaining μ for price index
                k == min(p.K, t+1) && (μ = 1.0 - μsum)
                μsum += μ # Must come after
                P0 = k<=t ? p.P_el[1,i,d,t-k+1] / μ1 : 1.0
                P_el = μ * P0 * p.λksum[k,i,d]
                p.P_el[k,i,d,t] = P_el
                p.Ps[i,d,t] += P_el
            end
        else
            p.P_el[:,i,d,t] .= 0.0
        end
    end
end

function _setprice!(p::Problem{<:Any, <:MaxPresentValue}, d::Int, t::Int)
    # k = 1 is handled separately
    @inbounds for i in 1:p.S
        λksum1 = p.λksum[1,i,d]
        if λksum1 > 0
            μ1 = p.μ[1,i]
            μsum = μ1
            P_el = μ1 * p.sc.Υ[i,d,t]^((p.σ[i]-1)/p.θ[i]-1) * λksum1
            p.P_el[1,i,d,t] = P_el
            p.Ps[i,d,t] += P_el
            for k in 2:min(p.K, t+1)
                μ = p.μ[k,i]
                # The last k abosrbs all remaining μ for price index
                k == min(p.K, t+1) && (μ = 1.0 - μsum)
                μsum += μ # Must come after
                P0 = k<=t ? p.P_el[1,i,d,t-k+1] / μ1 : 1.0
                P_el = μ * P0 * p.λksum[k,i,d]
                p.P_el[k,i,d,t] = P_el
                p.Ps[i,d,t] += P_el
            end
        else
            p.P_el[:,i,d,t] .= 0.0
        end
    end
end

function setprice!(p::Problem, t::Int)
    fill!(view(p.Ps, :, :, t), 0.0)
    # Partition by d to allow summming across k
    Threads.@threads for d in 1:p.N
        _setprice!(p, d, t)
    end
end

function _settradeshare!(p::Problem, d::Int, t::Int)
    @inbounds for (k, i, s) in Base.product(1:min(p.K, t+1), 1:p.S, 1:p.N)
        Ps = p.Ps[i,d,t]
        if Ps > 0
            Qs_el = p.P_el[k,i,d,t] / Ps * p.λk[k,i,s,d,t]
            p.Qs_el[k,i,s,d,t] = Qs_el
            p.λ[i,s,d,t] += Qs_el
        else
            p.Qs_el[k,i,s,d,t] = 0.0
        end
    end
end

function settradeshare!(p::Problem, t::Int)
    fill!(view(p.λ, :, :, :, t), 0.0)
    Threads.@threads for d in 1:p.N
        _settradeshare!(p, d, t)
    end
end

function setF!(p::Problem{<:Any,<:Any,WithIO}, wold::AbstractArray, t::Int)
    wageold = view(wold, size(wold,1), :)
    if t == 1
        p.income .= wageold .* p.wLss .+ view(p.D, :, t)
    else
        p.income .= wageold .* view(p.wL, :, t-1) .+ view(p.D, :, t)
    end
    F = _reshape(view(p.F, :, t), p.S, p.N)
    F .= p.income' .* p.η
    if p.sc isa MaxPresentValue
        F .+= p.sc.Fadj
    end
end

function setF!(p::Problem{<:Any,<:Any,NoIO}, wold::AbstractArray, t::Int)
    wageold = view(wold, size(wold,1), :)
    p.income[end] = p.wLss[end] + p.D[end,t]
    if t == 1
        p.income[1:end-1] .= wageold .* view(p.wLss, 1:p.N-1) .+ view(p.D, 1:p.N-1, t)
    else
        p.income[1:end-1] .= wageold .* view(p.wL, 1:p.N-1, t-1) .+ view(p.D, 1:p.N-1, t)
    end
    F = _reshape(view(p.F, :, t), p.S, p.N)
    F .= p.income' .* p.η
end

function setGcache!(p::Problem{<:Any,<:MinCurrentCost}, t::Int)
    Threads.@threads for d in 1:p.N
        @inbounds for j in 1:p.S
            λτsum = 0.0
            for s in 1:p.N
                τ = p.τ[j,s,d,t]
                λτsum += p.λ[j,s,d,t] * (τ - 1.0) / τ
            end
            p.λτsum[j,d] = λτsum
        end
    end
end

function setΩG_I!(p::Problem{<:Any,<:MinCurrentCost}, t::Int)
    ΩG_I = _reshape(p.ΩG_I, p.S, p.N, p.S, p.N)
    Threads.@threads for d in 1:p.N
        @inbounds for j in 1:p.S
            λτsum = p.λτsum[j,d]
            for s in 1:p.N
                λ = p.λ[j,s,d,t]
                τ = p.τ[j,s,d,t]
                for i in 1:p.S
                    if s == d
                        if i == j
                            ΩG_I[i,s,j,d] = λ * p.αM[i,j,s] / τ + p.ηG[i,s] * λτsum - 1.0
                        else
                            ΩG_I[i,s,j,d] = λ * p.αM[i,j,s] / τ + p.ηG[i,s] * λτsum
                        end
                    else
                        ΩG_I[i,s,j,d] = λ * p.αM[i,j,s] / τ
                    end
                end
            end
        end
    end
end

function setGcache!(p::Problem{<:Any,<:MaxPresentValue}, t::Int)
    Threads.@threads for d in 1:p.N
        @inbounds for j in 1:p.S
            σ = p.σ[j]
            cs = 1 - 1/σ
            λτsum = 0.0
            for s in 1:p.N
                τ = p.τ[j,s,d,t]
                λτsum += p.λ[j,s,d,t] * (τ - 1.0) / τ
            end
            p.λτsum[j,d] = λτsum * cs
        end
    end
end

function setΩG_I!(p::Problem{<:Any,<:MaxPresentValue}, t::Int)
    ΩG_I = _reshape(p.ΩG_I, p.S, p.N, p.S, p.N)
    Threads.@threads for d in 1:p.N
        @inbounds for j in 1:p.S
            σ = p.σ[j]
            cs = 1 - 1/σ
            λτsum = p.λτsum[j,d]
            for s in 1:p.N
                λ = p.λ[j,s,d,t]
                τ = p.τ[j,s,d,t]
                for i in 1:p.S
                    η = p.η[i,s]
                    if s == d # Needed for G
                        if i == j
                            ΩG_I[i,s,j,d] = λ * p.αM[i,j,s] / τ * cs + p.ηG[i,s] * λτsum +
                                η/σ - 1.0
                        else
                            ΩG_I[i,s,j,d] = λ * p.αM[i,j,s] / τ * cs + p.ηG[i,s] * λτsum +
                                η/σ
                        end
                    else
                        ΩG_I[i,s,j,d] = λ * p.αM[i,j,s] / τ * cs
                    end
                end
            end
        end
    end
    # Handle the special cases of CN2 and MX2
    for (s, d) in pairs(p.wLshift)
        if s != d
            for (i, j) in Base.product(1:p.S, 1:p.S)
                σ = p.σ[j]
                ΩG_I[i,d,j,s] += p.η[i,d] / σ
                ΩG_I[i,s,j,s] -= p.η[i,s] / σ
            end
        end
    end
end

function setXdiff!(p::Problem, Xdiff::AbstractArray, Xold::AbstractArray, t::Int)
    copyto!(Xdiff, view(p.F, :, t))
    # The subtraction is handled by diagonal elements in ΩG_I
    mul!(Xdiff, p.ΩG_I, Xold, true, true)
end

# Slightly faster than directly solving ΩG_I with lu!
function solveX!(p::Problem, t::Int)
    obj!(out, x) = setXdiff!(p, out, x, t)
    init_x = view(p.X,:,t)
    f = NonDifferentiable(obj!, init_x, copy(init_x); inplace=true)
    sol = anderson(f, init_x, 0.0, p.tolX, p.maxiterX, false, p.verboseX,
        false, p.betaX, 1, 1e10, p.solvercacheX)
    showconvergence(sol, "solveX!", p.verboseX)
    copyto!(view(p.X,:,t), p.solvercacheX.g)
end

function setX!(p::Problem{<:Any,<:Any,NoIO}, t::Int)
    F = _reshape(p.F, p.S, p.N, p.T)
    X = _reshape(p.X, p.S, p.N, p.T)
    for d in 1:p.N
        G = 0.0
        @inbounds for j in 1:p.S
            Fjd = F[j,d,t]
            X[j,d,t] = Fjd
            G += Fjd * p.λτsum[j,d]
        end
        if G > 0
            @inbounds for j in 1:p.S
                X[j,d,t] += p.ηG[j,d] * G
            end
        end
    end
end

function setY!(p::Problem{<:Any,<:MinCurrentCost}, t::Int)
    fill!(view(p.Y, :, :, t), 0.0)
    X = _reshape(view(p.X, :, t), p.S, p.N)
    Threads.@threads for s in 1:p.N
        @inbounds for (i, d) in Base.product(1:p.S, 1:p.N)
            p.Y[i,s,t] += p.λ[i,s,d,t] * X[i,d] / p.τ[i,s,d,t]
        end
    end
end

function setY!(p::Problem{<:Any,<:MaxPresentValue}, t::Int)
    fill!(view(p.Y, :, :, t), 0.0)
    X = _reshape(view(p.X, :, t), p.S, p.N)
    Threads.@threads for s in 1:p.N
        @inbounds for (i, d) in Base.product(1:p.S, 1:p.N)
            σ = p.σ[i]
            p.Y[i,s,t] += p.λ[i,s,d,t] * X[i,d] / p.τ[i,s,d,t] * (1 - 1/σ)
        end
    end
end

function setwdiff!(p::Problem{<:Any,<:MinCurrentCost,WithIO},
        wdiff::AbstractArray, wold::AbstractArray, t::Int)
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
    # Must loop separately
    wLbase = t == 1 ? p.wLss : view(p.wL,:,t-1)
    for (s, d) in pairs(p.wLshift)
        p.what[s,t] = p.wL[d,t] / wLbase[d]
    end
    for s in 1:p.N
        @inbounds for i in 1:p.S
            wdiff[i,s] = p.Ps[i,s,t] - wold[i,s]
        end
        @inbounds wdiff[end,s] = p.what[s,t] - wold[end,s]
    end
    return wdiff
end

function setΠ!(p::Problem{<:Any,<:MaxPresentValue}, t::Int)
    fill!(view(p.sc.Π, :, t), 0.0)
    X = _reshape(view(p.X, :, t), p.S, p.N)
    @inbounds for (i, d) in Base.product(1:p.S, 1:p.N)
        p.sc.Π[d,t] += X[i,d] / p.σ[i]
    end
end

function setwdiff!(p::Problem{<:Any,<:MaxPresentValue,WithIO},
        wdiff::AbstractArray, wold::AbstractArray, t::Int)
    setΠ!(p, t)
    fill!(view(p.wL, :, t), 0.0)
    @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
        p.wL[s,t] += p.α[i,s] * p.Y[i,s,t]
    end
    # Handle special regions where factor income needs to be aggregated
    for (s, d) in pairs(p.wLshift)
        if s != d
            p.wL[d,t] += p.wL[s,t]
            p.wL[s,t] = 0.0
            p.sc.Π[d,t] += p.sc.Π[s,t]
            p.sc.Π[s,t] = 0.0
        end
    end
    # Must loop separately
    wLbase = t == 1 ? p.wLss : view(p.wL,:,t-1)
    for (s, d) in pairs(p.wLshift)
        p.what[s,t] = p.wL[d,t] / wLbase[d]
    end
    for s in 1:p.N
        @inbounds for i in 1:p.S
            wdiff[i,s] = p.Ps[i,s,t] - wold[i,s]
        end
        @inbounds wdiff[end,s] = p.what[s,t] - wold[end,s]
    end
    return wdiff
end

function setwdiff!(p::Problem{<:Any,<:Any,NoIO},
        wdiff::AbstractArray, wold::AbstractArray, t::Int)
    fill!(view(p.wL, :, t), 0.0)
    @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
        p.wL[s,t] += p.Y[i,s,t]
    end
    # Handle special regions where factor income needs to be aggregated
    for (s, d) in pairs(p.wLshift)
        if s != d
            p.wL[d,t] += p.wL[s,t]
            p.wL[s,t] = 0.0
        end
    end
    # Must loop separately
    wLbase = t == 1 ? p.wLss : view(p.wL,:,t-1)
    #wLsc = sum(view(p.wL, :, t)) / sum(p.wLss)
    for (s, d) in pairs(p.wLshift)
        p.what[s,t] = p.wL[d,t] / wLbase[d]
    end
    what1 = p.what[end,t]
    p.what[:,t] ./= what1

    for s in 1:p.N-1
        @inbounds wdiff[end,s] = p.what[s,t] - wold[end,s]
    end
    return wdiff
end

function update_period!(p::Problem{<:Any,<:Any,WithIO},
        wdiff::AbstractArray, wold::AbstractArray, t::Int)
    setcost!(p, wold, t)
    settradeshare_k!(p, t)
    setchoice!(p, t)
    setprice!(p, t)
    settradeshare!(p, t)
    setF!(p, wold, t)
    any(>(0), p.ηG) && setGcache!(p, t)
    setΩG_I!(p, t)
    # Most of the run time is spent with solveX!
    solveX!(p, t)
    setY!(p, t)
    setwdiff!(p, wdiff, wold, t)
end

function update_period!(p::Problem{<:Any,<:Any,NoIO},
        wdiff::AbstractArray, wold::AbstractArray, t::Int)
    setcost!(p, wold, t)
    settradeshare_k!(p, t)
    setchoice!(p, t)
    setprice!(p, t)
    settradeshare!(p, t)
    setF!(p, wold, t)
    any(>(0), p.ηG) && setGcache!(p, t)
    setX!(p, t)
    setY!(p, t)
    setwdiff!(p, wdiff, wold, t)
end

# The contemporaneous factor price changes are to be determined endogenously
# Only values for k <= t + 1 are computed
# k = t + 1 is needed for price indices
function setcost_cum!(p::Problem, t::Int)
    Threads.@threads for d in 1:p.N
        @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
            # Important to reverse the order to use existing values
            for k in min(t+1, p.K):-1:3
                p.qhat_tk[k,i,s,d] = p.qhat_tk[k-1,i,s,d] * p.qhat[i,s,t-1] * p.τhat[i,s,d,t]
            end
            for k in min(t+1, 2):-1:1
                p.qhat_tk[k,i,s,d] = p.τhat[i,s,d,t]
            end
        end
    end
end

function setaggpriceindex!(p::Problem, t::Int)
    p.P .= p.Ps.^(1.0./(1.0 .- p.σ))
    for d in 1:p.N
        pf = 1.0
        @inbounds for j in 1:p.S
            pf *= p.P[j,d,t]^p.η[j,d]
        end
        p.Pf[d,t] = pf
    end
end

function forward!(p::Problem, t::Int)
    setcost_cum!(p, t)

    obj!(out, x) = update_period!(p, out, x, t)
    init_x = p.winit
    f = NonDifferentiable(obj!, init_x, copy(init_x); inplace=true)
    show_trace = p.verbosew
    xtol = 0.0
    iteroffset = 0
    sol = anderson(f, init_x, xtol, p.tolw, p.iterw1, false, show_trace, false, p.betaw1, 1, 1e10, p.solvercachew)
    # Switch to smaller factors to help getting convergence
    if converged(sol)
        res = p.solvercachew.g
    else
        iteroffset += p.iterw1
        sol = anderson(f, sol.zero, xtol, p.tolw, p.iterw2, false, show_trace, false, p.betaw2, 1, 1e10, p.solvercachew)
        if converged(sol)
            res = p.solvercachew.g
        else
            iteroffset += p.iterw2
            # Use plain fixed-point iteration without acceleration
            sol = anderson(f, sol.zero, xtol, p.tolw, p.maxiterw,
                false, show_trace, false, p.betaw3, 1, 1e10, p.solvercachew0)
            res = p.solvercachew0.g
        end
    end
    showconvergence(sol, "solve_period!", true, iteroffset)
    # p.Ps[:,:,t] .= view(res, 1:p.S, :)
    # p.what[:,t] .= view(res, p.S+1, :)
    copyto!(p.winit, res) # This matters
    setaggpriceindex!(p, t)
    return sol
end

function solve!(p::Problem{<:Any, <:MinCurrentCost})
    # Make sure τhat is correct for t = 1
    for t in 2:p.T
        p.τhat[:,:,:,t] .= view(p.τ,:,:,:,t) ./ view(p.τ,:,:,:,t-1)
    end
    # Important to always start from the first period
    for t in 1:p.T
        printstyled("Solving period ", t, "\n", bold=true, color=:green)
        forward!(p, t)
    end
    realwage!(p)
    realincome!(p)
    return p
end

function setprofit!(p::Problem, t::Int)
    if t > 1
        Threads.@threads for d in 1:p.N
            @inbounds for (i, s) in Base.product(1:p.S, 1:p.N)
                if p.λ0ss[i,s,d] > 0
                    b = 1.0
                    for k in 2:t
                        b *= p.sc.βf[i] * (1 - p.ζ[i])
                        tp = t - k + 1
                        # Only use Qs_el for those adjusted at least once
                        temp = b / p.Pf[d,t] * p.Pf[d,tp] * p.μ[1] / p.μ[k] *
                                p.Qs_el[k,i,s,d,t] / p.Qs_el[1,i,s,d,tp] *
                                p.X[i+p.S*(d-1),t] / p.X[i+p.S*(d-1),tp]
                        if t < p.T
                            p.sc.Ψsum1[i,s,d,tp] += temp
                        else
                            # The last term only shows up in the numerator
                            # to equalize the numbers of terms in numerator and denominator
                            if tp > 1
                                p.sc.Ψ[i,s,d,tp] = (1 + p.sc.Ψsum1[i,s,d,tp] + temp) /
                                    (1 + p.sc.Ψsum1[i,s,d,tp-1])
                            else
                                Ψsum0 = (1 - (p.sc.βf[i] * (1 - p.ζ[i]))^(p.T)) /
                                    (1 - (p.sc.βf[i] * (1 - p.ζ[i])))
                                p.sc.Ψ[i,s,d,tp] = (1 + p.sc.Ψsum1[i,s,d,tp] + temp) / Ψsum0
                            end
                        end
                    end
                end
            end
        end
    end
end

function update_dynamic!(p::Problem, Ψdiff::AbstractArray, Ψold::AbstractArray)
    # Important to always start from the first period
    fill!(p.sc.Ψsum1, 0.0)
    for t in 1:p.T
        printstyled("Solving period ", t, "\n", bold=true, color=:green)
        forward!(p, t)
        setprofit!(p, t)
    end
    # Ψ is updated in the last evaluation of setprofit!
    Ψdiff .= view(p.sc.Ψ,:,:,:,1:p.sc.TΨ) .- Ψold
end

function solve!(p::Problem{<:Any, <:MaxPresentValue})
    # Make sure τhat is correct for t = 1
    for t in 2:p.T
        p.τhat[:,:,:,t] .= view(p.τ,:,:,:,t) ./ view(p.τ,:,:,:,t-1)
    end
    obj!(out, x) = update_dynamic!(p, out, x)
    init_x = ones(p.S, p.N, p.N, p.sc.TΨ)
    f = NonDifferentiable(obj!, init_x, copy(init_x); inplace=true)
    sol = anderson(f, init_x, 0.0, p.sc.tolΨ, p.sc.maxiterΨ, false, p.sc.verboseΨ,
        false, p.sc.betaΨ, 1, 1e10, p.sc.solvercacheΨ)
    showconvergence(sol, "solveΨ!", p.sc.verboseΨ)
    realwage!(p)
    realincome!(p)
    dprofit!(p)
    return p
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

# Methods for computing objects not required for solving counterfacturals
# But are commonly used for results

# Results are already in log
function realwage!(p::Problem)
    p.W .= log.(p.wL) .- log.(p.wLss)
    # Rescale Pf as sum of p.η can be smaller than 1
    p.w .= p.W .- log.(p.Pf) ./ view(sum(p.η, dims=1),:)
end

function realincome!(p::Problem{<:Any, <:MinCurrentCost})
    realwage!(p)
    copyto!(p.drealincome, p.w)
end

# Results are already in log
function realincome!(p::Problem{<:Any, <:MaxPresentValue})
    p.drealincome .= log.(p.wL .+ p.sc.Π) .- log.(p.realincomess) .-
        log.(p.Pf) ./ view(sum(p.η, dims=1),:)
end

dprofit!(p::Problem{<:Any, <:MinCurrentCost}) = nothing

function dprofit!(p::Problem{<:Any, <:MaxPresentValue})
    p.sc.dΠ .= log.(p.sc.Π) .- log.(p.sc.Πss) .-
        log.(p.Pf) ./ view(sum(p.η, dims=1),:)
end

# υ must sum up to 1 for ACR formula to work
function rescale!(p::Problem{<:Any, <:MaxPresentValue})
    for t in 1:p.T
        for d in 1:p.N
            @inbounds for i in 1:p.S
                Υ = p.sc.Υ[i,d,t]
                if Υ > 0
                    for s in 1:p.N
                        p.sc.υ[i,s,d,t] /= Υ
                    end
                end
            end
        end
    end
end
