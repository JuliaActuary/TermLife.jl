using StructArrays

struct ModelPoint
    mortality_index::Int
    issue_age::Int
    face_amount::Int
    months_between_payments::Int
    premium_jump::Float64
end

struct LapseEncodedModelPoint
    issue_age::Int
    encoded_riskclass::Int
    encoded_faceamount::Int
    encoded_premiummode::Int
    encoded_premiumjump::Int
end


function encode(modelpoint::StructArray{ModelPoint})::StructArray{LapseEncodedModelPoint}

    function encode_riskclass_3299mortalitytables(mortality_index::Int)::Int
        (mortality_index == 3299 || mortality_index == 3302) && return 1
        3299 <= mortality_index <= 3304 && return 2
        3305 ≤ mortality_index ≤ 3308 && return 3
        throw(DomainError(mortality_index, "Mortality index falls outside of the range of 3299 to 3308"))
    end

    function encode_faceamount(face_amount::Int)::Int
        face_amount < 50000 && return 1
        50000 ≤ face_amount < 100000 && return 2
        100000 ≤ face_amount < 250000 && return 3
        250000 ≤ face_amount < 1000000 && return 4
        return 5 # 1000000 ≤ face_amount
    end

    function encode_premiummode(months_between_payments::Int)::Int
        months_between_payments == 12 && return 1
        (months_between_payments == 6 || months_between_payments == 3) && return 2
        months_between_payments == 1 && return 3
        throw(DomainError(months_between_payments, "Should be 1, 3, 6, or 12 months between payments"))
    end

    function encode_premiumjump(premium_jump::Float64)::Int
        premium_jump ≤ 2.0 && return 1
        2.0 < premium_jump ≤ 3.0 && return 2
        3.0 < premium_jump ≤ 4.0 && return 3
        4.0 < premium_jump ≤ 5.0 && return 4
        5.0 < premium_jump ≤ 6.0 && return 5
        6.0 < premium_jump ≤ 7.0 && return 6
        7.0 < premium_jump ≤ 8.0 && return 7
        8.0 < premium_jump ≤ 10.0 && return 8
        10.0 < premium_jump ≤ 12.0 && return 9
        12.0 < premium_jump ≤ 16.0 && return 10
        16.0 < premium_jump ≤ 20.0 && return 11
        return 12 # 20.0 < premium_jump
    end

    return StructArray{LapseEncodedModelPoint}((
        issue_age=modelpoint.issue_age,
        encoded_riskclass=encode_riskclass_3299mortalitytables.(modelpoint.mortality_index),
        encoded_faceamount=encode_faceamount.(modelpoint.face_amount),
        encoded_premiummode=encode_premiummode.(modelpoint.months_between_payments),
        encoded_premiumjump=encode_premiumjump.(modelpoint.premium_jump),
    ))
end

abstract type GLMFactor end

struct Intercept <: GLMFactor
    intercept::Float64
end

struct NumericalPredictor <: GLMFactor
    variable::String
    coef::Float64
end

struct CategoricalPredictor <: GLMFactor
    variable::String
    levels::Vector{String}
    coef::Vector{Float64}
end

struct CategoricalNumericalPredictor <: GLMFactor
    variable_category::String
    variable_numerical::String
    levels_category::Vector{String}
    coef_category::Vector{Float64}
end

# make GLMFactor broadcastable so that you can broadcast 
Base.Broadcast.broadcastable(ic::GLMFactor) = Ref(ic)

struct T10_RGA
    intercept::Intercept
    issue_age::NumericalPredictor
    issue_age²::NumericalPredictor
    log_issue_age::NumericalPredictor
    risk_class::CategoricalPredictor
    face_amount_band::CategoricalPredictor
    premium_mode::CategoricalPredictor
    premium_jump::CategoricalPredictor
    premium_jump_issueage_interaction::CategoricalNumericalPredictor
end

t10_rga = T10_RGA(
    Intercept(3.2460468406),
    NumericalPredictor("issue_age", 0.1620764522),
    NumericalPredictor("issue_age²", -0.0006419533),
    NumericalPredictor("log_issue_age", -2.7246684047),
    CategoricalPredictor(
        "risk class",
        ["Super-Pref NS", "NS", "SM"],
        [0.0, 0.0342716521, 0.1204694398],
    ),
    CategoricalPredictor(
        "face amount band",
        ["<50k", "50k-99k", "100k-249k", "250k-999k", "1m+"],
        [0.0, 0.3153176726, 0.3436644806, 0.3651595476, 0.3645073212],
    ),
    CategoricalPredictor(
        "premium mode",
        ["Annual", "Semi/Quarterly", "Monthly"],
        [0.0, -0.0324429782, -0.2754860904],
    ),
    CategoricalPredictor(
        "premium jump band",
        ["≤2.0", "2.01-3.0", "3.01-4.0", "4.01-5.0", "5.01-6.0", "6.01-7.0", "7.01-8.0", "8.01-10.0", "10.01-12.0", "12.01-16.0", "16.01-20.0", "20.01+"],
        [0.0, 1.1346066041, 1.4915714326, 1.8259985157, 2.0823058090, 2.1180488165, 2.1759679756, 2.2456634786, 2.3042436895, 2.3424735883, 2.3845090119, 2.3560022176],
    ),
    CategoricalNumericalPredictor(
        "premium jump band",
        "issue_age",
        ["≤2.0", "2.01-3.0", "3.01-4.0", "4.01-5.0", "5.01-6.0", "6.01-7.0", "7.01-8.0", "8.01-10.0", "10.01-12.0", "12.01-16.0", "16.01-20.0", "20.01+"],
        [0.0, -0.0224086364, -0.0258942527, -0.0304205710, -0.0338345132, -0.0338073701, -0.0347925252, -0.0356704787, -0.0361533190, -0.0366500058, -0.0368730873, -0.0360120152],
    ),
)

function glm_summand(glm_factor::NumericalPredictor, x::Int)
    return glm_factor.coef * x
end

function glm_summand(glm_factor::CategoricalPredictor, x::Int)
    return glm_factor.coef[x]
end

function glm_summand(glm_factor::CategoricalNumericalPredictor, category::Int, numeric::Int)
    return glm_factor.coef_category[category] * numeric
end

function glm_prediction(glm_model::T10_RGA, encoded_modelpoints::StructArray{LapseEncodedModelPoint})
    return exp.(
        glm_model.intercept.intercept .+
        glm_summand.(glm_model.issue_age, encoded_modelpoints.issue_age) +
        glm_summand.(glm_model.issue_age², encoded_modelpoints.issue_age .^ 2) +
        glm_summand.(glm_model.log_issue_age, log.(encoded_modelpoints.issue_age)) +
        glm_summand.(glm_model.risk_class, encoded_modelpoints.encoded_riskclass) +
        glm_summand.(glm_model.face_amount_band, encoded_modelpoints.encoded_faceamount) +
        glm_summand.(glm_model.premium_mode, encoded_modelpoints.encoded_premiummode) +
        glm_summand.(glm_model.premium_jump, encoded_modelpoints.encoded_premiumjump) +
        glm_summand.(glm_model.premium_jump_issueage_interaction, encoded_modelpoints.encoded_premiumjump, encoded_modelpoints.issue_age)
    )
end

function glm_prediction(glm_model::T10_RGA, encoded_modelpoints::DataFrame)
    return glm_prediction(glm_model, StructArray(encoded_modelpoints))
end

mps = StructArray{ModelPoint}((
    mortality_index=[3300],
    issue_age=[45],
    face_amount=[300000],
    months_between_payments=[12],
    premium_jump=[9.0]
))

mps_encoded = encode(mps)

glm_prediction(t10_rga, mps_encoded)

