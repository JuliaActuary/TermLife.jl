using ExperienceAnalysis
using Dates
using MortalityTables
using CSV
using DataFrames

const mort_df = Matrix{Float64}(CSV.read(joinpath(@__DIR__, "models", "mort_table.csv"), DataFrame)[:, 2:end])
const model_points = CSV.read(joinpath(@__DIR__, "models", "model_point_table.csv"), DataFrame)
const issue_age = model_points[:, :age_at_entry]
age = 70
mort = MortalityTables.table(3299)

get_month_ranges(policy_issued::Date, simulation_start::Date, simulation_end::Date) = exposure(
    ExperienceAnalysis.Anniversary(Month(1)),
    policy_issued,
    simulation_end;
    study_start = simulation_start,
    study_end = Date(2300, 1, 1),
)
rand()
get_month_ranges(policy_issued::Date, simulation_end::Date) = get_month_ranges(policy_issued, policy_issued, simulation_end)
get_month_ranges(policy_issued::Date) = get_month_ranges(policy_issued, policy_issued + Year(30) - Day(1))
get_month_ranges(Date(2019, 1, 15))
mort.select[70][70]
daily_mortality_rate(age::Int, duration::Int) = 1 - (1 - (mort.select[age][age + duration])) ^ (1 / 365)

function simulate(start_date::Date, age::Int, simlation_length::Year)
    month_ranges = get_month_ranges(start_date, start_date + simlation_length - Day(1))
    for (from, to, policy_timestep) in month_ranges
        duration = (policy_timestep - 1) ÷ 12
        for _ in from:Day(1):to
            if rand() < daily_mortality_rate(age, duration)
                # println("death")
                return 1
            end
        end
    end
    return 0
end

sum(simulate(Date(2019, 1, 15), 70, Year(1)) for _ in 1:10000) / 10000


