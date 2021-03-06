@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@testset "Test Modia3D" begin
   include("test_Graphics.jl")
   include("test_Solids.jl")
   include("test_solidProperties.jl")
   include("test_Composition.jl")
   include("test_DynamicExamples.jl")
   include("test_Renderer.jl")
   include("test_Examples.jl")

   include("runexamples.jl")

   println("\n... success of all tests!")
end
