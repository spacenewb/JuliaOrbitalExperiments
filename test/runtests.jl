using Test

using Dates
using DelimitedFiles
using Printf
using Colors
using DifferentialEquations
using LinearAlgebra
using Plots
using JOrbit

@testset "Orbit representation conversion functions" verbose = true begin
    include("./orbits/kepler_to_rv.jl")
    include("./orbits/rv_to_kepler.jl")
end
println("")


@testset "Struct Initialisations" verbose = true begin
    include("./types/Body.jl")
    include("./types/KeplerElem.jl")
    include("./types/StateVec.jl")
end
println("")
