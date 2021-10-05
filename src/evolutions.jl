## Delta rule
function delta_rule!(Q, s::Int, a::Int, r, α)
    Q[a,s] += α*(r - Q[a,s])
end

function delta_rule!(Q, a::Int, r::T, α) where T <: Real
    Q[a] += α*(r - Q[a])
end

function delta_rule!(Q, s::Int, r::T, α) where T <: AbstractArray
    q = @view(Q[:,s])
    @. q += α * (r - q)
end
