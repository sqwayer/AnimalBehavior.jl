
data_size(data::Array{Ts}) where Ts <: StructVector = sum(length.(data))
data_size(data::Ts) where Ts <: StructVector = length(data)

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

# Convert Dataframes into a StructVector with named fields s, a, and r
repack(df::DataFrames.DataFrame, val) = fill(val, nrow(df))
repack(df::DataFrames.DataFrame, name::Symbol) = Vector(df[!,name])
repack(df::DataFrames.DataFrame, names::Vector{Symbol}) = [(;df[!,names][i,:]...) for i in 1:nrow(df)]
function build_history(df::DataFrames.DataFrame; states=missing, actions, feedbacks=missing, hidden=missing)
    return StructVector(s = repack(df, states), 
                        a = repack(df, actions), 
                        r = repack(df, feedbacks), 
                        h = repack(df, hidden))
end