struct Posterior{Tp, Tl, Tap, Tal}
    name::Symbol
    parameters_distribution::Tp
    latent_distribution::Tl
    parameters_avg::Tap
    latent_avg::Tal
    nparams::Int
    ndata::Int
    loglikelihood::Float64
    pD::Float64
    dic::Float64
    bic::Float64
    aic::Float64
end

# Model log-likelihood
function loglikelihood(mdl, latent::NT, data) where NT <: NamedTuple
    θ = deepcopy(latent)
    P = [cycle!(θ, mdl, obs) for obs in data]
    return logpdf(arraydist(P), data.a)
end

function pD(D_samples, D_avg)
    return D_samples - D_avg
end

function pV(D_samples, _)
    return 0.5*var(D_samples)
end

# Model comparison
function posterior(mdl, chn::Chains, data; dic_params = pD )
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
    lp_avg = loglikelihood(mdl, avg_latent, data)
    lp_samples = zeros(n)
    for i = 1:n
        lp_samples[i] = loglikelihood(mdl, get_sample(latent, i), data)
    end
    D_samples = -2 * mean(lp_samples)
    D_avg = -2 * lp_avg
    pD = dic_params(D_samples, D_avg)
    dic = pD + D_samples

    # Compute AIC and BIC
    k = length(avg_param)
    N = length(data)
    aic = 2 * k - 2 * lp_avg
    bic = k * log(N) - 2 * lp_avg
    
    return Posterior(mdl.name, 
                     parameters, 
                     latent,
                     avg_param,
                     avg_latent,
                     k,
                     N,
                     lp_avg,
                     pD,
                     dic,
                     bic,
                     aic
        )
end

# Show
function Base.show(io::IO, ::MIME"text/plain", P::AnimalBehavior.Posterior)
    table_conf = set_pt_conf(tf = tf_markdown, alignment = :c)
    println(io, "Posterior probability for ", P.name, " with $(P.ndata) data points")
    
    println(io)
    param_header = collect(keys(P.parameters_avg))
    pretty_table_with_conf(table_conf, 
        collect(values(P.parameters_avg))'; 
        header = param_header,
        title = "Average hyperparameters")
    
    println(io)
    latent_header = collect(keys(P.latent_avg))
    pretty_table_with_conf(table_conf, 
        collect(values(P.latent_avg))'; 
        header = latent_header,
        title = "Average initial latent variables")
    
    println(io)
    fit_header = ["", "Goodness of fit", "Complexity"]
    fit_vals = ["AIC" P.aic 2*P.nparams;
                "DIC" P.dic 2*P.pD;
                "BIC" P.bic P.nparams * log(P.ndata)]
    pretty_table_with_conf(table_conf, fit_vals; header=fit_header)
end