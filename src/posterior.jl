struct Posterior{Tp, Tl, Tap, Tal}
    name::Symbol
    parameters_distribution::Tp
    latent_distribution::Tl
    parameters_avg::Tap
    latent_avg::Tal
    data_length::Int
    loglikelihood::Float64
    dic::Float64
    bic::Float64
    aic::Float64
end

# Model log-likelihood
function log_model_evidence(mdl, latent::NT, data) where NT <: NamedTuple
    θ = deepcopy(latent)
    P = [cycle!(mdl, θ, obs) for obs in data]
    return logpdf(arraydist(P), data.a)
end

# Model comparison
function posterior(mdl, chn::Chains, data)
    n = length(chn)

    # Extract parameters
    chains_params = Turing.MCMCChains.get_sections(chn, :parameters)
    param_names = chains_params.name_map.parameters
    param_vals = [vec(chains_params.value[:,i,:].data) for i in eachindex(param_names)]
    parameters = PosteriorDistribution(n, param_names, param_vals)

    # Extract latent variables
    genq = generated_quantities(mdl, chains_params)
    latent_names = collect(keys(genq[1]))
    latent_vals = [ vec([g[i] for g in genq]) for i in eachindex(latent_names)]
    latent = PosteriorDistribution(n, latent_names, latent_vals)

    # Summarize parameters and latent
    avg_param = average(parameters)
    avg_latent = generated_quantities(mdl, avg_param)
    
    # Compute DIC 
    lp_avg = log_model_evidence(mdl, avg_latent, data)
    lp_samples = zeros(n)
    for i = 1:n
        lp_samples[i] = log_model_evidence(mdl, get_sample(latent, i), data)
    end
    D_samples = -2 * mean(lp_samples)
    D_avg = -2 * lp_avg
    pD = D_samples - D_avg
    dic = pD + D_samples

    # Compute BIC and AIC
    k = length(avg_param)
    N = length(data)
    bic = k * log(N) - 2 * lp_avg
    aic = 2 * k - 2 * lp_avg
    
    return Posterior(mdl.name, 
                     parameters, 
                     latent,
                     avg_param,
                     avg_latent,
                     N,
                     lp_avg,
                     dic,
                     bic,
                     aic
        )
end

# Show
function Base.show(io::IO, ::MIME"text/plain", P::AnimalBehavior.Posterior)
    println(io, "Posterior probability for model ", P.name, " on $(P.data_length) data points :")
    println(io, "Average hyperparameters : ", P.parameters_avg)
    println(io, "Average initial latent variables : ", P.latent_avg)
    println(io, "Goodness of fit : ")
    println(io, "       Negative log-likelihood : ", -P.loglikelihood)
    println(io, "       Akaike Information Criterion : ", P.aic)
    println(io, "       Bayesian Information Criterion : ", P.bic)
    println(io, "       Deviance Information Criterion : ", P.dic)
    println(io, "Model complexity : ")
    println(io, "       Number of hyperparameters : ", length(P.parameters_avg))
    println(io, "       Effective number of parameters : ", (P.dic + 2 * P.loglikelihood)/2)
end