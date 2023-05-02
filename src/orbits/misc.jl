# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to miscelleneous things in orbital mechanics.
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

export add_node, rm_node

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
function add_node(orb::Orbit, node::Node)
	return Orbit(
        orb.name,
        orb.kepler,
        orb.body,
        [orb.nodes; node]
    )
end

"""
    plot_orbit(orbit::Orbit, line_props)

Plot the orbit.

# Remarks

The algorithm was obtained from \\[1] (accessed on 2022-07-20).

# References

- **[1]**: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
"""
function rm_node(orb::Orbit, node::Node)
    nodeslist = orb.nodes

    namelist = []
    for nd in nodeslist
        namelist = [namelist; nd.name]
    end

    matchidx = findfirst(item -> item == node.name, namelist)

    if matchidx === nothing
        println("Node <$(node.name)> not found in Orbit <$(orb.name)>")
        return nothing
    else
        deleteat!(nodeslist, matchidx)
    end

	return Orbit(
        orb.name,
        orb.kepler,
        orb.body,
        nodeslist
    )
end
