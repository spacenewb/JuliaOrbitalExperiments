# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to orbital frames and rotations.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
# ==============================================================================
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Remarks
# ==============================================================================
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export kepler_to_rv, rv_to_kepler, angle_to_dcm

################################################################################
#                                  Functions
################################################################################

"""
    plot_orbit(orbit::Orbit, line_props)

Plot the orbit.

# Remarks

The algorithm was obtained from \\[1] (accessed on 2022-07-20).

# References

- **[1]**: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
"""
function kepler_to_rv(a::Number, e::Number, i::Number, Ω::Number, ω::Number, f::Number, mu::Number)
    # Check eccentricity.
    !(0 <= e < 1) && throw(ArgumentError("Eccentricity must be in the interval [0,1)."));

    # Auxiliary variables.
    sin_f, cos_f = sincos(f);

    # Compute the geocentric distance.
    r = a * (1 - e^2) / (1 + e * cos_f);

    # Compute the position vector in the orbit plane, defined as:
    #   - The X axis points towards the perigee;
    #   - The Z axis is perpendicular to the orbital plane (right-hand);
    #   - The Y axis completes a right-hand coordinate system.
    r_o = [r * cos_f; r * sin_f; 0];

    # Compute the velocity vector in the orbit plane without perturbations.
    n = sqrt(mu / Float64(a)^3);
    v_o = ( n * a / sqrt(1 - e^2) ) * [-sin_f; e + cos_f; 0];

    # Compute the matrix that rotates the orbit reference frame into the
    # inertial reference frame.
    Dio = angle_to_dcm(-ω, -i, -Ω)

    # Compute the position and velocity represented in the inertial frame.
    r_i = Dio * r_o;
    v_i = Dio * v_o;

    return StateVec(r_i, v_i)
end

kepler_to_rv(kep::KeplerElem, mu::Number) = kepler_to_rv(kep.a, kep.e, kep.i, kep.Ω, kep.ω, kep.f, mu);

kepler_to_rv(v::Vector{<:Number}, mu::Number) = kepler_to_rv(v[1], v[2], v[3], v[4], v[5], v[6], mu);

"""
    plot_orbit(orbit::Orbit, line_props)

Plot the orbit.

# Remarks

The algorithm was obtained from \\[1] (accessed on 2022-07-20).

# References

- **[1]**: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
"""
function angle_to_dcm(θ₁, θ₂, θ₃)
    # Compute the sines and cosines.
    s₁, c₁ = sincos(θ₁);
    s₂, c₂ = sincos(θ₂);
    s₃, c₃ = sincos(θ₃);

	DCM = [ 	-s₁ * c₂ * s₃ + c₁ * c₃ 	c₁ * c₂ * s₃ + s₁ * c₃ 		s₂ * s₃;
             	-s₁ * c₃ * c₂ - c₁ * s₃ 	c₁ * c₃ * c₂ - s₁ * s₃ 		s₂ * c₃;
		    	s₁ * s₂           			-c₁ * s₂        			c₂ 			];
end

"""
    plot_orbit(orbit::Orbit, line_props)

Plot the orbit.

# Remarks

The algorithm was obtained from \\[1] (accessed on 2022-07-20).

# References

- **[1]**: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
"""
function rv_to_kepler(r_i::Vector{<:Number}, v_i::Vector{<:Number}, mu::Number)
    # Check inputs.
    length(r_i) != 3 && error("The vector r_i must have 3 dimensions.");
    length(v_i) != 3 && error("The vector v_i must have 3 dimensions.");

    @inbounds begin
        # Position and velocity vector norms and auxiliary dot products.
        r2 = dot(r_i, r_i);
        v2 = dot(v_i, v_i);

        r  = sqrt(r2);
        v  = sqrt(v2);

        rv = dot(r_i, v_i);

        # Angular momentum vector.
        h_i = r_i × v_i;
        h   = norm(h_i);

        # Vector that points to the right ascension of the ascending node (RAAN).
        n_i = [0; 0; 1] × h_i;
        n   = norm(n_i);

        # Eccentricity vector.
        e_i = ((v2 - mu / r) * r_i - rv * v_i ) / mu;

        # Orbit energy.
        ξ = v2 / 2 - mu / r;

        # Eccentricity
        # ============

        ecc = norm(e_i);

        # Semi-major axis
        # ===============

        if abs(ecc) <= 1.0 - 1e-6;
            a = -mu / (2ξ);
        else
            error("Could not convert the provided Cartesian values to Kepler elements.\n" *
                  "The computed eccentricity was not between 0 and 1");
        end

        # Inclination
        # ===========

        cos_i = h_i[3] / h;
        cos_i = abs(cos_i) > 1 ? sign(cos_i) : cos_i;
        i     = acos(cos_i);

        # Check the type of the orbit to account for special cases
        # ======================================================================

        # Equatorial
        # ----------------------------------------------------------------------

        if abs(n) <= 1e-6

            # Right Ascension of the Ascending Node.
            # ======================================

            Ω = 0;

            # Equatorial and elliptical
            # ------------------------------------------------------------------

            if abs(ecc) > 1e-6

                # Argument of Perigee
                # ===================

                cos_ω = e_i[1] / ecc;
                cos_ω = abs(cos_ω) > 1 ? sign(cos_ω) : cos_ω;
                ω     = acos(cos_ω);

                (e_i[2] < 0) && (ω = 2π - ω);

                # True anomaly
                # ============

                cos_v = dot(e_i, r_i) / (ecc * r);
                cos_v = abs(cos_v) > 1 ? sign(cos_v) : cos_v;
                v     = acos(cos_v);

                (rv < 0) && (v = 2π - v);

            # Equatorial and circular
            # ------------------------------------------------------------------

            else
                # Argument of Perigee
                # ===================

                ω = 0;

                # True anomaly
                # ============

                cos_v = r_i[1] / r;
                cos_v = abs(cos_v) > 1 ? sign(cos_v) : cos_v;
                v     = acos(cos_v);

                (r_i[2] < 0) && (v = 2π - v);
            end

        # Inclined
        # ----------------------------------------------------------------------
        else

            # Right Ascension of the Ascending Node.
            # ======================================

            cos_Ω = n_i[1] / n;
            cos_Ω = abs(cos_Ω) > 1 ? sign(cos_Ω) : cos_Ω;
            Ω     = acos(cos_Ω);

            (n_i[2] < 0) && (Ω = 2π - Ω);

            # Circular and inclined
            # ------------------------------------------------------------------

            if abs(ecc) < 1e-6

                # Argument of Perigee
                # ===================

                ω = 0;

                # True anomaly
                # ============

                cos_v = dot(n_i, r_i) / (n*r);
                cos_v = abs(cos_v) > 1 ? sign(cos_v) : cos_v;
                v     = acos(cos_v);

                (r_i[3] < 0) && (v = 2π - v);
            else

                # Argument of Perigee
                # ===================

                cos_ω = dot(n_i, e_i) / (n * ecc);
                cos_ω = abs(cos_ω) > 1 ? sign(cos_ω) : cos_ω;
                ω     = acos(cos_ω);

                (e_i[3] < 0) && (ω = 2π - ω);

                # True anomaly
                # ============

                cos_v = dot(e_i, r_i) / (ecc * r);
                cos_v = abs(cos_v) > 1 ? sign(cos_v) : cos_v;
                v     = acos(cos_v);

                (rv < 0) && (v = 2π - v);
            end
        end
    end

    # Return the Keplerian elements.
    # ==============================

    return KeplerElem(a, ecc, i, Ω, ω, v)
end

rv_to_kepler(v::StateVec, mu) = rv_to_kepler(v.pos, v.vel, mu);

rv_to_kepler(v::Vector{<:Number}, mu) = rv_to_kepler(v[1:3], v[4:6], mu);

rv_to_kepler(pos::Vector{<:Number}, vel::Vector{<:Number}, mu) = rv_to_kepler(pos, vel, mu);
