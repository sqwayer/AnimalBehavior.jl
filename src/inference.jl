function cycle!(mdl, θ, obs)
    # action
    P = observation(mdl, obs.s; θ...)
    # update
    evolution!(mdl, obs...; θ...)
    return P
end

function infer(mdl, data; sampler, niter)

    @model model(A) = begin
        θ = @submodel mdl
        θ = check_tuple_types(θ)
        
        P = [cycle!(mdl, θ, obs) for obs in data]
        A ~ arraydist(P)
    end
    chn = sample(model(data.a), sampler, niter)
    return chn
end