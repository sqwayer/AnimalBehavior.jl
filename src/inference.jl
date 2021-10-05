function cycle!(θ, mdl, obs)
    # action
    P = AnimalBehavior.observ(mdl, obs.s; θ...)
    # update
    AnimalBehavior.evol!(mdl, obs...; θ...)
    return P
end

# Sample for a single session
function sample(mdl::Tm, data::StructVector, args...; kwargs...) where Tm <: AbstractMCMC.AbstractModel
    sample(Random.default_rng(), mdl, data, args...; kwargs...)
end

function sample(rng::AbstractRNG, mdl::Tm, data::StructVector, args...; kwargs...) where Tm <: AbstractMCMC.AbstractModel
    @model model(A) = begin
        θ = @submodel mdl
        θ = check_tuple_types(θ)

        P = [cycle!(θ, mdl, obs) for obs in data]
        A ~ arraydist(P)
        return
    end

    return sample(rng, model(data.a), args...; kwargs...)
end

# Sample for multiple sessions
function sample(mdl::Tm, data::Vector{StructVector}, args...; kwargs...) where Tm <: AbstractMCMC.AbstractModel
    sample(Random.default_rng(), mdl, data, args...; kwargs...)
end

function sample(rng::AbstractRNG, mdl::Tm, data::Vector{StructVector}, args...; kwargs...) where Tm <: AbstractMCMC.AbstractModel
    nsess = length(data)
    @model model(A) = begin
        θ = @submodel mdl
        θ = check_tuple_types(θ)

        for sess in 1:nsess
            sessdat = data[sess]
            θ_init = deepcopy(θ)
            P = [cycle!(θ_init, mdl, obs) for obs in sessdat]
            A[sess] ~ arraydist(P)
        end
        return
    end
    actions = [sessdat.a for sessdat in data]
    return sample(rng, model(actions), args...; kwargs...)
end