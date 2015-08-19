##
##!------------------------------------------------------------------------------------------------!
##  digraph.jl
##
##  Digraphs and related functionality.
##
##  Creation date: 18/08/15
##  Author: Arindam Biswas <arindam dot b at eml dot cc>
##!------------------------------------------------------------------------------------------------!
##


abstract Digraph

abstract BareDigraph

type DigraphException <: Exception
end

type DigraphDynamic <: Digraph
    order::UInt32
    size::UInt64
    adjacencies::Vector{Vector{UInt32}}
    vertex_info::Vector{Int64}
    edge_info::Vector{Vector{Int64}}
    vertex_indicator::Vector{Bool} # vertex_indicator[u] is true if u is in the graph.
end

type DigraphStatic <: Digraph
    order::UInt32
    size::UInt64
    adjacencies::Vector{Vector{UInt32}}
    vertex_info::Vector{Int64}
    edge_info::Vector{Vector{Int64}}
end

type BareDigraphDynamic <: BareDigraph
    order::UInt32
    size::UInt64
    adjacencies::Vector{Vector{UInt32}}
    vertex_indicator::Vector{Bool} # vertex_indicator[u] is true if u is in the graph.
end

type BareDigraphStatic <: BareDigraph
    order::UInt32
    size::UInt64
    adjacencies::Vector{Vector{UInt32}}
end


