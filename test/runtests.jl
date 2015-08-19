using Compat

tests = [
    "common",
    "graph",
    "digraph"
    ]


for t in tests
    tp = joinpath(dirname(@__FILE__), "$(t).jl")
    println("Running $(tp)...")
    include(tp)
end
