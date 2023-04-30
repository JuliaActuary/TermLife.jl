function get_mortality_over_range(from::Date, to::Date, rate::Float64)::Float64
    1 - (1 - rate)^((Dates.value(to - from) + 1)/365.25)
end

function simulate()
    month_ranges = get_month_ranges(Date(2020,1,1), Date(2020,12,31))
    for (; from, to, policy_timestep) in month_ranges
        duration = (policy_timestep - 1) ÷ 12
        if rand() < get_mortality_over_range(from, to, .1)
            return 1
        end
    end
    return 0
end
