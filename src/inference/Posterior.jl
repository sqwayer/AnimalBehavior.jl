struct Posterior{Tp, Tl}
    name::Symbol                    # Model name
    params_names::Vector{Symbol}    # Names of hyperparameters
    latent_names::Vector{Symbol}    # Names of latent variables
    hyperparameters::Tp             # Posterior distribution of hyperparameters
    latent::Tl                      # Posterior distribution of latent variables
    loglikelihood_func::Function    # Loglikelihood function
    nsamples::Int                   # Number of posterior samples
    nparams::Int                    # Number of hyperparameters
    ndata::Int                      # Number of data points

    Posterior(name, pnames, lnames, hp::Tp, latent::Tl, l_fun, ns, np, nd) where {Tp, Tl} = new{Tp, Tl}(
        name,
        pnames, 
        lnames, 
        hp, 
        latent, 
        l_fun, 
        ns, 
        np, 
        nd
    )
end

# Constructor from chains
function posterior(mdl, chn::Chains, data)
    npc, _, nc = size(chn)
    nsmp = npc * nc 
    ndata = data_size(data)

    # Extract parameters
    params_posterior, latent_posterior = extract_posterior_samples(mdl, chn)
    params_names = collect(keys(params_posterior[1]))
    latent_names = collect(keys(latent_posterior[1]))
    # Compute loglikelihoods for each sample at each data point
    l_fun(x) = loglikelihood(mdl, x, data)

    return Posterior(mdl.name, 
                    params_names,
                    latent_names,
                    params_posterior, 
                    latent_posterior,
                    l_fun,
                    nsmp,
                    length(params_names), 
                    ndata
    )
end

# Show
function Base.show(io::IO, ::MIME"text/plain", P::AnimalBehavior.Posterior)
    table_conf = set_pt_conf(tf = tf_markdown, alignment = :c)
    println(io, "Posterior probability for ", P.name, " with $(P.nsamples) samples, from $(P.ndata) data points.")
    
    println(io)
    pretty_table_with_conf(table_conf, 
        collect(values(expectation(P).hyperparameters))'; 
        header = P.params_names,
        title = "Expected hyperparameters values")
    
    println(io)
    DIC, pD = dic(P)
    WAIC, pW = waic(P)
    fit_header = ["", "Goodness of fit", "Complexity"]
    fit_vals = ["DIC" DIC pD;
                "WAIC" WAIC pW;
                "BIC" bic(P) P.nparams * log(P.ndata)]
    pretty_table_with_conf(table_conf, fit_vals; header=fit_header)
end