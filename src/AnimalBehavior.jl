module AnimalBehavior

using Turing, StructArrays, Distributions, Random, PrettyTables
using StatsFuns: softmax
using ForwardDiff: ForwardDiff
using DataFrames: DataFrames

import Base: rand, convert, show
import Turing: sample

include("check_types.jl")
include("macros.jl")
include("simulate.jl")
include("inference.jl")
include("evolutions.jl")
include("observations.jl")
include("PosteriorDistribution.jl")
include("posterior.jl")

export  @evolution, 
        @observation, 
        @model, # from Turing
        sample, # from Turing
        posterior,
        simulate,
        delta_rule!, 
        epsilon_argmax,
        epsilon_greedy,
        softmax,
        ucb
end 
