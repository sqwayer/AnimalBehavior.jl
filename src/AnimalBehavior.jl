"""
        AnimalBehavior 
"""
module AnimalBehavior

using Turing, StructArrays, Distributions, Random, PrettyTables
using StatsFuns: softmax!, logsumexp
using ForwardDiff: ForwardDiff
using DataFrames: DataFrames

import Base: rand, convert, show
import Turing: sample, loglikelihood, dic

# Models
include("models/evolutions.jl")
include("models/observations.jl")
include("models/macros.jl")

# Inference
include("inference/check_types.jl")
include("inference/sampling.jl")
include("inference/Posterior.jl")
include("inference/criteria.jl")
include("inference/posterior_sampling.jl")
include("inference/summarystats.jl")

# Simulation
include("simulation/simulate.jl")
include("simulation/interface.jl")
include("simulation/Simulation.jl")

export  @evolution, 
        @observation, 
        @model, # from Turing
        sample, # from Turing
        posterior,
        sample_hyperparams,
        sample_latent,
        expectation,
        dic, 
        waic,
        bic,
        simulate,
        delta_rule!, 
        epsilon_argmax,
        epsilon_greedy!,
        softmax!, # from StatsFuns
        ucb!
end 
