# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   General structures related to plot styles.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


struct PlotStyle
	base::NamedTuple

    orbit::NamedTuple
    body::NamedTuple
    node::NamedTuple

    PlotStyle(
        base::NamedTuple,
        orbit::NamedTuple,
        body::NamedTuple,
        node::NamedTuple,
    ) = new(
        base,
        orbit,
        body,
        node,
    )
end
