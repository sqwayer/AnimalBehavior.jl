## Delta rule
function delta_rule!(s::Int, a::Int, r, Q, α)
    Q[a,s] += α*(r - Q[a,s])
end

function delta_rule!(a::Int, r::T, Q, α) where T <: Real
    Q[a] += α*(r - Q[a])
end

function delta_rule!(s::Int, r::T, Q, α) where T <: AbstractArray
    q = @view(Q[:,s])
    @. q += α * (r - q)
end
