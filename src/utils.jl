## Fast find
function fast_find(V, a)
      i=0
      for v in V
            i+=1
            if v==a
                  return i
            end
      end
      nothing
end

## Fast findall
function custom_findall(f, a, n::Int=1, m::Int=0)
	""" Find values of a satisfying f, then keeping only the n to (end-m)-th ones """
    j = 2-n
    b = Vector{Int}(undef, length(a))
    @inbounds for i in eachindex(a)
        @inbounds if f(a[i])
            if j > 0
				b[j] = i
			end
            j += 1
        end
    end
    resize!(b, j-1-m)
    return b
end