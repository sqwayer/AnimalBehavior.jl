# AnimalBehavior
General wrapper for behavioral models used during my PhD


## Create a model
First, you need to create a [DynamicPPL model](https://github.com/TuringLang) using the ```@model``` macro, that returns all the latent variables of your model as a ```NamedTuple``` : 
```julia
@model Qlearning(na, ns) = begin
    α ~ Beta()
    logβ ~ Normal(1,1)

    return (α=α, β=exp(logβ), Values = fill(1/na,na,ns))
end

MyModel = Qlearning(2,1)

```

Note that variables can be sampled from a prior distribution, and/or transorfmed by any arbitrary function 

Then you have to define an evolution and an observation functions with the macros ```@evolution```and ```@observation```respectively with the following syntax : 
```julia
@evolution MyModel begin 
        Values[a,s] += α * (r - Values[a,s]) 
    end

@observation MyModel begin
        Categorical(softmax(β * @views(Values[:,s])))
    end
```

The expression in the ```begin``` ```end``` statement can use the reserved variables names ```s```, ```a``` and ```r``` for the current state, action and feedback respectively, and/or any latent variable defined earlier.
Moreover, the observation function must return a ```Distribution``` from the [Distributions.jl package](https://github.com/JuliaStats/Distributions.jl).

## Simulate behavior
```julia
# Simulation in a probabilistic reversal task
function pr_feedback(history) # Reverse the correct response every 20 trials
    correct = mod(length(history)/20, 2) < 1 ? 1 : 2
    return rand() < 0.9 ? history[end].a == correct : history[end].a ≠ correct 
end

sim = simulate(MyModel; feedback=pr_feedback);
```
```simulate``` returns a Simulation structure with fields ```data``` and ```latent```.

## Inference
```julia
post = infer(MyModel, sim.data; sampler=NUTS(), niter=1000)
```
```infer``` retruns a ```MCMCChain```.
