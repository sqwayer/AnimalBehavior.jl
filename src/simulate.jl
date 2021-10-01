""" simulate(mdl; 
        state_transition = x -> 1, 
        feedback = x -> missing, 
        initial_state = 1, 
        ending_condition = x -> length(x) > 100,
        init_θ = mdl())
    
    Simulation function
    
    # Arguments

    # Examples
"""

struct Simulation{Td, Tl}
    name::Symbol
    data::Td
    latent::Tl
end

# Simulate
function simulate(mdl, data::StructVector; feedback = x -> missing, init_θ=mdl())
    initial_state = data.s[1]
    initial_hidden = data.h[1]
    state_transition(history) = data.s[min(length(history)+1, length(data))]
    hidden_transition(history) = data.h[min(length(history)+1, length(data))]
    ending_condition(history) = length(history) > length(data)
    
    return simulate(mdl; 
            state_transition = state_transition,
            hidden_transition = hidden_transition,
            feedback = feedback,
            initial_state = initial_state,
            initial_hidden = initial_hidden,
            ending_condition = ending_condition,
            init_θ = init_θ)
end

function simulate(mdl; 
    state_transition = x -> 1, 
    feedback = x -> missing,
    hidden_transition = x -> missing,
    initial_state = 1,
    initial_hidden = missing, 
    ending_condition = x -> length(x) > 100,
    init_θ = mdl())

    # Initialize
    θ = init_θ
    P_ = AnimalBehavior.observ(mdl, initial_state; θ...)
    a_type = Distributions.eltype(typeof(P_))
    r_type = Base.return_types(feedback, (StructVector,))[1]

    history = StructVector(s=[initial_state], a=Vector{Any}([missing]), r=Vector{Any}([missing]), h=Vector{Any}([initial_hidden]))
    latent = StructVector([deepcopy(θ)])
    
    while !ending_condition(history)
        # current state
        s = history[end].s
        
        # action
        P = AnimalBehavior.observ(mdl, s; θ...)
        a = rand(P)
        history.a[end] = a

        # feedback
        r = feedback(history)
        history.r[end] = r

        # update
        AnimalBehavior.evol!(mdl, s, a, r; θ...)

        # next state
        ns = state_transition(history)
        nh = hidden_transition(history)
        push!(history, (s=ns, a=missing, r=missing, h=nh))
        push!(latent, deepcopy(θ))
    end
    data = StructVector(s = history[1:end-1].s, 
                        a = convert.(a_type,history[1:end-1].a), 
                        r = convert.(r_type, history[1:end-1].r),
                        h = history[1:end-1].h)
    return Simulation(mdl.name, data, latent[1:end-1])
end

# Base functions
function Base.convert(::Type{DataFrames.DataFrame}, S::AnimalBehavior.Simulation)
    df = hcat(unpack(S.data), unpack(S.latent))
    return df
end

function Base.show(io::IO, mime::MIME"text/plain", S::AnimalBehavior.Simulation)
    table_conf = set_pt_conf(tf = tf_markdown, alignment = :c)
    println(io, "Simulation of one $(S.name) agent")
    println(io)
    pretty_table_with_conf(table_conf, 
        collect(values(S.latent[1]))'; 
        header=collect(keys(S.latent[1])),
        title="Initial latent variables")
    
    println(io)
    vals = hcat(collect(StructArrays.components(S.data))..., collect(StructArrays.components(S.latent))...)
    header = vcat(["State", "Action", "Feedback"], keys(S.latent[1])...)
    pretty_table_with_conf(table_conf, 
        vals; 
        header=header,
        title="Simulation of $(length(S.data)) trials")
end