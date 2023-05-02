#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to the orbital types.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

# File: ./src/types/orbit.jl
# ===============================

# Struct KeplerElem
# -----------------------

################################################################################
#                                 Test Results
################################################################################
#
# Initialise an object of type `KeplerElem`
#
#   Using:
#       a = 6786.230 # [km]
#       e = .01
#       i = 52*pi/180 # [rad]
#       Ω = 95*pi/180 # [rad]
#       ω = 93*pi/180 # [rad]
#       f = 300*pi/180 # [rad]
#
################################################################################

@testset "Struct KeplerElem" begin
    # Answer
    a = 6786.230; # km
    e = .01;
    i = 52*pi/180; # rad
    Ω = 95*pi/180; # rad
    ω = 93*pi/180; # rad
    f = 300*pi/180; # rad
    kepvec = [a; e; i; Ω; ω; f]

    # Objective
    kep1 = KeplerElem(a, e, i, Ω, ω, f)
    kep2 = KeplerElem(kepvec)

    # Test
    @test kep1.a ≈ a atol = 0.0
    @test kep1.e ≈ e atol = 0.0
    @test kep1.i ≈ i atol = 0.0
    @test kep1.Ω ≈ Ω atol = 0.0
    @test kep1.ω ≈ ω atol = 0.0
    @test kep1.f ≈ f atol = 0.0
    @test kep1.vec ≈ kepvec atol = 0.0

    @test kep2.a ≈ a atol = 0.0
    @test kep2.e ≈ e atol = 0.0
    @test kep2.i ≈ i atol = 0.0
    @test kep2.Ω ≈ Ω atol = 0.0
    @test kep2.ω ≈ ω atol = 0.0
    @test kep2.f ≈ f atol = 0.0
    @test kep2.vec ≈ kepvec atol = 0.0
end
