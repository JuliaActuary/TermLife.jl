using Accessors: @set
using Dates

struct SimulationModel
  # Future improvements:
  # - Use a realistic value for the mortality rate, e.g. from tables.
  "Annual mortality rate."
  mortality_rate::Float64
  # lapse_rate::Float64
end

struct Policy
  from::Date
  premium::Float64
  claim_date::Union{Date, Nothing}
  # lapse_date::Union{Date, Nothing}
end

Policy(from, premium = 20.0) = Policy(from, premium, nothing)

isstarted(policy, date) = policy.from ≤ date
isterminated(policy::Policy) = !isnothing(policy.claim_date)

simulate!(policies, from::Date, duration, model::SimulationModel) = simulate!(policies, from, from + duration, model)

function simulate!(policies, from::Date, to::Date, model::SimulationModel)
  for date in from:Month(1):to
    simulate!(policies, date, model)
  end
  policies
end

function simulate!(policies, date, model::SimulationModel)
  for (i, policy) in enumerate(policies)
    !isstarted(policy, date) && continue
    isterminated(policy) && continue
    monthly_mortality_rate = get_mortality_over_range(date, date + Month(1) - Day(1), model.mortality_rate)
    died = rand() < monthly_mortality_rate
    if died
      date_of_death = rand(date:Day(1):(date + Month(1) - Day(1)))
      policies[i] = @set policy.claim_date = date_of_death
    end
  end
  policies
end

function get_mortality_over_range(from::Date, to::Date, rate::Float64)::Float64
  1 - (1 - rate)^((Dates.value(to - from) + 1)/365.25)
end
