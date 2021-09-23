module AnimalBehavior

using Turing, StructArrays, StatsFuns
using ForwardDiff: ForwardDiff
using MacroTools: MacroTools

include("check_types.jl")
include("macros.jl")
include("simulate.jl")
include("inference.jl")
include("evolutions.jl")
include("observations.jl")

export @evolution, @observation, simulate, infer 
end 
