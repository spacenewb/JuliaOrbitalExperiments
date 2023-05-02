#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Definition of constants.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
#
#   [1] https://nssdc.gsfc.nasa.gov/planetary/factsheet/
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

# Celestial bodies - Stars, Planets, Moons and Minors [1]
# Stars
const Sol = Body("Sol", "Star", 696340, 1.989e30, colorant"#FE880D");

# Planets
const Mercury = Body("Mercury", "Planet", 4879/2, 0.330e24, colorant"#968275");
const Venus = Body("Venus", "Planet", 12104/2, 4.87e24, colorant"#D4C9B3");
const Earth = Body("Earth", "Planet", 12756/2, 5.97e24, colorant"#374A6A");
const Mars = Body("Mars", "Planet", 6792/2, 0.642e24, colorant"#DD663C");
const Jupiter = Body("Jupiter", "Planet", 142984/2, 1898e24, colorant"#E4C1AA");
const Saturn = Body("Saturn", "Planet", 120536/2, 568e24, colorant"#C5AE84");
const Uranus = Body("Uranus", "Planet", 51118/2, 86.8e24, colorant"#84A7AF");
const Neptune = Body("Neptune", "Planet", 49528/2, 102e24, colorant"#7E85DE");

# Moons
const Luna = Body("Luna", "Moon", 3475/2, 0.073e24, colorant"#98959A");

# Minors
const Pluto = Body("Pluto", "Minor", 2376/2, 0.0130e24, colorant"#5B4141");

# Alias
const Sun = Sol;
const Moon = Luna;
