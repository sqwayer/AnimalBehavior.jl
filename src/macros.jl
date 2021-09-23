""" Evolution macro creates a function _modelname_evolution(s, a, r; θ...)"""

function get_mdl_kwargs(mdl)
    nt = Base.return_types(mdl, ())[1]
    return fieldnames(nt), typeof(mdl)
end

macro evolution(mdl, expr)
    mdl_kwargs, mdl_type = get_mdl_kwargs(eval(:(mdl)))
    
    fun_def = Dict(
        :name => :evolution!,
        :body => expr,
        :args => [:(M::T), :s, :a, :r],
        :kwargs => mdl_kwargs,
        :whereparams => [:(T<:$mdl_type)]
    )
    return MacroTools.combinedef(fun_def)
end

macro observation(mdl, expr)
    mdl_kwargs, mdl_type = get_mdl_kwargs(eval(:($mdl)))
    fun_def = Dict(
        :name => :observation,
        :body => expr,
        :args => [:(M::T), :s],
        :kwargs => mdl_kwargs,
        :whereparams => [:(T<:$mdl_type)]
    )
    return MacroTools.combinedef(fun_def)
end