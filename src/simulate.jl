""" Simulation """
struct Simulation{Td, Tl}
    data::Td
    latent::Tl
end

function simulate(mdl; 
    state_transition = x -> 1, 
    feedback = x -> missing, 
    initial_state = 1, 
    ending_condition = x -> length(x) > 100)

    # Initialize
    θ = mdl()
    P_ = observation(mdl, initial_state; θ...)
    a_type = Base.return_types(rand, (typeof(P_),))[1]
    r_type = Base.return_types(feedback, (StructVector,))[1]

    history = StructVector(s=[initial_state], a=Vector{Any}([missing]), r=Vector{Any}([missing]))
    latent = StructVector([deepcopy(θ)])
    
    while !ending_condition(history)
        # current state
        s = history[end].s
        
        # action
        P = observation(mdl, s; θ...)
        a = rand(P)
        history.a[end] = a

        # feedback
        r = feedback(history)
        history.r[end] = r

        # update
        evolution!(mdl, s, a, r; θ...)

        # next state
        ns = state_transition(history)
        push!(history, (s=ns, a=missing, r=missing))
        push!(latent, deepcopy(θ))
    end
    data = StructVector(s = history[1:end-1].s, 
                        a = convert.(a_type,history[1:end-1].a), 
                        r = convert.(r_type, history[1:end-1].r))
    return Simulation(data, latent[1:end-1])
end
