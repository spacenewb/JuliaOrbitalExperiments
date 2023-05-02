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

    if fig_handle === nothing
        plot!(
            sol,
            idxs = (1, 2, 3),
            lab = orbit.name,
            legend = true,
            line = line_props,
        );
    else
        plot!(
            fig_handle,
            sol,
            idxs = (1, 2, 3),
            lab = orbit.name,
            legend = true,
            line = line_props,
        );
    end
    println("orbit plotted!")
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

    if fig_handle === nothing
        plot!(
            [pos[1]], [pos[2]], [pos[3]],
            lab = body.name,
            marker = (body.radius*scale/100, transparency, body.color,
            stroke(1, :white)),
            line = (0.0, :solid, :transparent),
        );
    else
        plot!(
            fig_handle,
            [pos[1]], [pos[2]], [pos[3]],
            lab = body.name,
            marker = (body.radius*scale/100, transparency, body.color,
            stroke(1, :white)),
            line = (0.0, :solid, :transparent),
        );
    end
    println("body plotted!")
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
function plot_nodes!(orbit::Orbit, fig_handle=nothing)
    println("started plot_nodes!")
    x = []
    y = []
    z = []
    node_names = []
    for nd in orbit.nodes
        node_names = [node_names; nd.name]
    end
    for ndpos in orbit.nodepos
        x = [x; ndpos[1]]
        y = [y; ndpos[2]]
        z = [x; ndpos[3]]
    end

    println("------------------")
    println(x)
    println(y)
    println(z)
    println("------------------")

    if fig_handle === nothing
        plot!(
            x,
            y,
            z,
            seriestype=:scatter,
            lab = node_names,
            legend = true,
            marker = (100, 1, :red, stroke(20, :white)),
            line = (0.0, :solid, :transparent),
        );
    else
        plot!(
            fig_handle,
            x,
            y,
            z,
            seriestype=:scatter,
            lab = node_names,
            legend = true,
            marker = (10, 1, :red, stroke(2, :white)),
            line = (0.0, :solid, :transparent),
        );
    end
    println("node plotted!")
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
    line_props=(1, :solid, :white),
    scale::Number=1.0,
    transparency::Number=0.8
)
    if (orbits isa Orbit)
        fig = plot(bg=:black);
        plot_body!(orbits.body, [0.0;0.0;0.0], scale, transparency, fig)
        plot_orbit!(orbits, line_props, fig)
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
                    parse(Colorant, RGB(rand(1), rand(1), rand(1)))
                )

                plot_orbit!(orbit, lp, fig)
                println("Ki")
                plot_nodes!(orbit, fig)

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
