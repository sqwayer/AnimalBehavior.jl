function _evolution(mdl, body)
    nt = Base.return_types(mdl, ())[1]
    mdl_kwargs = fieldnames(nt)
    mdl_type = typeof(mdl)
    callex = Expr(:call, :evolution!, Expr(:parameters, mdl_kwargs...), :(M::T), :s)
    whereex = Expr(:where, callex, :(T<:$mdl_type))
    ex = Expr(:(=), whereex, body)
    return ex
end

macro evolution(mdl, expr)
    body = QuoteNode(expr)
    return quote 
        eval(AnimalBehavior._evolution($mdl, $body))
    end
end

function _observation(mdl, body)
    nt = Base.return_types(mdl, ())[1]
    mdl_kwargs = fieldnames(nt)
    mdl_type = typeof(mdl)
    callex = Expr(:call, :observation, Expr(:parameters, mdl_kwargs...), :(M::T), :s, :a, :r)
    whereex = Expr(:where, callex, :(T<:$mdl_type))
    ex = Expr(:(=), whereex, body)
    return ex
end

macro observation(mdl, expr)
    body = QuoteNode(expr)
    return quote 
        eval(AnimalBehavior._observation($mdl, $body))
    end
end