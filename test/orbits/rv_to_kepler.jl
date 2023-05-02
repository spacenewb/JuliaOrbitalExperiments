#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to the orbital representation.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

# File: ./src/orbits/frames.jl
# ===============================

# Function rv_to_kepler
# -----------------------

################################################################################
#                                 Test Results
################################################################################
#
# Converting orbital representations
#
#   Using:
#       μₑ = 3.986004418e5; # [km^3/s^2].
#       r_ijk = 1.0e+03 * [-2.7489; 5.4437; 2.8977] # [km]
#       v_ijk = [-3.5694; -4.5794; 5.0621] # [km/s]
#
#   One must get:
#       a = 6786.230 # [km]
#       e = .01
#       i = 52*pi/180 # [rad]
#       Ω = 95*pi/180 # [rad]
#       ω = 93*pi/180 # [rad]
#       f = 300*pi/180 # [rad]
#
################################################################################

@testset "Function kepler_to_rv" begin
    μₑ = 3.986004418e5; # Standard gravitational parameter for Earth [km^3/s^2].

    r_ijk = 1.0e+03 * [-2.7489; 5.4437; 2.8977] # [km]
    v_ijk = [-3.5694; -4.5794; 5.0621] # [km/s]

    sv = StateVec(r_ijk, v_ijk)

    # Objective
    kep = rv_to_kepler(sv, μₑ)

    # Tolerance
    tol_len = 1e-1; # km
    tol_ecc = 1e-3;
    tol_ang = 1e-2; # rad

    # Answer
    a = 6786.230; # km
    e = .01;
    i = 52*pi/180; # rad
    Ω = 95*pi/180; # rad
    ω = 93*pi/180; # rad
    f = 300*pi/180; # rad

    # Test
    @test kep.a ≈ a atol = tol_len
    @test kep.e ≈ e atol = tol_ecc
    @test kep.i ≈ i atol = tol_ang
    @test kep.Ω ≈ Ω atol = tol_ang
    @test kep.ω ≈ ω atol = tol_ang
    @test kep.f ≈ f atol = tol_ang
end
