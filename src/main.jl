using .JOrbit

# Test Conversion Accuracy
μₑ = 3.986004418e5; # Standard gravitational parameter for Earth [km^3/s^2].

a = 6786.230; # km
e = .01;
i = 52*pi/180; # rad
Ω = 95*pi/180; # rad
ω = 93*pi/180; # rad
f = 300*pi/180; # rad

r_ijk = 1.0e+03 * [-2.7489; 5.4437; 2.8977]; # km
v_ijk = [-3.5694; -4.5794; 5.0621]; # km/s

#
kep = KeplerElem(a, e, i, Ω, ω, f)
kep2 = KeplerElem(a, e, i*1.2, Ω, ω, f)
sv = StateVec(r_ijk, v_ijk)

o1 = Orbit("Alfa", kep, JOrbit.Earth)
o11 = Orbit("Alfa2", sv, JOrbit.Earth)
o2 = Orbit("Beta", kep2, JOrbit.Earth)
o3 = Orbit("Beta", kep2, JOrbit.Mars)

n1 = Node("n1", 1.35)
n2 = Node("n2", 0.3)
n3 = Node("n3", 0.65)

#
o22 = o1

o11 = add_node(o1, n1)
o22 = add_node(o11, n2)
o33 = add_node(o22, n3)
# println(o33)
o44 = rm_node(o33, n1)
# println(o44)

# plotOrbits([o33, o2, o3])
# plotOrbits(o3)

orbi = o33;

# node_posns = []
# for nd in orbi.nodes
#     new_kep_vec = [orbi.kepler.vec[1:5]; nd.θ];
#     append!(node_posns, [kepler_to_rv(new_kep_vec, orbi.body.μ).pos]);
# end

# println(gg)
