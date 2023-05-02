# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   General structures related to orbits.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export Body, KeplerElem, Node, Orbit, StateVec

"""
    KeplerianElements{Tepoch, T}

This structure defines the orbit in terms of the Keplerian elements.

# Fields

- `t::Tepoch`: Epoch.
- `a::T`: Semi-major axis [m].
- `e::T`: Eccentricity [ ].
- `i::T`: Inclination [rad].
- `Ω::T`: Right ascension of the ascending node [rad].
- `ω::T`: Argument of perigee [rad].
- `f::T`: True anomaly [rad].
"""
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

"""
    KeplerianElements{Tepoch, T}

This structure defines the orbit in terms of the Keplerian elements.

# Fields

- `t::Tepoch`: Epoch.
- `a::T`: Semi-major axis [m].
- `e::T`: Eccentricity [ ].
- `i::T`: Inclination [rad].
- `Ω::T`: Right ascension of the ascending node [rad].
- `ω::T`: Argument of perigee [rad].
- `f::T`: True anomaly [rad].
"""
struct StateVec
	pos::Vector{<:Number}
	vel::Vector{<:Number}
	vec::Vector{<:Number}

	StateVec(pos::Vector{<:Number}, vel::Vector{<:Number}) = ( length(pos)!=3 && length(vel)!=3 ) ? error("Length of input vectors not correct!") : new(pos, vel, [pos; vel]);

	StateVec(r1::Number, r2::Number, r3::Number, v1::Number, v2::Number, v3::Number) = new([r1; r2; r3], [v1; v2; v3], [r1; r2; r3; v1; v2; v3]);

	StateVec(v::Vector{<:Number}) = length(v)!=6 ? error("Vector length < 6") : new(v[1:3], v[4:6], v);
end

"""
    KeplerianElements{Tepoch, T}

This structure defines the orbit in terms of the Keplerian elements.

# Fields

- `t::Tepoch`: Epoch.
- `a::T`: Semi-major axis [m].
- `e::T`: Eccentricity [ ].
- `i::T`: Inclination [rad].
- `Ω::T`: Right ascension of the ascending node [rad].
- `ω::T`: Argument of perigee [rad].
- `f::T`: True anomaly [rad].
"""
struct Body
	name::String
	class::String
	radius::Number
	mass::Number
	μ::Number
	color::Colorant

    function grav_param(m::Number)
        return G*m;
    end

	Body() = new("Earth", "Planet", 12756/2, 5.97e24, grav_param(5.97e24), colorant"#968275");

	Body(name::String, class::String, radius::Number, mass::Number, color::Colorant) = new(name, class, radius, mass, grav_param(mass), color);
end

"""
    KeplerianElements{Tepoch, T}

This structure defines the orbit in terms of the Keplerian elements.

# Fields

- `t::Tepoch`: Epoch.
- `a::T`: Semi-major axis [m].
- `e::T`: Eccentricity [ ].
- `i::T`: Inclination [rad].
- `Ω::T`: Right ascension of the ascending node [rad].
- `ω::T`: Argument of perigee [rad].
- `f::T`: True anomaly [rad].
"""
struct Node
	name::String
	θ::Number

	Node(name::String) = new(name, 0.0);

	Node(name::String, θ::Number=0.0) = new(name, θ);
end

"""
    KeplerianElements{Tepoch, T}

This structure defines the orbit in terms of the Keplerian elements.

# Fields

- `t::Tepoch`: Epoch.
- `a::T`: Semi-major axis [m].
- `e::T`: Eccentricity [ ].
- `i::T`: Inclination [rad].
- `Ω::T`: Right ascension of the ascending node [rad].
- `ω::T`: Argument of perigee [rad].
- `f::T`: True anomaly [rad].
"""
struct Orbit
	name::String
	kepler::KeplerElem
	state::StateVec
	body::Body
	nodes::Vector{Node}
    nodepos::Vector{Vector{Any}}

	Orbit(name::String, kep::KeplerElem, body::Body) = new(name, kep, kepler_to_rv(kep, body.μ), body, Node[], []);

	Orbit(name::String, state::StateVec, body::Body) = new(name, rv_to_kepler(state, body.μ), state, body, Node[], []);

	Orbit(name::String, kep::KeplerElem, body::Body, nodes::Vector) = new(name, kep, kepler_to_rv(kep, body.μ), body, nodes, []);

    Orbit(name::String, kep::KeplerElem, body::Body, nodes::Vector, nodepos::Vector{Vector{Any}}) = new(name, kep, kepler_to_rv(kep, body.μ), body, nodes, nodepos);
end
