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

# Struct StateVec
# -----------------------

################################################################################
#                                 Test Results
################################################################################
#
# Initialise an object of type `StateVec`
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

@testset "Struct StateVec" begin
    # Answer
    r_ijk = 1.0e+03 * [-2.7489; 5.4437; 2.8977]; # km
    v_ijk = [-3.5694; -4.5794; 5.0621]; # km/s
    rv_vec = [r_ijk; v_ijk]

    # Objective
    sv1 = StateVec(r_ijk, v_ijk)
    sv2 = StateVec([r_ijk; v_ijk])
    sv3 = StateVec(r_ijk[1], r_ijk[2], r_ijk[3], v_ijk[1], v_ijk[2], v_ijk[3])

    # Test
    @test sv1.pos[1] ≈ r_ijk[1] atol = 0.0
    @test sv1.pos[2] ≈ r_ijk[2] atol = 0.0
    @test sv1.pos[3] ≈ r_ijk[3] atol = 0.0
    @test sv1.vel[1] ≈ v_ijk[1] atol = 0.0
    @test sv1.vel[2] ≈ v_ijk[2] atol = 0.0
    @test sv1.vel[3] ≈ v_ijk[3] atol = 0.0
    @test sv1.vec ≈ rv_vec atol = 0.0

    @test sv2.pos[1] ≈ r_ijk[1] atol = 0.0
    @test sv2.pos[2] ≈ r_ijk[2] atol = 0.0
    @test sv2.pos[3] ≈ r_ijk[3] atol = 0.0
    @test sv2.vel[1] ≈ v_ijk[1] atol = 0.0
    @test sv2.vel[2] ≈ v_ijk[2] atol = 0.0
    @test sv2.vel[3] ≈ v_ijk[3] atol = 0.0
    @test sv2.vec ≈ rv_vec atol = 0.0

    @test sv3.pos[1] ≈ r_ijk[1] atol = 0.0
    @test sv3.pos[2] ≈ r_ijk[2] atol = 0.0
    @test sv3.pos[3] ≈ r_ijk[3] atol = 0.0
    @test sv3.vel[1] ≈ v_ijk[1] atol = 0.0
    @test sv3.vel[2] ≈ v_ijk[2] atol = 0.0
    @test sv3.vel[3] ≈ v_ijk[3] atol = 0.0
    @test sv3.vec ≈ rv_vec atol = 0.0
end
