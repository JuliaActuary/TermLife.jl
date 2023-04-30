using TermLife
using Dates
using Test

model = SimulationModel(1e-1)
from = Date(2020, 1)

random_policies(around::Date, spread::Int, n) = Policy.(rand((around - Month(spread)):Day(1):(around + Month(spread)), n))

@testset "Simulation of policies" begin
  n = 100
  policies = random_policies(from, 5, n)
  simulate!(policies, from, Month(40), model)
  @test count(x -> !isnothing(x.claim_date), policies) > 0.2n
  @test all(x -> isnothing(x.claim_date) || x.claim_date > x.from, policies)

  n = 10000
  policies = random_policies(from, 5, n)
  simulate!(policies, from, Year(50), model)
  @test count(x -> !isnothing(x.claim_date), policies) > 0.99n

  n = 1000000
  policies = random_policies(from, 0, n)
  simulate!(policies, from, Year(1) - Day(1), model)
  estimated_annual_mortality_rate = count(x -> !isnothing(x.claim_date), policies) / n
  @test isapprox(estimated_annual_mortality_rate, model.mortality_rate, atol=0.001)
end
