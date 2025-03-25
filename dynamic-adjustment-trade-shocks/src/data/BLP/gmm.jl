using StaticArrays

struct Moment{S,tradevars,tariffvars,iv,D}
    data::D
    hs::SVector{S,Int}
    function Moment(data, hs::Tuple, tradevars::Tuple, tariffvars::Tuple, iv::Symbol)
        S = length(hs)
        hs = SVector{S,Int}((hs...,))
        return new{S,tradevars,tariffvars,iv,typeof(data)}(data, hs)
    end
end

struct DMoment{S,tradevars,tariffvars,iv,D}
    data::D
    hs::SVector{S,Int}
    function DMoment(data, hs::Tuple, tradevars::Tuple, tariffvars::Tuple, iv::Symbol)
        S = length(hs)
        hs = SVector{S,Int}((hs...,))
        return new{S,tradevars,tariffvars,iv,typeof(data)}(data, hs)
    end
end

struct MomentLinear{S,tradevars,tariffvars,iv,D}
    data::D
    hs::SVector{S,Int}
    function MomentLinear(data, hs::Tuple, tradevars::Tuple, tariffvars::Tuple, iv::Symbol)
        S = length(hs)
        hs = SVector{S,Int}((hs...,))
        return new{S,tradevars,tariffvars,iv,typeof(data)}(data, hs)
    end
end

struct DMomentLinear{S,tradevars,tariffvars,iv,D}
    data::D
    hs::SVector{S,Int}
    function DMomentLinear(data, hs::Tuple, tradevars::Tuple, tariffvars::Tuple, iv::Symbol)
        S = length(hs)
        hs = SVector{S,Int}((hs...,))
        return new{S,tradevars,tariffvars,iv,typeof(data)}(data, hs)
    end
end

const MOrDM{S,tradevars,tariffvars,iv,D} =
    Union{Moment{S,tradevars,tariffvars,iv,D}, DMoment{S,tradevars,tariffvars,iv,D},
        MomentLinear{S,tradevars,tariffvars,iv,D}, DMomentLinear{S,tradevars,tariffvars,iv,D}}

@generated function gettrade(g::MOrDM{S,tradevars}, r) where {S,tradevars}
    ex = :(())
    for v in tradevars
        n = QuoteNode(v)
        push!(ex.args, :(getproperty(data, $n)[r]::Float64))
    end
    return :(data = g.data; SVector{S,Float64}($ex))
end

@generated function gettariff(g::MOrDM{S,tradevars,tariffvars}, r) where {S,tradevars,tariffvars}
    ex = :(())
    for v in tariffvars
        n = QuoteNode(v)
        push!(ex.args, :(getproperty(data, $n)[r]::Float64))
    end
    return :(data = g.data; SVector{S,Float64}($ex))
end

function (g::Moment{S,tradevars,tariffvars,iv})(p, r) where {S,tradevars,tariffvars,iv}
    θ, σ, ζ = p
    data = g.data
    trade = gettrade(g, r)
    tariff = gettariff(g, r)
    z = getproperty(data, iv)[r]::Float64
    elas = -θ .* (1 .- (1-ζ).^g.hs) .+ (1-σ) .* (1-ζ).^g.hs .- 1
    out = (trade .- elas .* tariff) .* z
    return out
end

function (g::DMoment{S,tradevars,tariffvars,iv})(p, r) where {S,tradevars,tariffvars,iv}
    θ, σ, ζ = p
    data = g.data
    tariff = gettariff(g, r)
    z = getproperty(data, iv)[r]::Float64
    out = hcat((1 .- (1-ζ).^g.hs), (1-ζ).^g.hs,
        θ .* g.hs.*(1-ζ).^(g.hs.-1) .+ (1-σ).*g.hs.*(1-ζ).^(g.hs.-1)) .* tariff .* z
    return out
end

function (g::MomentLinear{S,tradevars,tariffvars,iv})(p, r) where {S,tradevars,tariffvars,iv}
    data = g.data
    trade = gettrade(g, r)
    tariff = gettariff(g, r)
    z = getproperty(data, iv)[r]::Float64
    elas = SVector{S,Float64}((p...,))
    out = (trade .- (elas .- 1) .* tariff) .* z
    return out
end

function (g::DMomentLinear{S,tradevars,tariffvars,iv})(p, r) where {S,tradevars,tariffvars,iv}
    data = g.data
    tariff = gettariff(g, r)
    z = getproperty(data, iv)[r]::Float64
    out = diagm(tariff .* (-z))
    return out
end

function Base.show(io::IO, ::MIME"text/plain",
        m::MOrDM{S,tradevars,tariffvars,iv}) where {S,tradevars,tariffvars,iv}
    println(io, typeof(m).name.name, "{$S}:")
    print(io, "  tradevars: ")
    join(io, tradevars, ", ")
    print(io, "\n  tariffvars: ")
    join(io, tariffvars, ", ")
    print(io, "\n  IV: ", iv)
end

Base.show(io::IO, m::MOrDM{S}) where S =
    print(io, typeof(m).name.name, "{$S}(", join(m.hs, ", "), ")")
