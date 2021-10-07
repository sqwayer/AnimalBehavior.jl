# Fast mode
fast_mode(X::Vector{T}) where T <: Integer = fast_mode(X, minimum(X):maximum(X))
function fast_mode(X, range)
    m, cm = (0, 0)
    for i in range
       c = count(isequal(i), X)
       if c > cm 
        cm = c
        m = i
        end
    end
    return m 
end

# Summary stats
function average(V::Vector{A}) where A <: AbstractArray
    N = length(V)
    M = V[1]
    for i in 2:N
       M .+= V[i]
    end 
    M ./= N
    return M
end
average(V::Vector{T}) where T <: AbstractFloat = mean(V)
average(V::Vector{T}) where T <: Integer = fast_mode(V)

function average(SV::StructVector{TV}) where TV
    return TV(average.(values(StructArrays.components(SV))))
end

# Posterior expectation
function expectation(P::Posterior)
    return (hyperparameters = average(P.hyperparameters),
            latent = average(P.latent))
end