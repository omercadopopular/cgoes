include("TradeAdj.jl")
using DataFrames
using LinearAlgebra: I, qr!, ldiv!
using ReadStatTables
using TypedTables
using MAT
using FilePathsBase
using FilePathsBase: /

const copsdir = p"data/COPS/Replication_JPE_Matlab_files"
const elasdir = p"data/work/elas"
const modeldir = p"data/work/model"

function calibrate!(p, elas, para; noadj::Bool=false)
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
    fill!(p.η, 1)
    fill!(p.α, 1)
    fill!(p.αM, 0)
    p.λ0ss[1,:,:] .= para["Din00"]'
    p.Xss .= sum(para["xbilat00"], dims=2)'

    p.τ[1,:,:,1:13] .= para["series_tau"]
    p.τ[1,:,:,14:end] .= view(para["series_tau"], :, :, 13)

    for s in 1:p.N
        wL = 0.0
        for d in 1:p.N
            wL += p.Xss[1,d] * p.λ0ss[1,s,d] / p.τ[1,s,d,1]
        end
        p.wLss[s] = wL
    end

    p.D .= view(p.Xss, :) .- p.wLss

    return p
end

function run!(p, elas, para; fillηG=false)
    calibrate!(p, elas, para)
    fillηG && (p.ηG .= p.η)
    @time solve!(p);
    #priceindex!(p)
    #realwage!(p)
end

function main()
    para = matread(string(copsdir/"Benchmark_results_EU_enlargement/Base_year2002_skill.mat"))
    elas = (4.5, 1.1, 0.1)
    T = 200
    H = 30
    p = Problem(S=1, N=18, T=200, sc=MaxPresentValue(S=1, N=18, T=T, TΨ=T-5), it=NoIO(), histw1=1)
    run!(p, elas, para; fillηG=true)

end

