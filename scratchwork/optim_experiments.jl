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

# Checking dukes-macdonald without doing the algebra

using Optim

# replicating - https://www.soa.org/globalassets/assets/library/newsletters/product-development-news/2003/july/pdn-2003-iss56-doll-a.pdf

base_lapses = 0.10
total_lapses = 0.85
not_lapses = 1 - total_lapses
effectiveness = 0.80
select = 0.01
point_in_scale = 0.03
# sj;akjlf;skldj
excess_lapses = total_lapses - base_lapses
select_excess_lapses = effectiveness * excess_lapses
nonselect_excess_lapses = excess_lapses - select_excess_lapses
println("select_excess_lapses: ", select_excess_lapses)
println("nonselect_excess_lapses: ", nonselect_excess_lapses)
println("select_excess_lapses + nonselect_excess_lapses: ", select_excess_lapses + nonselect_excess_lapses)
# in solve_dm1, persisters are only those that do not lapse.
# total population is (select_excess_lapses + not_lapses)
function solve_dm1(x)
  return (point_in_scale * (select_excess_lapses + not_lapses) - (select_excess_lapses * select + not_lapses * x[1]))^2
end
res1 = optimize(solve_dm1, [0.0], BFGS())
mort1 = Optim.minimizer(res1)[1]
mort1 / point_in_scale

# in solve_dm2, persisters are the not lapsers and the nonselect excess lapsers.
# total population is (not_lapses + excess_lapses)
function solve_dm2(x)
  return (point_in_scale * (not_lapses + excess_lapses) - (select_excess_lapses * select + (nonselect_excess_lapses + not_lapses) * x[1]))^2
end
res2 = optimize(solve_dm2, [0.0], BFGS())
mort2 = Optim.minimizer(res2)[1]
mort2 / point_in_scale

# In solve_dm3, persisters are everyone that is not a select excess lapse.
# total population is everyone, 1 * point_in_scale
function solve_dm3(x)
  return (point_in_scale - (select_excess_lapses * select + (1 - select_excess_lapses) * x[1]))^2
end

res3 = optimize(solve_dm3, [0.0], BFGS())
mort3 = Optim.minimizer(res3)[1]
mort3 / point_in_scale