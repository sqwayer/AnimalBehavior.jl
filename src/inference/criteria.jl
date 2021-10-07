## Log-likelihood
# Unique session
function loglikelihood(mdl::Tm, latent::NT, data::StructVector) where {Tm <: AbstractMCMC.AbstractModel, NT <: NamedTuple}
    θ = deepcopy(latent)
    P = [cycle!(θ, mdl, obs) for obs in data]
    L = logpdf.(P, data.a)
    return L
end

# Multiple sessions
function loglikelihood(mdl::Tm, latent::NT, data::Array{Ts}) where {Tm <: AbstractMCMC.AbstractModel, NT <: NamedTuple, Ts <: StructVector}
    nsess = length(data)
    L = Float64[]
    for sess = 1:nsess
        θ = deepcopy(latent) # Re-initialize the latent variables
        P = [cycle!(θ, mdl, obs) for obs in data[sess]]
        L = append!(L, logpdf.(P, data[sess].a))
    end
    return L
end

## DIC
# Number of effective parameters
neff_params(::Val{:pD}, D_samples, D_avg) = mean(D_samples) - D_avg
neff_params(::Val{:pV}, D_samples, _) = 0.5*var(D_samples)

function dic(P::Posterior, pDIC = :pD)
    latent_avg = average(P.latent)
    lp_avg = sum(P.loglikelihood_func(latent_avg))
    lp_samples = sum.(P.loglikelihood_func.(P.latent))
    D_samples = -2 .* lp_samples
    D_avg = -2 * lp_avg
    pD = neff_params(Val(pDIC), D_samples, D_avg)
    return D_avg + 2 * pD, pD
end

## WAIC
function waic(P::Posterior)
    lp_y = hcat([P.loglikelihood_func(P.latent[i]) for i = 1:P.nsamples]...)
    N, K = size(lp_y) 
    lppd = sum(logsumexp(lp_y, dims=2)) - N*log(K)
    pW = sum(var(lp_y, dims=2))
    return -2 * lppd + 2 * pW, pW
end

## BIC
function bic(P::Posterior)
    latent_avg = average(P.latent)
    lp_avg = sum(P.loglikelihood_func(latent_avg))
    return - 2 * lp_avg + P.nparams * log(P.ndata)
end