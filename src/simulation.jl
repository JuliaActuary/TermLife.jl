using Accessors: @set
using Dates

struct SimulationModel
  # Future improvements:
  # - Use a realistic value for the mortality rate, e.g. from tables.
  "Annual mortality rate."
  mortality_rate::Float64
  "Annual lapse rate. Payments all occur every month."
  lapse_rate::Float64
end

struct Policy
  from::Date
  premium::Float64
  # A claim means the person died.
  claim_date::Union{Date, Nothing}
  # For now, if we lapse we permanently cancel the policy.
  lapse_date::Union{Date, Nothing}
end

Policy(from, premium = 20.0) = Policy(from, premium, nothing, nothing)

isstarted(policy, date) = policy.from ≤ date
isterminated(policy::Policy) = !isnothing(policy.claim_date) || !isnothing(policy.lapse_date)

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
    monthly_mortality_rate = compute_monthly_rate(date, date + Month(1) - Day(1), model.mortality_rate)
    died = rand() < monthly_mortality_rate
    if died
      date_of_death = rand(date:Day(1):(date + Month(1) - Day(1)))
      policies[i] = @set policy.claim_date = date_of_death
    else
      # TODO: Compute how many payments were due between the previous and current simulation dates.
      number_of_due_payments = 1
      # TODO: Adjust the lapse rate based on annual lapse rate and number of due payments.
      policy_lapse_rate = compute_monthly_rate(date, date + Month(1) - Day(1), model.lapse_rate)
      lapsed = rand() < policy_lapse_rate
      if lapsed
        # TODO: Pick a date among the dates of due payments instead of a random one.
        lapse_date = rand(date:Day(1):(date + Month(1) - Day(1)))
        policies[i] = @set policy.lapse_date = lapse_date
      end
    end
  end
  policies
end

function compute_monthly_rate(from::Date, to::Date, annual_rate::Float64)::Float64
  1 - (1 - annual_rate)^((Dates.value(to - from) + 1)/365.25)
end
