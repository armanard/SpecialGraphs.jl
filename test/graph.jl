##
##!------------------------------------------------------------------------------------------------!
##  graph.jl
##
##  Tests for graph.jl
##
##  Creation date: 18/08/15
##  Author: Arindam Biswas <arindam dot b at eml dot cc>
##!------------------------------------------------------------------------------------------------!
##


using SpecialGraphs
using Base.Test


g = GraphDynamic(UInt32(20))
h = BareGraphDynamic(UInt32(30))

@test order(g) == 20
@test order(h) == 30
add_vertex!(g)
@test order(g) == 21
add_vertex!(h)
add_vertex!(h)
add_vertex!(h)
@test order(h) == 33
add_edge!(g, UInt32(9), UInt32(7))
@test degree(g, UInt32(7)) == 1
@test size(g) == 1
add_edge!(h, UInt32(19), UInt32(1))
add_edge!(h, UInt32(4), UInt32(27))
@test size(h) == 2
add_edge!(h, UInt32(19), UInt32(1))
add_edge!(h, UInt32(4), UInt32(19))
add_edge!(h, UInt32(10), UInt32(21))
add_edge!(h, UInt32(8), UInt32(10))
@test degree(h, UInt32(19)) == 3
@test degree(h, UInt32(10)) == 2

@test length(vertices(g)) == 21
remove_vertex!(g, UInt32(19))
@test length(edges(g)) == 1
@test size(g) == 1
remove_vertex!(g, UInt32(7))
@test length(edges(g)) == 0
@test length(vertices(g)) == 19
@test size(g) == 0
@test order(g) == 19
@test degree(g, 1) == 0
@test length(vertices(h)) == 33
@test order(h) == 33
@test length(edges(h)) == 6
@test size(h) == 6
remove_vertex!(h, UInt32(19))
@test length(edges(h)) == 4
@test size(h) == 4
@test length(vertices(h)) == 32
@test order(h) == 32
@test degree(h, 4) == 0

for u in 1:5
    @test !adjacent(g, UInt32(u + 20), UInt32(26 - u))
    @test exists(g, UInt32(u))
    @test !adjacent(h, UInt32(u + 30), UInt32(36 - u))
    @test exists(h, UInt32(u))
end
add_edge(g, UInt32(21), UInt32(25))
@test adjacent(g, UInt32(25), UInt32(21))
add_edge(h, UInt32(31), UInt32(35))
@test adjacent(h, UInt32(35), UInt32(31))

@test isempty(neighbours(g, UInt32(1)))
@test isempty(neighbours(h, UInt32(4)))

edge_info!(g, UInt32(9), UInt32(7), 10)
add_edge!(g, UInt32(7), UInt32(8))
edge_info!(g, UInt32(8), UInt32(7), 1)
add_edge!(g, UInt32(17), UInt32(6))
add_edge!(g, UInt32(4), UInt32(1))
@test edge_info(g, UInt32(9), UInt32(7)) == 10
@test adjacent(g, UInt32(2), UInt32(7)) == false
@test adjacent(g, UInt32(7), UInt32(9)) == true
@test edge_info(g, UInt32(8), UInt32(7)) == 1
@test adjacent(g, UInt32(6), UInt32(17)) == true
remove_edge!(g, UInt32(6), UInt32(17))
@test adjacent(g, UInt32(6), UInt32(17)) == false
@test size(g) == 3

