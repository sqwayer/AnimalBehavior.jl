@model Qlearning(na, ns) = begin
    α ~ Beta()
    β ~ Gamma(2,1)
    return (α=α, β=β, Values = fill(1/na,na,ns))
end

mdl1 = Qlearning(2,1)

@evolution mdl1 begin 
    delta_rule!(s, a, r, Values, α)
end

@observation mdl1 begin
    Categorical(softmax(β * @views(Values[:,s])))
end

θ = generated_quantities(mdl1, (α=0.2, β = 2.0))
@test θ == (α = 0.2, β = 2.0, Values = fill(0.5, 2, 1))

AnimalBehavior.evol!(mdl1, 1, 1, 1.0; θ... )
@test θ.Values[1] == 0.6

@test AnimalBehavior.observ(mdl1, 1; θ... ) == Categorical(softmax([1.2, 1.0]))


