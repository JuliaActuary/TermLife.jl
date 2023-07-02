using TermLife: TermLife as tl
using Optim

# I was trying to make up some parameters for the GLM, optim makes it easier to get reasonable parameters.

######### LEVEL TERM #########
# Female is [1, 0], Male is [1, 1]. (intercept always 1)
function loss_levelterm(b)
  return (0.04 - tl.logistic(b, [1, 0]))^2 + (0.07 - tl.logistic(b, [1, 1]))^2
end
result = optimize(loss_levelterm, zeros(2), BFGS())
betas_levelterm = Optim.minimizer(result)
@assert 0.04 == round(tl.logistic(betas_levelterm, [1, 0]); digits=5)
println("betas_levelterm", betas_levelterm)

######### POST LEVEL TERM #########
# 5 cases so as to make system of equations maybe not overspecified
mps_params = [(0, 4.0), (0, 6.0), (0, 11.0), (0, 16.0), (1, 16.0)]
modelpoints = [tl.ModelPoint(i, j) for (i, j) in mps_params]
onehots = [tl.onehot_modelpoint(mp) for mp in modelpoints]
targets = [0.5, 0.6, 0.7, 0.8, 0.85]
function loss_postlevelterm(b)
  return sum([(targets[i] - tl.logistic(b, onehots[i]))^2 for i in eachindex(targets)])
end
result_plt = optimize(loss_postlevelterm, zeros(5), BFGS())
betas_plt = Optim.minimizer(result_plt)
@assert 0.85 ≈ tl.logistic(betas_plt, [1, 1, 0, 0, 1])
println("betas_plt", betas_plt)