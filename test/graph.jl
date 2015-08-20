##
##!------------------------------------------------------------------------------------------------!
##  graph.jl
##
##  Tests for graph.jl.
##
##  Creation date: 18/08/15
##  Author: Arindam Biswas <arindam dot b at eml dot cc>
##!------------------------------------------------------------------------------------------------!
##


using SpecialGraphs
using Base.Test

for g in (GraphDynamic(UInt32(9)), BareGraphDynamic(UInt32(9)))
    # After initialization, order = 9, size = 0, degree(*) = 0
    # vertices = 1:9, edges = [], neighbours(*) = []
    # exists(*) = true, adjacent(*, *) = false
    @test order(g) == 9
    @test size(g) == 0
    for i in 1:9
        @test degree(g, UInt32(i)) == 0
        @test length(neighbours(g, UInt32(i))) == 0
        @test exists(g, UInt32(i))
    end

    @test length(vertices(g)) == 9
    @test length(edges(g)) == 0

    @test !adjacent(g, UInt32(1), UInt32(2))   # 1 -- 2
    @test !adjacent(g, UInt32(3), UInt32(2))   # 2 -- 3
    @test !adjacent(g, UInt32(5), UInt32(7))   # 5 -- 7
    @test !adjacent(g, UInt32(3), UInt32(6))   # 3 -- 6
    @test !adjacent(g, UInt32(4), UInt32(2))   # 2 -- 4
    @test !adjacent(g, UInt32(5), UInt32(8))   # 5 -- 8
    @test !adjacent(g, UInt32(9), UInt32(3))   # 3 -- 9

    # Add a vertex and edges corresponding to the tests above.
    add_vertex!(g)
    add_edge!(g, UInt32(1), UInt32(2))   # 1 -- 2
    add_edge!(g, UInt32(3), UInt32(2))   # 2 -- 3
    add_edge!(g, UInt32(5), UInt32(7))   # 5 -- 7
    add_edge!(g, UInt32(3), UInt32(6))   # 3 -- 6
    add_edge!(g, UInt32(4), UInt32(2))   # 2 -- 4
    add_edge!(g, UInt32(5), UInt32(8))   # 5 -- 8
    add_edge!(g, UInt32(9), UInt32(3))   # 3 -- 9

    # If g is not a bare graph, add vertex and edge information.
    if (typeof(g) == GraphDynamic)
        vertex_info!(g, UInt32(3), Int64(10))
        vertex_info!(g, UInt32(4), Int64(2))
        vertex_info!(g, UInt32(5), Int64(7))
        edge_info!(g, UInt32(2), UInt32(1), Int64(11))
        edge_info!(g, UInt32(3), UInt32(2), Int64(17))
        edge_info!(g, UInt32(2), UInt32(4), Int64(13))
        edge_info!(g, UInt32(9), UInt32(3), Int64(7))
    end

    # Here, order = 10, size = 7, degree(1) = 1, degree(2) = 3, degree(3) = 3, degree(5) = 2
    # length(vertices) = 10 , length(edges) = 7, sort(neighbours(3)) = [2, 6, 9], neighbours(6) = [3]
    # exists(*) = true, adjacent(1, 2) = true, adjacent(3, 2) = true, adjacent(8, 5) = true
    # adjacent(3, 6) = true, adjacent(3, 9) = true, adjacent(5, 6) = false, adjacent(9, 2) = false
    @test order(g) == 10
    @test size(g) == 7
    @test degree(g, UInt32(1)) == 1
    @test degree(g, UInt32(2)) == 2
    @test degree(g, UInt32(3)) == 3
    @test degree(g, UInt32(5)) == 2

    @test length(vertices(g)) == 10
    @test length(edges(g)) == 7

    @test sort(neighbours(g, UInt32(3))) == [2, 6, 9]
    @test neighbours(g, UInt32(6)) == [3]

    for i in 1:10
        @test exists(g, UInt32(i))
    end

    @test adjacent(g, UInt32(1), UInt32(2))    # 1 -- 2
    @test adjacent(g, UInt32(3), UInt32(2))    # 2 -- 3
    @test adjacent(g, UInt32(8), UInt32(5))    # 5 -- 8
    @test adjacent(g, UInt32(3), UInt32(6))    # 3 -- 6
    @test adjacent(g, UInt32(3), UInt32(9))    # 3 -- 9
    @test !adjacent(g, UInt32(5), UInt32(6))   # 5 -- 6
    @test !adjacent(g, UInt32(9), UInt32(2))   # 2 -- 9

    # If g is not a bare graph, check vertex and edge information.
    if (typeof(g) == GraphDynamic)
        @test vertex_info(g, UInt32(3)) == Int64(10)
        @test vertex_info(g, UInt32(4)) == Int64(2)
        @test vertex_info(g, UInt32(5)) == Int64(7)
        @test edge_info(g, UInt32(2), UInt32(1)) == Int64(11)
        @test edge_info(g, UInt32(3), UInt32(2)) == Int64(17)
        @test edge_info(g, UInt32(2), UInt32(4)) == Int64(13)
        @test edge_info(g, UInt32(9), UInt32(3)) == Int64(7)
    end

    # Remove 2 vertices and 3 edges.
    remove_vertex!(g, UInt32(4))
    remove_vertex!(g, UInt32(7))
    remove_edge!(g, UInt32(1), UInt32(2))      # 1 -- 2
    remove_edge!(g, UInt32(3), UInt32(2))      # 2 -- 3
    remove_edge!(g, UInt32(8), UInt32(5))      # 5 -- 8

    # Here, order = 8, size = 4, degree(1) = 0, degree(2) = 1, degree(3) = 2, degree(5) = 1
    # length(vertices) = 8, length(edges) = 4, sort(neighbours(3)) = [6, 9], neighbours(6) = [3]
    # exists(3) = true, exists(4) = false, exists(6) = true, exists(7) = false
    # adjacent(1, 2) = false, adjacent(3, 2) = false, adjacent(8, 5) = false, adjacent(3, 6) = true,
    # adjacent(3, 9) = true, adjacent(5, 6) = false, adjacent(9, 2) = false
    @test order(g) == 8
    @test size(g) == 4
    @test degree(g, UInt32(1)) == 0
    @test degree(g, UInt32(2)) == 1
    @test degree(g, UInt32(3)) == 2

    @test length(vertices(g)) == 8
    @test length(edges(g)) == 4

    @test sort(neighbours(g, UInt32(3))) == [6, 9]
    @test neighbours(g, UInt32(6)) == [3]

    @test exists(g, UInt32(3))
    @test !exists(g, UInt32(4))
    @test exists(g, UInt32(6))
    @test !exists(g, UInt32(7))

    @test !adjacent(g, UInt32(1), UInt32(2))   # 1 -- 2
    @test !adjacent(g, UInt32(3), UInt32(2))   # 2 -- 3
    @test !adjacent(g, UInt32(8), UInt32(5))   # 5 -- 8
    @test adjacent(g, UInt32(3), UInt32(6))    # 3 -- 6
    @test adjacent(g, UInt32(3), UInt32(9))    # 3 -- 9
    @test !adjacent(g, UInt32(5), UInt32(6))   # 5 -- 6
    @test !adjacent(g, UInt32(9), UInt32(2))   # 2 -- 9

    # If g is not a bare graph, check vertex and edge information.
    if (typeof(g) == GraphDynamic)
        @test vertex_info(g, UInt32(3)) == Int64(10)
        # @test vertex_info(g, UInt32(4)) == Int64(2) deleted
        @test vertex_info(g, UInt32(5)) == Int64(7)
        # @test edge_info(g, UInt32(2), UInt32(1)) == Int64(11) deleted
        # @test edge_info(g, UInt32(3), UInt32(2)) == Int64(17) deleted
        @test edge_info(g, UInt32(2), UInt32(4)) == Int64(13)
        @test edge_info(g, UInt32(9), UInt32(3)) == Int64(7)
    end

    # Add a deleted vertex, a deleted edge and a new edge.
    add_vertex!(g, UInt32(4))
    add_edge!(g, UInt32(3), UInt32(2))
    add_edge!(g, UInt32(9), UInt32(2))

    # If g is not a bare graph, add vertex and edge information.
    if (typeof(g) == GraphDynamic)
        vertex_info!(g, UInt32(4), Int64(9))
        edge_info!(g, UInt32(3), UInt32(2), Int64(3))
        edge_info!(g, UInt32(2), UInt32(9), Int64(13))
    end

    # Here, order = 9, size = 6, degree(1) = 0, degree(2) = 3, degree(3) = 3, degree(5) = 1
    # length(vertices) = 9, length(edges) = 6, sort(neighbours(3)) = [2, 6, 9], neighbours(6) = [3]
    # exists(3) = true, exists(4) = true, exists(6) = true, exists(7) = false
    # adjacent(1, 2) = false, adjacent(3, 2) = true, adjacent(8, 5) = false, adjacent(3, 6) = true,
    # adjacent(3, 9) = true, adjacent(5, 6) = false, adjacent(9, 2) = true
    @test order(g) == 9
    @test size(g) == 6
    @test degree(g, UInt32(1)) == 0
    @test degree(g, UInt32(2)) == 3
    @test degree(g, UInt32(3)) == 3

    @test length(vertices(g)) == 9
    @test length(edges(g)) == 6

    @test sort(neighbours(g, UInt32(3))) == [2, 6, 9]
    @test neighbours(g, UInt32(6)) == [3]

    @test exists(g, UInt32(3))
    @test exists(g, UInt32(4))
    @test exists(g, UInt32(6))
    @test !exists(g, UInt32(7))

    @test !adjacent(g, UInt32(1), UInt32(2))   # 1 -- 2
    @test adjacent(g, UInt32(3), UInt32(2))    # 2 -- 3
    @test !adjacent(g, UInt32(8), UInt32(5))   # 5 -- 8
    @test adjacent(g, UInt32(3), UInt32(6))    # 3 -- 6
    @test adjacent(g, UInt32(3), UInt32(9))    # 3 -- 9
    @test !adjacent(g, UInt32(5), UInt32(6))   # 5 -- 6
    @test adjacent(g, UInt32(9), UInt32(2))    # 2 -- 9

    # If g is not a bare graph, check vertex and edge information.
    if (typeof(g) == GraphDynamic)
        @test vertex_info(g, UInt32(3)) == Int64(10)
        @test vertex_info(g, UInt32(4)) == Int64(9) # added again
        @test vertex_info(g, UInt32(5)) == Int64(7)
        # @test edge_info(g, UInt32(2), UInt32(1)) == Int64(11) deleted
        @test edge_info(g, UInt32(3), UInt32(2)) == Int64(3)  # added again
        @test edge_info(g, UInt32(2), UInt32(4)) == Int64(13)
        @test edge_info(g, UInt32(9), UInt32(3)) == Int64(7)
        @test edge_info(g, UInt32(9), UInt32(2)) == Int64(13) # new
    end
end
