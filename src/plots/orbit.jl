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
    ax::Union{Axis3, Axis}=current_axis(),
)
    μ = orbit.body.μ

    u0 = orbit.state.vec

    T = 2*pi*sqrt(Float64(orbit.kepler.a)^3/μ)
    tspan = (0.0, T)

    prob = ODEProblem(ode_2bp!, u0, tspan, μ)

    sol = solve(prob, AutoTsit5(Rosenbrock23()), reltol = 1e-12, abstol = 1e-14)

    x = getindex.(sol.u,1)
    y = getindex.(sol.u,2)
    z = getindex.(sol.u,3)

    lines!(
        ax,
        [x; x[end]],
        [y; y[end]],
        [z; z[end]],
        label = orbit.name,
    )

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
function make_sphere(n::Integer, r::Number, offset::Tuple)
    r = abs(r)
    θ = [0;(0.5:n-0.5)/n;1]
    φ = [(0:2n-2)*2/(2n-1);2]
    x = [r*cospi(φ)*sinpi(θ) for θ in θ, φ in φ] .+ offset[1]
    y = [r*sinpi(φ)*sinpi(θ) for θ in θ, φ in φ] .+ offset[2]
    z = [r*cospi(θ) for θ in θ, φ in φ] .+ offset[3]
    return (x=x, y=y, z=z)
end
function plot_body!(
    body::Body,
    pos::Tuple=(0.0, 0.0, 0.0),
    ax::Union{Axis3, Axis}=current_axis(),
)

    scatter!(
        ax,
        pos[1],
        pos[2],
        pos[3],
        label = body.name,
    )

    sph = make_sphere(9, body.radius, pos)
    surface!(
        ax,
        sph.x,
        sph.y,
        sph.z,
    )

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
function plot_nodes!(
    orbit::Orbit,
    node_flag="all",
    ax::Union{Axis3, Axis}=current_axis(),
)

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

            scatter!(
                ax,
                x,
                y,
                z,
                label = node_name,
            )
        end
        i += 1
    end

    if !isempty(unavailable_nodes_names)
        @warn ("Requested Node <$(unavailable_nodes_names)> is not found in the Orbit <$(orbit.name)>")
        # println("Requested Node <$(unavailable_nodes_names)> is not found in the Orbit <$(orbit.name)>")
    end

    return nothing
end

function make_equal_limits(
    ax::Union{Axis3, Axis}=current_axis(),
    centering_switch::Bool=true,
)
    xmin, ymin, zmin = minimum(ax.finallimits[])
    xmax, ymax, zmax = maximum(ax.finallimits[])

    min_l = min(xmin, ymin, zmin)
    max_l = min(xmax, ymax, zmax)

    if centering_switch
        abs_max_l = max(abs(min_l), abs(max_l))
        ax_l = (-abs_max_l, abs_max_l)
    else
        ax_l = (min_l, max_l)
    end

    limits!(ax, ax_l, ax_l, ax_l)
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
    nodes::Union{Node, Vector{Node}, String}="all",
)

    if (orbits isa Orbit)
        fig = Figure();
        ax = Axis3(
            fig[1, 1],
            aspect = (1.0,1.0,1.0),
            title = join(["Body: "; orbits.body.name; " | Orbit: "; orbits.name]),
            xlabel = "The x label",
            ylabel = "The y label",
            zlabel = "The z label",
            viewmode = :fit,
        );
        plot_body!(orbits.body, (0.0,0.0,0.0), ax)
        plot_orbit!(orbits, ax)
        plot_nodes!(orbits, nodes, ax)
        axislegend(position = :ct, orientation = :horizontal)
        display(GLMakie.Screen(), fig)
        make_equal_limits(ax, true)
    elseif (orbits isa Vector{Orbit})
        orb_body_list = []
        orb_body_name_list = []
        for orb in orbits
            orb_body_list = [orb_body_list; orb.body]
            orb_body_name_list = [orb_body_name_list; orb.body.name]
        end

        uniquebodylist = unique(orb_body_list)

        i = 1
        for curr_body in uniquebodylist
            fig = Figure();
            ax = Axis3(
                fig[1, 1],
                aspect = (1.0,1.0,1.0),
                xlabel = "The x label",
                ylabel = "The y label",
                zlabel = "The z label",
                viewmode = :fit,
            );

            plot_body!(curr_body, (0.0,0.0,0.0), ax)

            orbits_in_this_body = orbits[findall(orb_body_name_list .== curr_body.name)]

            orb_names = []
            for orbit in orbits_in_this_body
                orb_names = [orb_names; orbit.name]
                plot_orbit!(orbit, ax)
                plot_nodes!(orbit, nodes, ax)
            end
            orb_names = join( orb_names, ", ")
            ax.title = join(["Body: "; curr_body.name; " | Orbits: "; orb_names])

            axislegend(position = :ct, orientation = :horizontal)
            display(GLMakie.Screen(), fig)
            make_equal_limits(ax, true)
            i+=1
        end
    end
    return nothing
end
