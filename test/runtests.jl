using AnimalBehavior
using Turing
using Test

println("Macros")
println("======")
include("models_test.jl")

println("Simulation")
println("==========")
include("simul_test.jl")

println("Inference")
println("=========")
include("sample_test.jl")