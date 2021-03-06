function _evolution(mdl, body)
    nt = Base.return_types(mdl, ())[1]
    mdl_kwargs = fieldnames(nt)
    mdl_type = typeof(mdl)
    callex = Expr(:call, :(AnimalBehavior.evol!), Expr(:parameters, mdl_kwargs...), :(M::T), :s, :a, :r)
    whereex = Expr(:where, callex, :(T<:$mdl_type))
    ex = Expr(:(=), whereex, body)
    return ex
end

macro evolution(mdl, expr)
    body = QuoteNode(expr)
    return esc(quote 
        eval(AnimalBehavior._evolution($mdl, $body))
    end)
end

function evol! end

function _observation(mdl, body)
    nt = Base.return_types(mdl, ())[1]
    mdl_kwargs = fieldnames(nt)
    mdl_type = typeof(mdl)
    callex = Expr(:call, :(AnimalBehavior.observ), Expr(:parameters, mdl_kwargs...), :(M::T), :s)
    whereex = Expr(:where, callex, :(T<:$mdl_type))
    ex = Expr(:(=), whereex, body)
    return ex
end

macro observation(mdl, expr)
    body = QuoteNode(expr)
    return esc(quote 
        eval(AnimalBehavior._observation($mdl, $body))
    end)
end

function observ end