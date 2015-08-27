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
    adjacencies_out::Vector{Vector{UInt32}}
    adjacencies_in::Vector{Vector{UInt32}}
    vertex_info::Vector{Int64}
    edge_info::Vector{Vector{Int64}}
    vertex_indicator::Vector{Bool} # vertex_indicator[u] is true if u is in the graph.
end

type DigraphStatic <: Digraph
    order::UInt32
    size::UInt64
    adjacencies_out::Vector{Vector{UInt32}}
    adjacencies_in::Vector{Vector{UInt32}}
    vertex_info::Vector{Int64}
    edge_info::Vector{Vector{Int64}}
end

type BareDigraphDynamic <: BareDigraph
    order::UInt32
    size::UInt64
    adjacencies_out::Vector{Vector{UInt32}}
    adjacencies_in::Vector{Vector{UInt32}}
    vertex_indicator::Vector{Bool} # vertex_indicator[u] is true if u is in the graph.
end

type BareDigraphStatic <: BareDigraph
    order::UInt32
    size::UInt64
    adjacencies_out::Vector{Vector{UInt32}}
    adjacencies_in::Vector{Vector{UInt32}}
end

function DigraphDynamic(order::UInt32)
    adjacencies_out = Vector{Vector{UInt32}}(order)
    adjacencies_in = Vector{Vector{UInt32}}(order)
    vertex_info = Vector{Int64}(order)
    edge_info = Vector{Vector{Int64}}(order)
    vertex_indicator = Vector{Bool}(order)

    for i in 1:order
        adjacencies_out[i] = Vector{UInt32}()
        adjacencies_in[i] = Vector{UInt32}()
        edge_info[i] = Vector{Int64}()
        vertex_indicator[i] = true
    end
    return DigraphDynamic(order, UInt64(0), adjacencies_out, adjacencies_in,
        vertex_info, edge_info, vertex_indicator)
end

function DigraphStatic(order::UInt32)
    adjacencies_out = Vector{Vector{UInt32}}(order)
    adjacencies_in = Vector{Vector{UInt32}}(order)
    vertex_info = Vector{Int64}(order)
    edge_info = Vector{Vector{Int64}}(order)

    for i in 1:order
        adjacencies_out[i] = Vector{UInt32}()
        adjacencies_in[i] = Vector{UInt32}()
        edge_info[i] = Vector{Int64}()
    end
    return DigraphStatic(order, UInt64(0), adjacencies_out, adjacencies_in,
        vertex_info, edge_info)
end

function BareDigraphDynamic(order::UInt32)
    adjacencies_out = Vector{Vector{UInt32}}(order)
    adjacencies_in = Vector{Vector{UInt32}}(order)
    vertex_indicator = Vector{Bool}(order)

    for i in 1:order
        adjacencies_out[i] = Vector{UInt32}()
        adjacencies_in[i] = Vector{UInt32}()
        vertex_indicator[i] = true
    end
    return BareDigraphDynamic(order, UInt64(0), adjacencies_out, adjacencies_in,
        vertex_indicator)
end

function BareDigraphStatic(order::UInt32)
    adjacencies_out = Vector{Vector{UInt32}}(order)
    adjacencies_in = Vector{Vector{UInt32}}(order)

    for i in 1:order
        adjacencies_out[i] = Vector{UInt32}()
        adjacencies_in[i] = Vector{UInt32}()
    end
    return BareDigraphStatic(order, UInt64(0), adjacencies_out, adjacencies_in)
end

## Properties
order(g::Union{Graph, BareGraph}) = g.order
size(g::Union{Graph, BareGraph}) = g.size
degree(g::Union{Graph, BareGraph}, u::UInt32) = length(g.adjacencies_out[u])

## Access
function vertices(g::Union{DigraphDynamic, BareDigraphDynamic})
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

function vertices(g::Union{DigraphStatic, BareDigraphStatic})
    return Vector{UInt32}(1:g.order)
end

function edges(g::Union{DigraphDynamic, BareDigraphDynamic})
    edges = Vector{Tuple{UInt32, UInt32}}(g.size)
    j = 1
    l = length(g.vertex_indicator)
    for i in 1:l
        if !g.vertex_indicator[i]
            continue
        end
        for t in g.adjacencies_out[i]
            edges[j] = (i, t)
            j += 1
        end
    end
    return edges
end

function edges(g::Union{DigraphStatic, BareDigraphStatic})
    edges = Vector{Tuple{UInt32, UInt32}}(g.size)
    j = 1
    for i in 1:g.order
        for t in g.adjacencies_out[i]
            edges[j] = (i, t)
            j += 1
        end
    end
    return edges
end

function exists(g::Union{DigraphDynamic, BareDigraphDynamic}, u::UInt32)
    return g.vertex_indicator[u]
end

function exists(g::Union{DigraphStatic, BareDigraphStatic}, u::UInt32)
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

function adjacent(g::Union{DigraphDynamic, BareDigraphDynamic}, u::UInt32, v::UInt32)
    return _find_index(g.adjacencies_out[u], v) != 0
end

function adjacent(g::Union{DigraphStatic, BareDigraphStatic}, u::UInt32, v::UInt32)
    # For static graphs, the adjacency list is sorted.
    return _binary_search(g.adjacencies_out[u], 1, length(g.adjacencies_out[u]), v) != 0
end

function neighbours_out(g::Union{Graph, BareGraph}, u::UInt32)
    return g.adjacencies_out[u]
end

function neighbours_in(g::Union{Graph, BareGraph}, u::UInt32)
    return g.adjacencies_in[u]
end

function vertex_info(g::Union{DigraphDynamic, DigraphStatic}, u::UInt32)
    return g.vertex_info[u]
end

function edge_info(g::DigraphDynamic, u::UInt32, v::UInt32)
    l = g.edge_info[u]
    return l[_find_index(g.adjacencies_out[u], v)]
end

function edge_info(g::DigraphStatic, u::UInt32, v::UInt32)
    l = g.edge_info[u]
    return l[_binary_search(g.adjacencies_out[u], 1, length(g.adjacencies_out[u]), v)]
end

## Mutation
function add_vertex!(g::DigraphDynamic)
    # The vertex is added at the end.
    push!(g.adjacencies_out, Vector{UInt32}())
    push!(g.adjacencies_in, Vector{UInt32}())
    push!(g.vertex_info, Int64(0))
    push!(g.edge_info, Vector{Int64}())
    push!(g.vertex_indicator, true)
    g.order += 1
end

function add_vertex!(g::DigraphDynamic, u::UInt32)
    # Assume u was previously deleted.
    g.vertex_indicator[u] = true
    g.order += 1
end

function add_vertex!(g::BareDigraphDynamic)
    # The vertex is always added at the end.
    push!(g.adjacencies_out, Vector{UInt32}())
    push!(g.adjacencies_in, Vector{UInt32}())
    push!(g.vertex_indicator, true)
    g.order += 1
end

function add_vertex!(g::BareDigraphDynamic, u::UInt32)
    # Assume u was previously deleted.
    g.vertex_indicator[u] = true
    g.order += 1
end

function add_edge!(g::DigraphDynamic, u::UInt32, v::UInt32)
    push!(g.adjacencies_out[u], v)
    push!(g.adjacencies_in[v], u)
    push!(g.edge_info[u], v)
    g.size += 1
end

function add_edge!(g::BareDigraphDynamic, u::UInt32, v::UInt32)
    push!(g.adjacencies_out[u], v)
    push!(g.adjacencies_out[v], u)
    g.size += 1
end

function remove_vertex!(g::Union{DigraphDynamic, BareDigraphDynamic}, u::UInt32)
    # Do not actually remove the vertex, only set vertex_indicator[u] to false.
    g.vertex_indicator[u] = false
    # Remove all edges incident with u.
    n = copy(g.adjacencies_out[u])
    for v in n
        remove_edge!(g, u, v)
    end
    g.order -= 1
end

function remove_edge!(g::DigraphDynamic, u::UInt32, v::UInt32)
    no = g.adjacencies_out[u]
    ni = g.adjacencies_out[v]
    l = g.edge_info[u]
    # Find the index of v in the adjacency list.
    i = _find_index(no, v)
    j = _find_index(ni, u)
    no[i] = no[end]
    pop!(no)
    ni[j] = ni[end]
    pop!(ni)
    l[i] = l[end]
    pop!(l)

    g.size -= 1
end

function remove_edge!(g::BareDigraphDynamic, u::UInt32, v::UInt32)
    no = g.adjacencies_out[u]
    ni = g.adjacencies_out[u]
    # Find the index of v in the adjacency list.
    i = _find_index(no, v)
    j = _find_index(ni, u)
    no[i] = no[end]
    pop!(no)
    ni[j] = ni[end]
    pop!(ni)

    g.size -= 1
end

function vertex_info!(g::Union{DigraphDynamic, DigraphStatic}, u::UInt32, info::Int64)
    g.vertex_info[u] = info
end

function edge_info!(g::Union{DigraphDynamic, DigraphStatic}, u::UInt32, v::UInt32, info::Int64)
    i = _find_index(g.adjacencies_out[u], v)
    g.edge_info[u][i] = info
end
