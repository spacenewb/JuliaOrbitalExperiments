using Plots
using DifferentialEquations
using LinearAlgebra
using Colors

function ode_2bp!(du, u, p, t)
	mu = p;
	minus_mu_r3 = - mu / ( (u[1] ^ 2 + u[2] ^ 2 + u[3] ^ 2) ^ (3/2) );

    du[1:6] = [ u[4:6]; ( minus_mu_r3 * u[1:3] ) ];
end

# ----------------------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------------------- #

function angle_to_dcm(θ₁, θ₂, θ₃)
    # Compute the sines and cosines.
    s₁, c₁ = sincos(θ₁);
    s₂, c₂ = sincos(θ₂);
    s₃, c₃ = sincos(θ₃);

	DCM = [ 	-s₁ * c₂ * s₃ + c₁ * c₃ 	c₁ * c₂ * s₃ + s₁ * c₃ 		s₂ * s₃;
             	-s₁ * c₃ * c₂ - c₁ * s₃ 	c₁ * c₃ * c₂ - s₁ * s₃ 		s₂ * c₃;
		    	s₁ * s₂           			-c₁ * s₂        			c₂ 			];
end

# ----------------------------------------------------------------------------------------------- #

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

# ----------------------------------------------------------------------------------------------- #

# Test Conversion Accuracy
a = 6786.230; # km
e = .01;
i = 52*pi/180; # rad
Ω = 95*pi/180; # rad
ω = 93*pi/180; # rad
f = 300*pi/180; # rad

r_ijk = 1.0e+03 * [-2.7489; 5.4437; 2.8977]; # km
v_ijk = [-3.5694; -4.5794; 5.0621]; # km/s
statevec = StateVec(r_ijk, v_ijk);

kep = [a; e; i; Ω; ω; f]
kepkep = KeplerElem(kep);

kepler_to_rv(kepkep, mu)
rv_to_kepler(statevec, mu)

# ----------------------------------------------------------------------------------------------- #

struct KeplerElem
	a::Number
	e::Number
	i::Number
	Ω::Number
	ω::Number
	f::Number
	vec::Vector{<:Number}

	KeplerElem(a::Number, e::Number, i::Number, Ω::Number, ω::Number, f::Number) = new(a, e, i, Ω, ω, f, [a; e; i; Ω; ω; f]);

	KeplerElem(v::Vector{<:Number}) = length(v)!=6 ? error("Vector length < 6") : new(v[1], v[2], v[3], v[4], v[5], v[6], v);
end

# ----------------------------------------------------------------------------------------------- #

struct StateVec
	pos::Vector{<:Number}
	vel::Vector{<:Number}
	vec::Vector{<:Number}

	StateVec(pos::Vector{<:Number}, vel::Vector{<:Number}) = ( length(pos)!=3 && length(vel)!=3 ) ? error("Length of input vectors not correct!") : new(pos, vel, [pos; vel]);

	StateVec(r1::Number, r2::Number, r3::Number, v1::Number, v2::Number, v3::Number) = new([r1; r2; r3], [v1; v2; v3], [r1; r2; r3; v1; v2; v3]);

	StateVec(v::Vector{<:Number}) = length(v)!=6 ? error("Vector length < 6") : new(v[1:3], v[4:6], v);
end

# ----------------------------------------------------------------------------------------------- #

ke = KeplerElem(a, e, i, Ω, ω, f)
sv = StateVec(r_ijk, v_ijk/1.1)

# ----------------------------------------------------------------------------------------------- #

struct Body
	name::String
	class::String
	radius::Number
	mass::Number
	μ::Number
	color::Colorant

	function grav_param(m::Number)
		G = 6.674e-20; # km3/kg/s2
		return G*m;
	end

	Body() = new("Earth", "Planet", 12756/2, 5.97e24, grav_param(5.97e24), colorant"#968275");

	Body(name::String, class::String, radius::Number, mass::Number, color::Colorant) = new(name, class, radius, mass, grav_param(mass), color);
end

# ----------------------------------------------------------------------------------------------- #

# Stars
const Sol 		= 	Body("Sol",    "Star", 	696340, 1.989e30, colorant"#FE880D");

# Planets
const Mercury 	= Body("Mercury", "Planet", 4879/2, 0.330e24, colorant"#968275");
const Venus 	= Body("Venus", "Planet", 12104/2, 4.87e24, colorant"#D4C9B3");
const Earth 	= Body("Earth", "Planet", 12756/2, 5.97e24, colorant"#374A6A");
const Mars 		= Body("Mars", "Planet", 6792/2, 0.642e24, colorant"#DD663C");
const Jupiter 	= Body("Jupiter", "Planet", 142984/2, 1898e24, colorant"#E4C1AA");
const Saturn 	= Body("Saturn", "Planet", 120536/2, 568e24, colorant"#C5AE84");
const Uranus 	= Body("Uranus", "Planet", 51118/2, 86.8e24, colorant"#84A7AF");
const Neptune 	= Body("Neptune", "Planet", 49528/2, 102e24, colorant"#7E85DE");

# Moons
const Luna 		= Body("Luna", "Moon", 3475/2, 0.073e24, colorant"#98959A");

# Minors
const Pluto 	= 	Body("Pluto", "Minor", 2376/2, 0.0130e24, colorant"#5B4141");

# Alias
const Sun 		= 	Sol;
const Moon 		= 	Luna;

# ----------------------------------------------------------------------------------------------- #

struct Node
	name::String
	θ::Number

	Node(name::String) = new(name, 0.0);

	Node(name::String, θ::Number=0.0) = new(name, θ);
end

# ----------------------------------------------------------------------------------------------- #

mutable struct Orbit
	name::String
	kepler::KeplerElem
	state::StateVec
	body::Body
	nodes::Vector{Node}

	Orbit(name::String, kep::KeplerElem, body::Body) = new(name, kep, kepler_to_rv(kep, mu), body, Node[]);

	Orbit(name::String, state::StateVec, body::Body) = new(name, rv_to_kepler(state, mu), state, body, Node[]);

	Orbit(name::String, kep::KeplerElem, body::Body, nodes::Vector) = new(name, kep, kepler_to_rv(kep, mu), body, nodes);
end

# ----------------------------------------------------------------------------------------------- #

function add_node(orb::Orbit, node::Node)
	orb.nodes = [orb.nodes; node];
	return orb
end

o1 = Orbit("Alfa", ke, Earth)
n1 = Node("n1", 1.35)
o11 = add_node(o1, n1)
o22 = o1
o22 = add_node(o22, n1)
o22
o2 = Orbit("Beta", sv, Earth)
o1.nodes

# ----------------------------------------------------------------------------------------------- #

function plot_orbit(orbit::Orbit, line_props)
    μ = orbit.body.μ;

    u0 = orbit.state.vec;

    T = 2*pi*sqrt(Float64(a)^3/μ);
    tspan = (0.0, T);

    prob = ODEProblem(ode_2bp!, u0, tspan, μ);

    sol = solve(prob, AutoTsit5(Rosenbrock23()), reltol = 1e-12, abstol = 1e-14);

    plot(sol,
    idxs = (1, 2, 3),
    title = "Orbit Plot",
    lab = orbit.name,
    legend = true,
    line = line_props,
    bg = :black,
    fg = :white,
    leg = false,
    );
end

function plot_orbit!(orbit::Orbit, line_props)
    μ = orbit.body.μ;

    u0 = orbit.state.vec;

    T = 2*pi*sqrt(Float64(a)^3/μ);
    tspan = (0.0, T);

    prob = ODEProblem(ode_2bp!, u0, tspan, μ);

    sol = solve(prob, AutoTsit5(Rosenbrock23()), reltol = 1e-12, abstol = 1e-14);

    plot!(sol,
    idxs = (1, 2, 3),
    lab = orbit.name,
    legend = true,
    line = line_props,
    );
end

# ----------------------------------------------------------------------------------------------- #

plot_orbit(o2, (3, :dash, :cyan))
plot_orbit!(o1, (1, :solid, :magenta))

# ----------------------------------------------------------------------------------------------- #

function plot_body(body::Body, pos::Vector{<:Number}=[0.0, 0.0, 0.0], scale::Number=1.0, transparency::Number=0.8)
    plot([pos[1]], [pos[2]], [pos[3]],
        title = "Body Plot",
        lab = body.name,
        legend = true,
        marker = (body.radius*scale/100, transparency, body.color,
         Plots.stroke(1, :white)),
        line = (0.0, :solid, :transparent),
        bg = :black,
        fg = :white,
        leg = false,
    );
end

function plot_body!(body::Body, pos::Vector{<:Number}=[0.0, 0.0, 0.0], scale::Number=1.0, transparency::Number=0.8)
    plot!([pos[1]], [pos[2]], [pos[3]],
        lab = body.name,
        marker = (body.radius*scale/100, transparency, body.color,
        Plots.stroke(1, :white)),
        line = (0.0, :solid, :transparent),
    );
end

# ----------------------------------------------------------------------------------------------- #

plot_body(Earth)
plot_body!(Mars)

# ----------------------------------------------------------------------------------------------- #

function plotOrbit(orbit::Orbit, line_props=(1, :solid, :white), scale::Number=1.0, transparency::Number=0.8)
    plot_body(orbit.body, [0.0;0.0;0.0], scale, transparency);
    plot_orbit!(orbit, line_props);
end

function plotOrbit!(orbit::Orbit, line_props=(1, :solid, :white), scale::Number=1.0, transparency::Number=0.8)
    plot_body!(orbit.body, [0.0;0.0;0.0], scale, transparency);
    plot_orbit!(orbit, line_props);
end

# ----------------------------------------------------------------------------------------------- #

plotOrbit(o1)
plotOrbit!(o2)

# ----------------------------------------------------------------------------------------------- #

function plot_node(node::Node, marker)
    plot([0.0], [0.0], [0.0],
        title = "Body Plot",
        lab = body.name,
        legend = true,
        marker = (body.radius*scale/100, transparency, body.color,
        Plots.stroke(1, :white)),
        line = (0.0, :solid, :transparent),
        bg = :black,
        fg = :white,
        leg = false,
    );
end

# ----------------------------------------------------------------------------------------------- #
