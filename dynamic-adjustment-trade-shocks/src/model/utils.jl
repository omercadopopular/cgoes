# A customized constructor for AndersonCache
function initAndersonCache(m::Int, size::Int...)
    x = Array{Float64, length(size)}(undef, size...)
    g = similar(x)
    if m > 0
        fxold = similar(x)
        gold = similar(x)

        # maximum size of history
        mmax = min(length(x), m)

        # buffer storing the differences between g of the iterates, from oldest to newest
        Δgs = [similar(x) for _ in 1:mmax]

        T = eltype(x)
        γs = Vector{T}(undef, mmax) # coefficients obtained from the least-squares problem

        # matrices for QR decomposition
        Q = Matrix{T}(undef, length(x), mmax)
        R = Matrix{T}(undef, mmax, mmax)
    else
        fxold = nothing
        gold = nothing
        Δgs = nothing
        γs = nothing
        Q = nothing
        R = nothing
    end
    AndersonCache(x, g, fxold, gold, Δgs, γs, Q, R)
end

function showconvergence(sol::SolverResults, name::String, verbose::Bool, offset=0)
    iter = sol.iterations + offset
    if !(sol.x_converged || sol.f_converged)
        printstyled("$name did not converge after $iter iterations\n", color=:red)
    elseif verbose
        println("$name converged after $iter iterations")
    end
end

# An alternative to reshape that does not allocate
_reshape(A::AbstractArray, dims::Int...) = Base.ReshapedArray(A, dims, ())
