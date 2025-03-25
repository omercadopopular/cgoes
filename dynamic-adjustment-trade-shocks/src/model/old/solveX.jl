function setGcache!(p::Problem, t::Int)
    Threads.@threads for d in 1:p.N
        @inbounds for j in 1:p.S
            λτsum = 0.0
            for s in 1:p.N
                ττ = p.τ[j,s,d,t]
                λτsum += p.λ[j,s,d,t] * (ττ - 1.0) / ττ
            end
            p.λτsum[j,d] = λτsum
        end
    end
end

function setΩG_I!(p::Problem, t::Int)
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

function setXdiff!(p::Problem, Xdiff::AbstractArray, Xold::AbstractArray)
    copyto!(Xdiff, p.F)
    mul!(Xdiff, p.ΩG_I, Xold, 1.0, 1.0)
end

function solveX!(p::Problem, t::Int)
    obj!(out, x) = setXdiff!(p, out, x)
    init_x = t == 1 ? _reshape(p.X_ss, length(p.X_ss)) : view(p.X, :, t-1)
    f = NonDifferentiable(obj!, init_x, copy(init_x); inplace=true)
    sol = anderson(f, init_x, p.tolX, p.tolX, p.maxiterX, false, p.verboseX,
        false, 0.9, 1, 1e10, p.solvercacheX)
    showconvergence(sol, "solveX!", p.verboseX)
end
