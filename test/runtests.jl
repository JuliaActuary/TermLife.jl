using TermLife: TermLife as tl
using Test

@testset "TermLife.jl" begin
    @test round(tl.glm_prediction_test()[1], digits=3) == .912
    # Write your tests here.
end
