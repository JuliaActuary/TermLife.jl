module TermLife
using Dates

include("encodings.jl")


struct State
    from::Date
    to::Date
    policy_timestep::Int
    mortality_table_index::Int
end

end # module TermLife
