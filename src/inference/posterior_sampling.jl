# Extract hyperparameters and latent variables from chains
function extract_posterior_samples(mdl, chn::Chains)
    # Extract parameters
    chains_params = Turing.MCMCChains.get_sections(chn, :parameters)
    vals = [vec(chains_params[n].data) for n in names(chains_params)]
    nt = NamedTuple{Tuple(names(chains_params))}(Tuple(vals))
    params_posterior = StructVector(nt)

    # Extract latent variables
    latent_posterior = StructVector(vec(generated_quantities(mdl, chains_params)))

    return params_posterior, latent_posterior
end

# Sampling from the posterior
sample_hyperparams(rng::AbstractRNG, post::Posterior, n::Int) = rand(rng, post.hyperparameters, n)
sample_hyperparams(post::Posterior, n::Int) = rand(post.hyperparameters, n)
sample_latent(rng::AbstractRNG, post::Posterior, n::Int) = rand(rng, post.latent, n)
sample_latent(post::Posterior, n::Int) = rand(post.latent, n)

function sample(rng::AbstractRNG, post::Posterior, n::Int)
    idx = rand(rng, 1:post.nsamples, n)
    hp = Vector{eltype(post.hyperparameters)}(undef, n)
    l = Vector{eltype(post.latent)}(undef, n)
    for i in eachindex(idx)
        hp[i] = post.hyperparameters[idx[i]]
        l[i] =  post.latent[idx[i]]
    end
    return (hyperparameters = hp,   
            latent = l)
end
sample(post::Posterior, n::Int) = sample(Random.default_rng(), post, n) 