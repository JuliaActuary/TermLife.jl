using LinearAlgebra

struct ModelPoint
    gender::Int
    premium_jump::Float64
    term_length::Int
end

function encode_premiumjump(premium_jump::Float64)::Int
    premium_jump ≤ 5.0 && return 1
    5.0 < premium_jump ≤ 10.0 && return 2
    10.0 < premium_jump ≤ 15.0 && return 3
    return 4 # premium_jump > 15.0
end

function onehot_segment_premiumjump(premium_jump::Float64)::Vector{Int}
    encoded = encode_premiumjump(premium_jump)
    return [encoded == 2, encoded == 3, encoded == 4] # skip the first one
end

function onehot_modelpoint(mp::ModelPoint)::Vector{Int}
    # concat 1, isMale, onehot_segment_premiumjump
    return vcat(1, mp.gender, onehot_segment_premiumjump(mp.premium_jump))
end

logistic(b, x) = (1 / (1 + exp(-dot(b, x))))
# use optim to make parameters that are what we want
levelterm_betas = [-3.1780536385725715, 0.591364260890254]
postlevelterm_betas = [-6.953439443971817e-9, 0.3483066975132669, 0.40546512698832365, 0.8472978846239957, 1.3862943676090715]
lapse_levelterm(mp::ModelPoint) = logistic(levelterm_betas, [1, mp.gender])
lapse_postlevelterm(mp::ModelPoint) = logistic(postlevelterm_betas, onehot_modelpoint(mp))
lapse(mp::ModelPoint, timestep::Int) = (timestep ÷ 12) < mp.term_length ? lapse_levelterm(mp) : lapse_postlevelterm(mp)