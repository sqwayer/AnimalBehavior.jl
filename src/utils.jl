# Unpacking vectors of arrays into dataframes

function all_indices_comb(A::AbstractMatrix)
    m, n = size(A)
    M = repeat(1:m, inner=n)
    N = repeat(1:n, outer=m)
    v = [(i,j) for (i,j) in zip(M,N)]
    return v
end

function unpack(V::Vector{T}, name) where T <: Number 
    DataFrames.DataFrame(reshape(V, length(V), 1), [name])
end

function unpack(V::Vector{T}, name) where T <: AbstractVector 
    df = DataFrames.DataFrame([V], [name])
    return select(df, name => ByRow(vec) => [Symbol(name,"[$i]") for i in eachindex(V[1])])
end

function unpack(V::Vector{T}, name) where T <: AbstractMatrix
    all_indices = all_indices_comb(V[1])
    df = DataFrames.DataFrame([V], [name])
    return select(df, name => ByRow(vec) => [Symbol(name,"[$i, $j]") for (i,j) in all_indices])
end

function unpack(S::StructVector{T}) where T <: NamedTuple
    tmp = DataFrames.DataFrame(S)
    df = DataFrames.DataFrame()
    for n in keys(S[1])
        df = hcat(df, unpack(tmp[!,n], n))
    end
    return df
end
