using TermLife: TermLife as tl
using Test

@test round(tl.glm_prediction_test()[1], digits=3) == .912
