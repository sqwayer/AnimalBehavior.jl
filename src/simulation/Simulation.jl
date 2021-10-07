struct Simulation{Td, Tl}
    name::Symbol
    data::Td
    latent::Tl
end

# Base functions
function Base.convert(::Type{DataFrames.DataFrame}, S::AnimalBehavior.Simulation)
    df = hcat(unpack(S.data), unpack(S.latent))
    return df
end

function Base.show(io::IO, mime::MIME"text/plain", S::AnimalBehavior.Simulation)
    table_conf = set_pt_conf(tf = tf_markdown, alignment = :c)
    println(io, "Simulation of one $(S.name) agent")
    println(io)
    pretty_table_with_conf(table_conf, 
        collect(values(S.latent[1]))'; 
        header=collect(keys(S.latent[1])),
        title="Initial latent variables")
    
    println(io)
    vals = hcat(collect(StructArrays.components(S.data))..., collect(StructArrays.components(S.latent))...)
    header = vcat(["State", "Action", "Feedback", "Hidden"], keys(S.latent[1])...)
    pretty_table_with_conf(table_conf, 
        vals; 
        header=header,
        title="Simulation of $(length(S.data)) trials")
end