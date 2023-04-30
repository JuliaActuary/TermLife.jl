module TermLife

using Dates
using PrecompileTools

# include("encodings.jl")
include("simulation.jl")

@compile_workload begin
  model = SimulationModel(1e-1, 1e-1)
  from = Date(2020, 1)
  policies = Policy.(rand((from - Month(5)):Day(1):(from + Month(5)), 100))
  simulate!(policies, from, Month(40), model)
end

export Policy, SimulationModel, simulate!

end # module TermLife
