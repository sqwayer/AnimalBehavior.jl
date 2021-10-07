check_singleton_type(x) = x
check_singleton_type(x::T) where T <:ForwardDiff.Dual = x.value
function check_tuple_types(X)
    return NamedTuple{keys(X)}(check_singleton_type.(values(X)))
end