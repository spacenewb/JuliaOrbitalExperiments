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

export add_node!, rm_node!

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
############### CHECK DUPLICATES BEFORE ADDING ###############
function add_node!(orb::Orbit, node::Node)

    duplicate_node = []
    duplicate = false
    for no in orb.nodes
        if (node == no)
            duplicate_node = node
            duplicate = true
        end
    end

    if !duplicate
        ndpos = [kepler_to_rv([orb.kepler.vec[1:5]; node.θ], orb.body.μ).pos]
        return Orbit(
            orb.name,
            orb.kepler,
            orb.body,
            push!(orb.nodes, node),
            append!(orb.nodepos, ndpos),
        )
    else
        @warn ("Found duplicate Node <$(duplicate_node)> pre-existing in Orbit <$(orb.name)>. \n
            Ignoring and proceeding...");
        return nothing
    end
end

function add_node!(orb::Orbit, node::Vector{Node})
    unique!(node)
    for nd in node
        add_node!(orb, nd)
    end
    return orb
end

"""
    plot_orbit(orbit::Orbit, line_props)

Plot the orbit.

# Remarks

The algorithm was obtained from \\[1] (accessed on 2022-07-20).

# References

- **[1]**: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
"""
function rm_node!(orb::Orbit, node::Node)
    if !isempty(orb.nodes)
        nodeslist = orb.nodes
        nodeposlist = orb.nodepos

        namelist = []
        for nd in nodeslist
            namelist = [namelist; nd.name]
        end

        matchidx = findall(item -> item == node.name, namelist)

        if matchidx === nothing
            @warn ("Node <$(node.name)> not found in Orbit <$(orb.name)>")
            return nothing
        else
            deleteat!(nodeslist, matchidx)
            deleteat!(nodeposlist, matchidx)
        end

        return Orbit(
            orb.name,
            orb.kepler,
            orb.body,
            nodeslist,
            nodeposlist
        )
    else
        @warn ("No Nodes found in Orbit <$(orb.name)> to remove")
        return nothing
    end
end

function rm_node!(orb::Orbit, node::Vector{Node})
    unique!(node)
    for nd in node
        rm_node!(orb, nd)
    end
    return orb
end
