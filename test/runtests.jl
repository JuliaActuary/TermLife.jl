using TermLife: TermLife as tl
using Test

@testset "encodings" begin
    @test 1 == tl.encode_premiumjump(4.0)
    @test [0, 1, 0] == tl.onehot_segment_premiumjump(11.0)
    @test [1, 0, 1, 0, 0] == tl.onehot_modelpoint(tl.ModelPoint(0, 9.0, 10))
    @test 0.04 == round(tl.logistic(tl.levelterm_betas, [1, 0]), digits=5)
    @test 0.85 ≈ tl.logistic(tl.postlevelterm_betas, [1, 1, 0, 0, 1])
    mp1 = tl.ModelPoint(0, 4.0, 10)
    @test 0.04 == round(tl.lapse(mp1, 119); digits=5)
    @test 0.5 == round(tl.lapse(mp1, 120), digits=5)
end

@testset "dukes macdonald" begin
    base_lapses = 0.10
    total_lapses = 0.85
    effectiveness = 0.80
    select = 0.01
    point_in_scale = 0.03
    # sj;akjlf;skldj
    @test 3.67 == round(tl.dukes_macdonald1(point_in_scale, select, base_lapses, total_lapses, effectiveness) / point_in_scale; digits=2)
    @test 2.33 == round(tl.dukes_macdonald2(point_in_scale, select, base_lapses, total_lapses, effectiveness) / point_in_scale; digits=2)
    @test 2.00 == round(tl.dukes_macdonald3(point_in_scale, select, base_lapses, total_lapses, effectiveness) / point_in_scale; digits=2)
end
