module AnimalBehavior

using Turing, StructArrays
using StatsFuns: softmax
using ForwardDiff: ForwardDiff
using MacroTools: MacroTools

include("check_types.jl")
include("macros.jl")
include("simulate.jl")
include("inference.jl")
include("evolutions.jl")
include("observations.jl")

export  @evolution, 
        @observation, 
        simulate, 
        infer, 
        delta_rule!, 
        epsilon_argmax,
        epsilon_greedy,
        softmax,
        ucb

end 
