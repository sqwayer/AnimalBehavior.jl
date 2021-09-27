# struct Posterior{Tp, Tl, Tc}
#     parameters::Tp
#     latent::Tl
#     chain::Tc
# end

function cycle!(mdl, θ, obs)
    # action
    P = AnimalBehavior.observ(mdl, obs.s; θ...)
    # update
    AnimalBehavior.evol!(mdl, obs...; θ...)
    return P
end

function sample(mdl::Tm, data::StructVector, args...; kwargs...) where Tm <: AbstractMCMC.AbstractModel
    sample(Random.default_rng(), mdl, data, args...; kwargs...)
end

function sample(rng::AbstractRNG, mdl::Tm, data::StructVector, args...; kwargs...) where Tm <: AbstractMCMC.AbstractModel
    @model model(A) = begin
        θ = @submodel mdl
        θ = check_tuple_types(θ)

        P = [cycle!(mdl, θ, obs) for obs in data]
        A ~ arraydist(P)
        return
    end

    return sample(rng, model(data.a), args...; kwargs...)
end