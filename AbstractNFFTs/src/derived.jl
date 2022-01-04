
##########################
# plan_nfft constructors
##########################

# The following automatically call the plan_nfft version for type Array

plan_nfft(x::AbstractArray, N::Union{Integer,NTuple{D,Int}}, args...; kargs...) where {D} =
    plan_nfft(Array, x, N, args...; kargs...)

plan_nfft(x::AbstractArray, dim::Integer, N::Union{NTuple{D,Int}}, args...; kargs...) where {D} =
    plan_nfft(Array, x, dim, N, args...; kargs...)

# The follow convert 1D parameters into the format required by the NFFT plan

plan_nfft(Q::Type, x::AbstractRange, N::NTuple{D,Int}, rest...; kwargs...) where {D} =
    plan_nfft(Q, collect(x), N, rest...; kwargs...)

plan_nfft(Q::Type, x::AbstractVector, N::Integer, rest...; kwargs...) =
    plan_nfft(Q, collect(reshape(x,1,length(x))), (N,), rest...; kwargs...)

plan_nfft(Q::Type, x::AbstractVector, dim::Integer, N::NTuple{D,Int}, rest...; kwargs...) where {D} =
    plan_nfft(Q, collect(reshape(x,1,length(x))), dim, N, rest...; kwargs...) 


"""
nfft(x, f::AbstractArray{T,D}, rest...; kwargs...)

calculates the NFFT of the array `f` for the nodes contained in the matrix `x`
The output is a vector of length M=`size(nodes,2)`
"""
function nfft(x, f::AbstractArray{T,D}, rest...;  kwargs...) where {T,D}
  p = plan_nfft(x, size(f), rest...; kwargs... )
  return nfft(p, f)
end

"""
nfft_adjoint(x, N, fHat::AbstractArray{T,D}, rest...; kwargs...)

calculates the adjoint NFFT of the vector `fHat` for the nodes contained in the matrix `x`.
The output is an array of size `N`
"""
function nfft_adjoint(x, N, fHat::AbstractVector{T}, rest...;  kwargs...) where T
  p = plan_nfft(x, N, rest...;  kwargs...)
  return nfft_adjoint(p, fHat)
end


"""
        nfft(p, f) -> fHat

For a **non**-directional `D` dimensional plan `p` this calculates the NFFT of a `D` dimensional array `f` of size `N`.
`fHat` is a vector of length `M`.
(`M` and `N` are defined in the plan creation)

For a **directional** `D` dimensional plan `p` both `f` and `fHat` are `D`
dimensional arrays, and the dimension specified in the plan creation is
affected.
"""
function nfft(p::AbstractNFFTPlan{D,0,T}, f::AbstractArray{U,D}, args...; kargs...) where {D,T,U}
    fHat = similar(f,Complex{T}, p.M)
    nfft!(p, f, fHat, args...; kargs...)
    return fHat
end

function nfft(p::AbstractNFFTPlan{D,DIM,T}, f::AbstractArray{U,D}, args...; kargs...) where {D,DIM,T,U}
    sz = [p.N...]
    sz[DIM] = p.M
    fHat = similar(f, Complex{T}, Tuple(sz))
    nfft!(p, f, fHat, args...; kargs...)
    return fHat
end

"""
        nfft_adjoint(p, fHat) -> f

For a **non**-directional `D` dimensional plan `p` this calculates the adjoint NFFT of a length `M` vector `fHat`
`f` is a `D` dimensional array of size `N`.
(`M` and `N` are defined in the plan creation)

For a **directional** `D` dimensional plan `p` both `f` and `fHat` are `D`
dimensional arrays, and the dimension specified in the plan creation is
affected.
"""
function nfft_adjoint(p::AbstractNFFTPlan{D,DIM,T}, fHat::AbstractArray{U}, args...; kargs...) where {D,DIM,T,U}
    f = similar(fHat, Complex{T}, p.N)
    nfft_adjoint!(p, fHat, f, args...; kargs...)
    return f
end
