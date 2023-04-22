using Test
using TermLife: TermLife as tl
@test round(tl.glm_prediction_test()[1], digits=3) == .912
# round a number to one decimal place

round(x, digits=1)
