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
o1sv = Orbit("Alfa2", sv, JOrbit.Earth)
o2 = Orbit("Beta", kep2, JOrbit.Earth)
o3 = Orbit("Gamma", kep2, JOrbit.Mars)

n1 = Node("n1", 1.35)
n2 = Node("n2", 0.3)
n3 = Node("n3", 0.65)
n4 = Node("n4", 2.4)

###### add and remove nodes test
add_node!(o1, n1)
add_node!(o1, [n1, n1])
rm_node!(o1, n1)
add_node!(o1, [n1, n1, n2])
rm_node!(o1, [n1, n2, n2])
rm_node!(o1, n1)

##### Plot test
add_node!(o1, [n1, n2, n3])

plotOrbits([o1, o2, o3], n1)
plotOrbits(o1, n4)
plotOrbits(o1, n2)
plotOrbits(o1, [n2, n3])
plotOrbits([o1, o2, o3], [n2, n3])

# df = plotOrbits(o1)
