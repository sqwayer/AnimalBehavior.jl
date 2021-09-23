module AnimalBehavior
using Turing, StructArrays
using ForwardDiff: ForwardDiff
using MacroTools: MacroTools

export @evolution, @observation, simulate, infer 
end 
