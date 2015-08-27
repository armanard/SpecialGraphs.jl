##
##!------------------------------------------------------------------------------------------------!
##  graph.jl
##
##  Graph (undirected) types and associated functions.
##  All functions except those with a "ß_" prefix are unsafe.
##
##  Creation date: 16/08/15
##  Author: Arindam Biswas <arindam dot b at eml dot cc>
##!------------------------------------------------------------------------------------------------!
##


# The base graph type.
abstract Graph

abstract BareGraph

type GraphException <: Exception
end

type GraphDynamic <: Graph
    order::UInt32
    size::UInt64
    adjacencies::Vector{Vector{UInt32}}
    vertex_info::Vector{Int64}
    edge_info::Vector{Vector{Int64}}
    vertex_indicator::Vector{Bool} # vertex_indicator[u] is true if u is in the graph.
end

type GraphStatic <: Graph
    order::UInt32
    size::UInt64
    adjacencies::Vector{Vector{UInt32}}
    vertex_info::Vector{Int64}
    edge_info::Vector{Vector{Int64}}
end

type BareGraphDynamic <: BareGraph
    order::UInt32
    size::UInt64
    adjacencies::Vector{Vector{UInt32}}
    vertex_indicator::Vector{Bool} # vertex_indicator[u] is true if u is in the graph.
end

type BareGraphStatic <: BareGraph
    order::UInt32
    size::UInt64
    adjacencies::Vector{Vector{UInt32}}
end

function GraphDynamic(order::UInt32)
    adjacencies = Vector{Vector{UInt32}}(order)
    vertex_info = Vector{Int64}(order)
    edge_info = Vector{Vector{Int64}}(order)
    vertex_indicator = Vector{Bool}(order)

    for i in 1:order
        adjacencies[i] = Vector{UInt32}()
        edge_info[i] = Vector{Int64}()
        vertex_indicator[i] = true
    end
    return GraphDynamic(order, UInt64(0), adjacencies, vertex_info, edge_info, vertex_indicator)
end

function GraphStatic(order::UInt32)
    adjacencies = Vector{Vector{UInt32}}(order)
    vertex_info = Vector{Int64}(order)
    edge_info = Vector{Vector{Int64}}(order)

    for i in 1:order
        adjacencies[i] = Vector{UInt32}()
        edge_info[i] = Vector{Int64}()
    end
    return GraphStatic(order, UInt64(0), adjacencies, vertex_info, edge_info)
end

function BareGraphDynamic(order::UInt32)
    adjacencies = Vector{Vector{UInt32}}(order)
    vertex_indicator = Vector{Bool}(order)

    for i in 1:order
        adjacencies[i] = Vector{UInt32}()
        vertex_indicator[i] = true
    end
    return BareGraphDynamic(order, UInt64(0), adjacencies, vertex_indicator)
end

function BareGraphStatic(order::UInt32)
    adjacencies = Vector{Vector{UInt32}}(order)

    for i in 1:order
        adjacencies[i] = Vector{UInt32}()
    end
    return BareGraphStatic(order, UInt64(0), adjacencies)
end

## Properties
order(g::Union{Graph, BareGraph}) = g.order
size(g::Union{Graph, BareGraph}) = g.size
degree(g::Union{Graph, BareGraph}, u::UInt32) = length(g.adjacencies[u])

## Access
function vertices(g::Union{GraphDynamic, BareGraphDynamic})
    vertices = Vector{UInt32}(g.order)
    # order keeps changing; use length of vertex_indicator.
    i, j = length(g.vertex_indicator), g.order
    while i >= 1
        if g.vertex_indicator[i]
            vertices[j] = i
            j -= 1
        end
        i -= 1
    end
    return vertices
end

function vertices(g::Union{GraphStatic, BareGraphStatic})
    return Vector{UInt32}(1:g.order)
end

function edges(g::Union{GraphDynamic, BareGraphDynamic})
    edges = Vector{Tuple{UInt32, UInt32}}(g.size)
    j = 1
    l = length(g.vertex_indicator)
    for i in 1:l
        if !g.vertex_indicator[i]
            continue
        end
        for t in g.adjacencies[i]
            if i < t
                edges[j] = (i, t)
                j += 1
            end
        end
    end
    return edges
end

function edges(g::Union{GraphStatic, BareGraphStatic})
    edges = Vector{Tuple{UInt32, UInt32}}(g.size)
    j = 1
    for i in 1:g.order
        for t in g.adjacencies[i]
            if i < t
                edges[j] = (i, t)
                j += 1
            end
        end
    end
    return edges
end

function exists(g::Union{GraphDynamic, BareGraphDynamic}, u::UInt32)
    return g.vertex_indicator[u]
end

function exists(g::Union{GraphStatic, BareGraphStatic}, u::UInt32)
    return 0 < u <= g.order
end

# Finds the index of u in l or returns 0, if u is not in l.
function _find_index(l::Vector{UInt32}, u::UInt32)
    for i in 1:length(l)
        if u == l[i]
            return i
        end
    end
    return 0
end

function adjacent(g::Union{GraphDynamic, BareGraphDynamic}, u::UInt32, v::UInt32)
    return _find_index(g.adjacencies[u], v) != 0
end

# Does a binary search on l[i:j] and returns the index if u is found, or 0 if not.
function _binary_search(l::Vector{UInt32}, i::UInt32, j::UInt32, u::UInt32)
    # l contains tuples of the form (target, edgeinfo).
    if i == j
        return l[i] == u ? i : 0
    end

    k = uint32((i + j) / 2)
    v = l[k]
    if u < v
        return _binary_search(l, i, k, u)
    elseif u > v
        return _binary_search(l, k + 1, j, u)
    else
        return k
    end
end

function adjacent(g::Union{GraphStatic, BareGraphStatic}, u::UInt32, v::UInt32)
    # For static graphs, the adjacency list is sorted.
    return _binary_search(g.adjacencies[u], 1, length(g.adjacencies[u]), v) != 0
end

function neighbours(g::Union{Graph, BareGraph}, u::UInt32)
    return g.adjacencies[u]
end

function vertex_info(g::Union{GraphDynamic, GraphStatic}, u::UInt32)
    return g.vertex_info[u]
end

function edge_info(g::GraphDynamic, u::UInt32, v::UInt32)
    l = g.edge_info[u]
    return l[_find_index(g.adjacencies[u], v)]
end

function edge_info(g::GraphStatic, u::UInt32, v::UInt32)
    l = g.edge_info[u]
    return l[_binary_search(g.adjacencies[u], 1, length(g.adjacencies[u]), v)]
end

## Mutation
function add_vertex!(g::GraphDynamic)
    # The vertex is added at the end.
    push!(g.adjacencies, Vector{UInt32}())
    push!(g.vertex_info, Int64(0))
    push!(g.edge_info, Vector{Int64}())
    push!(g.vertex_indicator, true)
    g.order += 1
end

function add_vertex!(g::GraphDynamic, u::UInt32)
    # Assume u was previously deleted.
    g.vertex_indicator[u] = true
    g.order += 1
end

function add_vertex!(g::BareGraphDynamic)
    # The vertex is always added at the end.
    push!(g.adjacencies, Vector{UInt32}())
    push!(g.vertex_indicator, true)
    g.order += 1
end

function add_vertex!(g::BareGraphDynamic, u::UInt32)
    # Assume u was previously deleted.
    g.vertex_indicator[u] = true
    g.order += 1
end

function add_edge!(g::GraphDynamic, u::UInt32, v::UInt32)
    push!(g.adjacencies[u], v)
    push!(g.edge_info[u], v)
    # Store duplicates for the "reverse edge" too. neighbours() needs this.
    push!(g.adjacencies[v], u)
    push!(g.edge_info[v], u)
    g.size += 1
end

function add_edge!(g::BareGraphDynamic, u::UInt32, v::UInt32)
    push!(g.adjacencies[u], v)
    # Store a duplicate for the "reverse edge" too. neighbours() needs this.
    push!(g.adjacencies[v], u)
    g.size += 1
end

function remove_vertex!(g::Union{GraphDynamic, BareGraphDynamic}, u::UInt32)
    # Do not actually remove the vertex, only set vertex_indicator[u] to false.
    g.vertex_indicator[u] = false
    # Remove all edges incident with u.
    n = copy(g.adjacencies[u])
    for v in n
        remove_edge!(g, u, v)
    end
    g.order -= 1
end

function remove_edge!(g::GraphDynamic, u::UInt32, v::UInt32)
    n = g.adjacencies[u]
    l = g.edge_info[u]
    # Find the index of v in the adjacency list.
    i = _find_index(n, v)
    n[i] = n[end]
    pop!(n)
    l[i] = l[end]
    pop!(l)

    # Do the same thing for the "reverse edge".
    n = g.adjacencies[v]
    l = g.edge_info[v]
    i = _find_index(n, u)
    n[i] = n[end]
    pop!(n)
    l[i] = l[end]
    pop!(l)
    g.size -= 1
end

function remove_edge!(g::BareGraphDynamic, u::UInt32, v::UInt32)
    n = g.adjacencies[u]
    # Find the index of v in the adjacency list.
    i = _find_index(n, v)
    n[i] = n[end]
    pop!(n)

    # Do the same thing for the "reverse edge".
    n = g.adjacencies[v]
    i = _find_index(n, u)
    n[i] = n[end]
    pop!(n)
    g.size -= 1
end

function vertex_info!(g::Union{GraphDynamic, GraphStatic}, u::UInt32, info::Int64)
    g.vertex_info[u] = info
end

function edge_info!(g::Union{GraphDynamic, GraphStatic}, u::UInt32, v::UInt32, info::Int64)
    i = _find_index(g.adjacencies[u], v)
    g.edge_info[u][i] = info
    # Do the same for the "reverse edge".
    i = _find_index(g.adjacencies[v], u)
    g.edge_info[v][i] = info
end
