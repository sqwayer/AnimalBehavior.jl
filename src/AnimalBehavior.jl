module AnimalBehavior
using Turing, StructArrays, StatsFuns
using ForwardDiff: ForwardDiff
using MacroTools: MacroTools

export @evolution, @observation, simulate, infer 
end 
