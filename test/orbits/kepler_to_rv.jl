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

# Function kepler_to_rv
# -----------------------

################################################################################
#                                 Test Results
################################################################################
#
# Converting orbital representations
#
#   Using:
#       μₑ = 3.986004418e5; # [km^3/s^2].
#       a = 6786.230 # [km]
#       e = .01
#       i = 52*pi/180 # [rad]
#       Ω = 95*pi/180 # [rad]
#       ω = 93*pi/180 # [rad]
#       f = 300*pi/180 # [rad]
#
#   One must get:
#       r_ijk = 1.0e+03 * [-2.7489; 5.4437; 2.8977] # [km]
#       v_ijk = [-3.5694; -4.5794; 5.0621] # [km/s]
#
################################################################################

@testset "Function kepler_to_rv" begin
    μₑ = 3.986004418e5; # Standard gravitational parameter for Earth [km^3/s^2].

    a = 6786.230; # km
    e = .01;
    i = 52*pi/180; # rad
    Ω = 95*pi/180; # rad
    ω = 93*pi/180; # rad
    f = 300*pi/180; # rad
    kep = [a; e; i; Ω; ω; f]

    Kep = KeplerElem(kep);

    # Objective
    sv = kepler_to_rv(Kep, μₑ)

    # Tolerance
    tol_pos = 1e-1; # km
    tol_vel = 1e-2; # km/s

    # Answer
    r_ijk = 1.0e+03 * [-2.7489; 5.4437; 2.8977] # [km]
    v_ijk = [-3.5694; -4.5794; 5.0621] # [km/s]

    # Test
    @test sv.pos[1] ≈ r_ijk[1] atol = tol_pos
    @test sv.pos[2] ≈ r_ijk[2] atol = tol_pos
    @test sv.pos[3] ≈ r_ijk[3] atol = tol_pos
    @test sv.vel[1] ≈ r_ijk[4] atol = tol_vel
    @test sv.vel[2] ≈ r_ijk[5] atol = tol_vel
    @test sv.vel[3] ≈ r_ijk[6] atol = tol_vel
end
