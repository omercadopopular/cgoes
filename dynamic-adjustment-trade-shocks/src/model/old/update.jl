# Methods for computing objects not required for solving counterfacturals
# But are commonly used for results

function priceindex!(p::Problem)
    p.P .= (1.0./(1.0 .- p.σ)) .* log.(p.Ps)
    for (d, t) in Base.product(1:p.N, 1:p.T)
        pf = 0.0
        @inbounds for j in 1:p.S
            pf += p.η[j,d] * p.P[j,d,t]
        end
        p.Pf[d,t] = pf
    end
end

function realwage!(p::Problem)
    p.W .= log.(p.what)
    for t in 2:p.T
        p.W[:,t] .= view(p.W, :, t-1) .+ view(p.W, :, t)
    end
    p.w .= p.W .- p.Pf
end
