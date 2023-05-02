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

# Struct Body
# -----------------------

################################################################################
#                                 Test Results
################################################################################
#
# Initialise an object of type `Body`
#
#   Using:
#       name = "Earth"
#       class = "Planet"
#       radius = 6378 [km]
#       mass = 5.97e24 [kg]
#       μ = 3.986004418e5 [km^3/s^2].
#       color = colorant"#968275"
#
################################################################################

@testset "Struct Body" begin
    # Answer
    name = "Earth"
    class = "Planet"
    radius = 6378 # [km]
    mass = 5.97e24 # [kg]
    μ = 3.986004418e5 # [km^3/s^2]
    color = colorant"#968275"

    # Objective
    bod1 = Body()
    bod2 = Body(name, class, radius, mass, color)
    bod3 = Body(name, class, radius, mass, μ, color)


    # Test
    @test bod1.name == name
    @test bod1.class == class
    @test bod1.radius ≈ radius = 0.0
    @test bod1.mass ≈ mass atol = 0.0
    @test bod1.μ ≈ μ atol = 0.0
    @test bod1.color == color

    @test bod2.name == name
    @test bod2.class == class
    @test bod2.radius ≈ radius = 0.0
    @test bod2.mass ≈ mass atol = 0.0
    @test bod2.μ ≈ μ atol = 0.0
    @test bod2.color == color

    @test bod3.name == name
    @test bod3.class == class
    @test bod3.radius ≈ radius = 0.0
    @test bod3.mass ≈ mass atol = 0.0
    @test bod3.μ ≈ μ atol = 0.0
    @test bod3.color == color
end
