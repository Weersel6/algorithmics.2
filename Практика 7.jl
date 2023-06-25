#1.Генерация всех размещений с повторениями из n элементов {1,2,...,n} по k
function next_repit_placement!(p::Vector{T}, n::T) where T<:Integer
    i = findlast(x->(x < n), p)
    
    isnothing(i) && (return nothing)
    p[i] += 1
    p[i+1:end] .= 1 
    return p
end
 
println("Генерация всех размещений с повторениями из n элементов {1,2,...,n} по k")
println(next_repit_placement!([1, 1, 1], 3))

# ---------------Тест----------------
"""
n = 2; k = 3
p = ones(Int,k)
println(p)
while !isnothing(p)
    p = next_repit_placement!(p,n)
    println(p)
end
"""
# ------------------------------------

#2.Генерация вcех перестановок 1,2,...,n
function next_permute!(p::AbstractVector)
    n = length(p)
    k = 0 
    for i in reverse(1:n - 1) 
        if p[i] < p[i + 1]
            k = i
            break
        end
    end
    k == firstindex(p) - 1 && return nothing 
 
    i = k + 1
    while i < n && p[i + 1] > p[k] 
        i += 1
    end
   
    p[k], p[i] = p[i], p[k]
    
    reverse!(@view p[k + 1:end])
    return p
end
 
println("Генерация всех размещений с повторениями из n элементов {1,2,...,n} по k")
println(next_permute!([1, 3, 4, 2]))
 
# ----------------Тест----------------
"""
p=[1,2,3,4]
println(p)
while !isnothing(p)
    p = next_permute!(p)
    println(p)
end
"""
# ------------------------------------

#3.Генерация всех всех подмножеств n-элементного множества {1,2,...,n}
println("Генерация всех всех подмножеств n-элементного множества {1,2,...,n} 1 способ")
 
#3.1.Первый способ - на основе генерации двоичных кодов чисел 0, 1, ..., 2^n-1
 
indicator(i::Integer, n::Integer) = reverse(digits(Bool, i; base=2, pad=n))
 
println("1 способ")
println(indicator(12, 5))
 
#3.2.Второй способ - на основе непосредственной генерации последовательности индикаторов в лексикографическом порядке
 
function next_indicator!(indicator::AbstractVector{Bool})
    i = findlast(x->(x==0), indicator)
    isnothing(i) && return nothing
    indicator[i] = 1
    indicator[i+1:end] .= 0
    return indicator 
end
 
println("2 способ")
println(next_indicator!(indicator(12, 5)))
 
# ----------------Тест----------------
"""
n=5; A=1:n
indicator = zeros(Bool, n)
println(indicator)
while !isnothing(indicator)
    A[findall(indicator)] |> println
    indicator = next_indicator!(indicator)
    println(indicator)
end
"""
# ------------------------------------
 
#4.Генерация всех k-элементных подмножеств n-элементного множества {1, 2, ..., n}
function next_indicator!(indicator::AbstractVector{Bool}, k)
    i = lastindex(indicator)
    while indicator[i] == 0
        i -= 1
    end
    
    m = 0 
    while i >= firstindex(indicator) && indicator[i] == 1 
        m += 1
        i -= 1
    end
    if i < firstindex(indicator)
        return nothing
    end
    
    indicator[i] = 1
    indicator[i + 1:end] .= 0
    indicator[lastindex(indicator) - m + 2:end] .= 1
    return indicator 
end
 
println("Генерация всех k-элементных подмножеств n-элементного множества {1, 2, ..., n}")
n = 6
k = 3
a = 1:6
println(a[findall(next_indicator!([zeros(Bool, n-k); ones(Bool, k)], k))])
 
# ----------------Тест----------------
"""
n=6; k=3; A=1:n
indicator = [zeros(Bool,n-k); ones(Bool,k)]
A[findall(indicator)] |> println
for !isnothing(indicator)
    indicator = next_indicator!(indicator, k)
    A[findall(indicator)] |> println
end
"""
# ------------------------------------
 
#5.Генерация всех разбиений натурального числа на положительные слагаемые
function next_split!(s ::AbstractVector{Int64}, k)
    k == 1 && return (nothing, 0)
    i = k-1 
    while i > 1 && s[i-1]>=s[i]
        i -= 1
    end
    
    s[i] += 1
    
    r = sum(@view(s[i+1:k]))
    k = i+r-1 
    s[(i+1):(length(s)-k)] .= 1
    return s, k
end
 
println("Генерация всех разбиений натурального числа на положительные слагаемые")
println(next_split!(ones(Int64, 5), 5))
 
# ----------------Тест----------------
"""
n=5; s=ones(Int, n); k=n
println(s)
while !isnothing(s)
    println(s[1:k])
    s, k = next_split!(s, k)
    println(s)
end
"""
# ------------------------------------
 
# № 6 Специальные пользовательские типы и итераторы для генерации рассматриваемых комбинаторных объектов
next_rep_plasement(c::Vector, n) - для генерации размещений с повторениями
next_permute(p::AbstractVector) - для генерации перестановок
next_indicator(indicator::AbstractVector{Bool}) - для генерации всех подмножеств
next_indicator(indicator::AbstractVector{Bool}, k) - для генерации k-элементных подмножеств
next_split(s::AbstractVector{Integer}, k) - для генерации разбиений
 
# Абстрактный пользовательский тип для генерации комбинаторных объектов
abstract type AbstractCombinObject
end

Base.iterate(obj::AbstractCombinObject) = (get(obj), nothing)
Base.iterate(obj::AbstractCombinObject, state) = (isnothing(next!(obj)) ? nothing : (get(obj), nothing))
 
 
#6.1.Размещения с повторениями
struct RepitPlacement{N,K} <: AbstractCombinObject
    value::Vector{Int}
    RepitPlacement{N,K}() where {N, K} = new(ones(Int, K))
end
 
Base.get(p::RepitPlacement) = p.value
next!(p::RepitPlacement{N,K}) where {N, K} = next_repit_placement!(p.value, N)

println("Размещения с повторениями")
for a in RepitPlacement{2,3}() 
    println(a)
end

#6.2.Cтруктура для представления перестановок
struct Permute{N} <: AbstractCombinObject
    value::Vector{Int}
    Permute{N}() where N = new(collect(1:N))
end
 
Base.get(obj::Permute) = obj.value
next!(permute::Permute) = next_permute!(permute.value)

println("Перестановки")
for p in Permute{4}()
    println(p)
end

#6.3.Все подмножества N-элементного множества
struct Subsets{N} <: AbstractCombinObject
    indicator::Vector{Bool}
    Subsets{N}() where N = new(zeros(Bool, N))
end
 
Base.get(sub::Subsets) = sub.indicator
next!(sub::Subsets) = next_indicator!(sub.indicator) 
 

println("Все подмножества N-элементного множества")
for sub in Subsets{4}()
    println(sub)
end

#6.4.k-элементные подмоножества n-элементного множества
struct KSubsets{M,K} <: AbstractCombinObject
    indicator::Vector{Bool}
    KSubsets{M, K}() where{M, K} = new([zeros(Bool, length(M)-K); ones(Bool, K)])
end
 
Base.get(sub::KSubsets) = sub.indicator
next!(sub::KSubsets{M, K}) where{M, K} = next_indicator!(sub.indicator, K) 
 
for sub in KSubsets{1:6, 3}()
    sub |> println
end
 
#6.5.Разбиения
mutable struct NSplit{N} <: AbstractCombinObject
    value::Vector{Int}
    num_terms::Int # число слагаемых (это число мы обозначали - k)
    NSplit{N}() where N = new(vec(ones(Int, N)), N)
end
 
Base.get(nsplit::NSplit) = nsplit.value[begin:nsplit.num_terms]
function next!(nsplit::NSplit)
    a, b = next_split!(nsplit.value, nsplit.num_terms)
    if isnothing(a) return nothing end
    nsplit.value, nsplit.num_terms = a, b
    get(nsplit)
end
 
println("Разбиения")
for s in NSplit{5}()
    println(s)
end
 
