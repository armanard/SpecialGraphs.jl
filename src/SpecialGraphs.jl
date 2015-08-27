##
##!------------------------------------------------------------------------------------------------!
##  SpecialGraphs.jl
##
##  The SpecialGraphs module.
##
##  Creation date: 16/08/15
##  Author: Arindam Biswas <arindam dot b at eml dot cc>
##!------------------------------------------------------------------------------------------------!
##


module SpecialGraphs
using Compat

import Base: start, done, next, show, ==, <
import Base: length, isempty, size, getindex, isless

export
    ### Types
    Reference,
    Graph, BareGraph, GraphDynamic, GraphStatic, BareGraphDynamic, BareGraphStatic,
    Digraph, BareDigraph, DigraphDynamic, DigraphStatic, BareDigraphDynamic, BareDigraphStatic,

    ### Exceptions
    GraphException, DigraphException,

    ### Functions
    ## Constructors

    ## Attributes
    order, size, degree,

    ## Lists
    vertices, edges,

    ## Existence
    exists, adjacent,

    ## Neighbourhood
    neighbours, neighbours_out, neighbours_in,

    ## Information
    vertex_info, edge_info, vertex_info!, edge_info!,

    ## Manipulation
    add_vertex!, add_edge!, remove_vertex!, remove_edge!



include("common.jl")
include("graph.jl")
include("digraph.jl")

end
