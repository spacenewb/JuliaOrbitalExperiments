# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to plotting various orbit related things.
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

export plotOrbits

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
function plot_orbit!(
    orbit::Orbit,
    line_props,
    fig_handle=nothing,
)
    μ = orbit.body.μ;

    u0 = orbit.state.vec;

    T = 2*pi*sqrt(Float64(orbit.kepler.a)^3/μ);
    tspan = (0.0, T);

    prob = ODEProblem(ode_2bp!, u0, tspan, μ);

    sol = solve(prob, AutoTsit5(Rosenbrock23()), reltol = 1e-12, abstol = 1e-14);

    plot!(
        fig_handle,
        sol,
        idxs = (1, 2, 3),
        lab = orbit.name,
        legend = true,
        line = line_props,
    );
    return nothing
end

"""
    plot_body(body::Body, pos::Vector{<:Number}, scale::Number, transparency::Number)

Plot the body.

# Remarks

The algorithm was obtained from \\[1] (accessed on 2022-07-20).

# References

- **[1]**: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
"""
function plot_body!(
    body::Body,
    pos::Vector{<:Number}=[0.0, 0.0, 0.0],
    scale::Number=1.0,
    transparency::Number=0.8,
    fig_handle=nothing,
)

    plot!(
        fig_handle,
        [pos[1]],
        [pos[2]],
        [pos[3]],
        lab = body.name,
        marker = (body.radius*scale/100, transparency, body.color,
        stroke(1, :white)),
        line = (0.0, :solid, :transparent),
    );
    return nothing
end

"""
    plot_node(node::Node, marker)

Plot the node.

# Remarks

`marker` is a tuple of (markersize, markeralpha, markercolor, markeroutline),
    eg. marker = (100, 0.5, :red, stroke(1, :white))

The algorithm was obtained from \\[1] (accessed on 2022-07-20).

# References

- **[1]**: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
"""
function plot_nodes!(orbit::Orbit, fig_handle=nothing, node_flag="all")

    all_nodes_names_list = []
    for nd in orbit.nodes
        all_nodes_names_list = [all_nodes_names_list; nd.name]
    end

    node_to_plot_names_list = []
    unavailable_nodes_names = []
    if node_flag isa Node

        if (findfirst(all_nodes_names_list .== node_flag.name)!==nothing)
            node_to_plot_names_list = node_flag.name
        else
            unavailable_nodes_names = [unavailable_nodes_names; node_flag.name]
        end

    elseif node_flag isa Vector{Node}
        unique!(node_flag)
        for nd in node_flag
            if (findfirst(all_nodes_names_list .== nd.name)!==nothing)
                node_to_plot_names_list = [node_to_plot_names_list; nd.name]
            else
                unavailable_nodes_names = [unavailable_nodes_names; nd.name]
            end
        end

    elseif node_flag == "all"
        node_to_plot_names_list = all_nodes_names_list
    end

    i = 1;
    for ndpos in orbit.nodepos
        node_name = orbit.nodes[i].name

        if (findfirst(node_to_plot_names_list .== node_name)!==nothing)

            x = [ndpos[1]]
            y = [ndpos[2]]
            z = [ndpos[3]]

            plot!(
                fig_handle,
                x,
                y,
                z,
                seriestype=:scatter,
                lab = node_name,
                legend = true,
                ms=5,
                ma=1,
                mc=parse(Colorant, RGB(rand(), rand(), rand())),
                msw=2;
                shape=:xcross,
            );
        end
        i += 1
    end

    if !isempty(unavailable_nodes_names)
        @warn ("Requested Node <$(unavailable_nodes_names)> is not found in the Orbit <$(orbit.name)>")
        # println("Requested Node <$(unavailable_nodes_names)> is not found in the Orbit <$(orbit.name)>")
    end

    return nothing
end

"""
    plotOrbits(orbits::Union{Orbit, Vector{Orbit}}, line_props, scale::Number, transparency::Number)

Plot the body.

# Remarks

`line_props` is a tuple of (linewidth, linestyle, linecolor),
    eg. line_props=(1, :solid, :white)

The algorithm was obtained from \\[1] (accessed on 2022-07-20).

# References

- **[1]**: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
"""
function plotOrbits(
    orbits::Union{Orbit, Vector{Orbit}},
    nodes::Union{Node, Vector{Node}, String},
    line_props=(1, :solid, :white),
    scale::Number=1.0,
    transparency::Number=0.8
)
    if (orbits isa Orbit)
        fig = plot(bg=:black);
        plot_body!(orbits.body, [0.0;0.0;0.0], scale, transparency, fig)
        plot_orbit!(orbits, line_props, fig)
        plot_nodes!(orbits, fig, nodes)
        display(fig)
    elseif (orbits isa Vector{Orbit})
        orb_body_list = []
        orb_body_name_list = []
        for orb in orbits
            orb_body_list = [orb_body_list; orb.body]
            orb_body_name_list = [orb_body_name_list; orb.body.name]
        end

        uniquebodylist = unique(orb_body_list)

        for curr_body in uniquebodylist
            fig = plot(bg=:black);

            plot_body!(curr_body, [0.0;0.0;0.0], scale, transparency, fig)

            orbits_in_this_body = orbits[findall(orb_body_name_list .== curr_body.name)]

            xl_p = []
            xl_m = []
            yl_p = []
            yl_m = []
            zl_p = []
            zl_m = []
            for orbit in orbits_in_this_body
                lp = (
                    line_props[1],
                    line_props[2],
                    parse(Colorant, RGB(rand(), rand(), rand()))
                )

                plot_orbit!(orbit, lp, fig)
                plot_nodes!(orbit, fig, nodes)

                xl_p = [xl_p; xlims()[2]]
                xl_m = [xl_m; xlims()[1]]
                yl_p = [yl_p; ylims()[2]]
                yl_m = [yl_m; ylims()[1]]
                zl_p = [zl_p; zlims()[2]]
                zl_m = [zl_m; zlims()[1]]
            end
            xlims!(minimum(xl_m), maximum(xl_p))
            ylims!(minimum(yl_m), maximum(yl_p))
            zlims!(minimum(zl_m), maximum(zl_p))

            display(fig)
        end
    end
    return nothing
end
