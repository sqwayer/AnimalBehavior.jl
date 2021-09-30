""" Example usage : 
@observation MyModel begin
    Categorical(epsilon_argmax(ucb(Q, U, c)))
end
or 
@observation MyModel begin
    Categorical(epsilon_greedy(softmax(ucb(Q, U, c))))
end
"""

function epsilon_greedy(P, ϵ)
    N = length(P)
    P .*= 1 - ϵ 
    P .+= ϵ/(N)
    return P
end

function epsilon_argmax(Q::Vector{T}, ϵ) where T
    P = zero(Q)
    P[argmax(Q)] = one(T)   
    return epsilon_greedy(P, ϵ)
end

function ucb(Q, U, c)
    S = sqrt.(U)
    S .*= c
    S .+= Q
    return S
end