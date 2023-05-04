
export cosmos_theme

function cosmos_theme()

    cosmos_theme = Theme(
        # Base Theme
        resolution = (600, 600),
        backgroundcolor = :black,
        textcolor = :gray50,

        # colormap=:linear_bmy_10_95_c78_n256,

        palette=(color = [:red, :blue]),

        # colormap,

        Lines=(
            linewidth = 2,
            linestyle = :solid,
        ),

        Scatter=(
            linestyle = :solid,
            linewidth = 1,
            markersize = 10,
            strokecolor = :white,
            strokewidth = 1,
        ),

        Surface = (
            shading = false,
            diffuse = Vec3f(0.4),
            specular = Vec3f(0.2),
            shininess = 32.0,

            colormap = :viridis,
        ),

        Axis = (
            # Misc
            palette = (color = [:red, :blue],),
            backgroundcolor = :red,

            # Grids
            xgridwidth = 1.5,
            ygridwidth = 1.5,
            xgridvisible = false,
            ygridvisible = false,
            xgridcolor = (:black, 0.07),
            ygridcolor = (:black, 0.07),

            xminorgridvisible = false,
            yminorgridvisible = false,
            xminorgridcolor = (:white, 0.5),
            yminorgridcolor = (:white, 0.5),

            # Axis Spines
            spinewidth = 0,
            leftspinevisible = true,
            rightspinevisible = false,
            bottomspinevisible = true,
            topspinevisible = false,

            # Axis Ticks
            xminorticksvisible = false,
            yminorticksvisible = false,

            xticksvisible = false,
            yticksvisible = false,
            xtickcolor = :gray21,
            ytickcolor = :gray21,
            xticksize = 4,
            yticksize = 4,
            xtickwidth = 1.5,
            ytickwidth = 1.5,
            xticklabelcolor = :gray31,
            yticklabelcolor = :gray31,

            # Axis Labels
            xlabelpadding = 3,
            ylabelpadding = 3
        ),

        Legend = (
            unique = true,
            bgcolor = :transparent,
            colgap = 16,
            rowgap = 3,
            margin = (0.0f0, 0.0f0, 0.0f0, 0.0f0),
            padding = (0, 0, 0, 0),
            orientation = :horizontal,

            titlevisible = false,
            titlefont = :bold,
            titlecolor = :white,
            titlegap = 8,
            titlehalign = :center,
            titlevalign = :center,
            titleposition = :top,
            titlesize = 16.0f0,

            framevisible = false,
            framecolor = :transparent,
            framewidth = 1,

            labelcolor = :white,
            labelfont = :regular,
            labelhalign = :left,
            labelvalign = :center,
            labeljustification = Makie.automatic,
            labelsize = 16.0f0,

            patchcolor = :transparent,
            patchlabelgap = 5,
            patchsize = (20.0f0, 20.0f0),
            patchstrokecolor = :transparent,
            patchstrokewidth = 1.0,

            # # Layout
            # alignmode = Inside(),
            # halign = :center,
            # valign = :center,
        ),

        Colorbar = (
            ticksvisible = false,
            ticklabelpad = 5,
            tickcolor = :white,
            tickalign = 1,
            ticklabelcolor = :gray31,

            spinewidth = 0,
            spinecolor = :white,
            topspinecolor = :white,
            bottomspinecolor = :white,
            leftspinecolor = :white,
            rightspinecolor = :white,
        ),

        Axis3 = (
            # Misc
            palette = (color = [:red, :blue],),
            aspect = (1.0,1.0,1.0),
            azimuth = 1.275pi,
            backgroundcolor = :transparent,
            elevation = pi / 8,
            protrusions = 30,
            perspectiveness = 0,
            viewmode = :fit,

            # Title
            titlevisible = true,
            titlealign = :center,
            titlecolor = :white,
            titlefont = :bold,
            titlegap = 4.0,
            titlesize = 16.0f0,

            # Grid
            xgridvisible = false,
            ygridvisible = false,
            zgridvisible = false,
            xgridcolor = RGBAf(1, 1, 1, 0.16),
            ygridcolor = RGBAf(1, 1, 1, 0.16),
            zgridcolor = RGBAf(1, 1, 1, 0.16),
            xgridwidth = 1,
            ygridwidth = 1,
            zgridwidth = 1,
            xminorgridvisible = false,
            yminorgridvisible = false,
            zminorgridvisible = false,

            # Axis Labels
            xlabelvisible = false,
            ylabelvisible = false,
            zlabelvisible = false,
            xlabelrotation = Makie.automatic,
            ylabelrotation = Makie.automatic,
            zlabelrotation = Makie.automatic,
            xlabelalign = Makie.automatic,
            ylabelalign = Makie.automatic,
            zlabelalign = Makie.automatic,
            xlabelcolor = :white,
            ylabelcolor = :white,
            zlabelcolor = :white,
            xlabelfont = :regular,
            ylabelfont = :regular,
            zlabelfont = :regular,
            xlabeloffset = 50,
            ylabeloffset = 50,
            zlabeloffset = 50,
            xlabelsize = 16.0f0,
            ylabelsize = 16.0f0,
            zlabelsize = 16.0f0,

            # Panels
            yzpanelvisible = false,
            xzpanelvisible = false,
            xypanelvisible = false,
            yzpanelcolor = :gray92,
            xzpanelcolor = :gray92,
            xypanelcolor = :gray92,

            # Axis Ticks
            xticks = WilkinsonTicks(5; k_min = 3),
            yticks = WilkinsonTicks(5; k_min = 3),
            zticks = WilkinsonTicks(5; k_min = 3),
            xtickwidth = 1,
            ytickwidth = 1,
            ztickwidth = 1,
            xticksvisible = false,
            yticksvisible = false,
            zticksvisible = false,
            xtickcolor = :white,
            ytickcolor = :white,
            ztickcolor = :white,
            xtickformat = Makie.automatic,
            ytickformat = Makie.automatic,
            ztickformat = Makie.automatic,

            # Axis Tick Labels
            xticklabelsvisible = false,
            yticklabelsvisible = false,
            zticklabelsvisible = false,
            xticklabelfont = :regular,
            yticklabelfont = :regular,
            zticklabelfont = :regular,
            xticklabelsize = 16.0f0,
            yticklabelsize = 16.0f0,
            zticklabelsize = 16.0f0,
            xticklabelcolor = :gray31,
            yticklabelcolor = :gray31,
            zticklabelcolor = :gray31,
            xticklabelpad = 3,
            yticklabelpad = 3,
            zticklabelpad = 6,

            # Spines
            xspinesvisible = true,
            yspinesvisible = true,
            zspinesvisible = true,
            xspinewidth = 3,
            yspinewidth = 3,
            zspinewidth = 3,
            xspinecolor_1 = :transparent,
            yspinecolor_1 = :transparent,
            zspinecolor_1 = :transparent,
            xspinecolor_2 = :gray30,
            yspinecolor_2 = :gray30,
            zspinecolor_2 = :gray30,
            xspinecolor_3 = :transparent,
            yspinecolor_3 = :transparent,
            zspinecolor_3 = :transparent,

        ),
    )
    return cosmos_theme
end
