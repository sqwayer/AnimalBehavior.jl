function pr_feedback(history)
    return history[end].a == 1
end

sim = simulate(mdl1; feedback=pr_feedback, init_θ = (α = 1.0, β=100.0, Values = reshape([1.0, 0.0], 2, 1)))

@test mean(sim.data.r) == 1.0