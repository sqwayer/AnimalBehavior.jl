""" Posterior distribution 
- Name for each field
- Sampleable (rand)
- Summary stats (mean/median depending on the eltype (Float/Int))
"""

struct PosteriorDistribution{TV}
    nsamples::Int
    names::Vector{Symbol}
    values::Vector{TV}
end

function PosteriorDistribution(names::Vector{Symbol}, values::Vector{TV}) where TV
    length(names) == length(values) || throw(DimensionMismatch("Invalid argument dimension."))
    n = unique(length.(values))
    length(n) == 1 || throw(DimensionMismatch("Inequal samples length"))
    return PosteriorDistribution{TV}(n[1], names, values)
end

function PosteriorDistribution(nt::NamedTuple)
    return PosteriorDistribution(collect(keys(nt)), collect(values(nt)))
end

# Sampling
function get_sample(PD::PosteriorDistribution{TV}, i::Int) where TV
    return (;zip(PD.names, getindex.(PD.values, i))...)
end

function rand(rng::AbstractRNG, PD::PosteriorDistribution{TV}) where TV
    si = rand(rng, 1:PD.nsamples) # Draw a sample
    return get_sample(PD, si)
end
rand(PD::PosteriorDistribution{TV}) where TV = rand(Random.default_rng(), PD)

function rand(rng::AbstractRNG, PD::PosteriorDistribution{TV}, n::Int) where TV
    return [rand(rng, PD) for i = 1:n]
end
rand(PD::PosteriorDistribution{TV}, n::Int) where TV = rand(Random.default_rng(), PD, n)

# Summary stats
average(V::Vector{T}) where T <: AbstractFloat = mean(V)
average(V::Vector{T}) where T <: Integer = Int(mode(V))
function average(V::Vector{M}) where M <: AbstractMatrix
    sz = unique(size.(V))
    length(sz) == 1 || throw(DimensionMismatch("Inequal matrices sizes"))
    return mean(V)
end
function average(PD::PosteriorDistribution{TV}) where TV
    AV = similar(getindex.(PD.values, 1))
    for i in eachindex(AV)
        AV[i] = average(PD.values[i])
    end
    return (;zip(PD.names, AV)...)
end