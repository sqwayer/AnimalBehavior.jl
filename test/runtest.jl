using AnimalBehavior
using Turing

@model Qlearning(na, ns) = begin
    α ~ Beta()
    β ~ Gamma(2,1)
    return (α=α, β=β, Values = fill(1/na,na,ns))
end

MyModel = Qlearning(2,1)

@evolution MyModel begin 
    delta_rule!(s, a, r, Values, α)
end

@observation MyModel begin
    Categorical(softmax(β * @views(Values[:,s])))
end

# Simulation of a probabilistic reversal task
function pr_feedback(history) # Reverse the correct response every 20 trials
    correct = mod(length(history)/20, 2) < 1 ? 1 : 2
    return rand() < 0.9 ? history[end].a == correct : history[end].a ≠ correct 
end

sim = simulate(MyModel; feedback=pr_feedback, init_θ = (α = 0.4, β=2.4, Values = fill(1/2,2,1)))

# Inference
chn = sample(MyModel, sim.data, NUTS(), MCMCThreads(), 1000, 4)
post = posterior(MyModel, chn, sim.data)
