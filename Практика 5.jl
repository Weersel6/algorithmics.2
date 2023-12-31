#Пузырьковая сортировка O(n^2)
function bubble_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    n = length(array)

    for k in 1:n-1
        istranspose = false

        for i in 1:n-k
            if array[i]>array[i+1]
                array[i], array[i+1] = array[i+1], array[i]
                istranspose = true
            end
        end

        if istranspose == false
            break
        end
    end

    return array
end

bubble_sort(array::AbstractVector)::AbstractVector = bubble_sort!(copy(array))

#1.Реализовать функции, аналогичные встроенным функциям sort, sort!, sortperm, sortperm! на основе алгоритма сортировки вставками.
function insert_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    n = 1

    while n < length(array) 
        n += 1
        i = n
        while i > 1 && array[i-1] > array[i]
            array[i], array[i-1] = array[i-1], array[i]
            i -= 1
        end
    end

    return array

end

insert_sort(array::AbstractVector)::AbstractVector = insert_sort!(copy(array))

#2.Реализовать алгоритм сортировки "расчесыванием", который базируется на сортировке "пузырьком". Исследовать эффективность этого алгоритма в равнении с пузырьковой сортировкой (на больших массивах делать времннные замеры).
function comb_sort!(array::AbstractVector{T}, factor::Real=1.2473309) where T <: Number 
    step = length(array)

    while step >= 1
        for i in 1:length(array)-step
            if array[i] > array[i+step]
                array[i], array[i+step] = array[i+step], array[i]
            end
        end

        step = Int(floor(step/factor))

    end

    bubble_sort!(array)

end

comb_sort(array::AbstractVector, factor::Real=1.2473309)::AbstractVector = comb_sort!(copy(array),factor)

#3.Реализовать алгоритм сортировки Шелла, который базируется на сортировке вставками.
function shell_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    n = length(array)
    step_series = (n÷2^i for i in 1:Int(floor(log2(n)))) 

    for step in step_series
        for i in firstindex(array):step-1
            insert_sort!(@view array[i:step:end])
        end
    end

    return array

end

shell_sort(array::AbstractVector)::AbstractVector = shell_sort!(copy(array))

#4.Реализовать алгоритм сортировки слияниями. Исследовать эффективность этого алгоритма в сравнении с предыдущми алгоритмами.
@inline function Base.merge!(a1, a2, a3)::Nothing
    i1, i2, i3 = 1, 1, 1

    @inbounds while i1 <= length(a1) && i2 <= length(a2) 
        if a1[i1] < a2[i2]
            a3[i3] = a1[i1]
            i1 += 1
        else
            a3[i3] = a2[i2]
            i2 += 1
        end
        i3 += 1
    end

    @inbounds if i1 > length(a1)
        a3[i3:end] .= @view(a2[i2:end]) 
    else
        a3[i3:end] .= @view(a1[i1:end])
    end

    nothing

end

function merge_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
	b = similar(array) 
	N = length(array)
	n = 1 

	@inbounds while n < N
		K = div(N,2n) 
		for k in 0:K-1
			merge!(@view(array[(1:n).+k*2n]), @view(array[(n+1:2n).+k*2n]), @view(b[(1:2n).+k*2n]))
		end

		if N - K*2n > n 
			merge!(@view(array[(1:n).+K*2n]), @view(array[K*2n+n+1:end]), @view(b[K*2n+1:end]))
		elseif 0 < N - K*2n <= n 
			b[K*2n+1:end] .= @view(array[K*2n+1:end])
		end

		array, b = b, array
		n *= 2

	end
	if isodd(log2(n)) 
		b .= array 
		array = b
	end

	return array 

end

merge_sort(array::AbstractVector)::AbstractVector = merge_sort!(copy(array))

#5.Реализовать алгоритм сортировки Хоара. 
function part_sort!(array::AbstractVector{T}, base::T) where T <: Number
	N = length(array)
	K=0
	L=0
	M=N

	while L < M 
		if array[L+1] == base
			L += 1
		elseif array[L+1] > base
			array[L+1], array[M] = array[M], array[L+1]
			M -= 1
		else 
			L += 1; K += 1
			array[L], array[K] = array[K], array[L]
		end
	end

	return K, M+1 

end

function quick_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
	if isempty(array) return array end
	N = length(array)
	K, M = part_sort!(array, array[rand(1:N)]) 
	quick_sort!(@view array[1:K])
	quick_sort!(@view array[M:N])
	return array
end
quick_sort(array::AbstractVector)::AbstractVector = quick_sort!(copy(array))

#6.Реализовать вычисление медианы массива на основе процедуры Хоара.
function median(array::AbstractVector{T})::T where T <: Number
	quick_sort!(array)
    if len(array) % 2 == 1
        return array[len(array) / 2]
    else
        return 0.5 * (array[len(array) / 2 - 1] + l[len(array) / 2])
	end
end

#7.Реализовать алгоритм сортировки за линейное время.
function calc_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    min_val, max_val = extrema(array)
    num_val = zeros(T, max_val - min_val + 1) 
    for val in array
        num_val[val-min_val+1] += 1
    end  
    k = 0
    for (i, num) in enumerate(num_val)
        array[k+1:k+num] .= min_val+i-1
        k += num
    end
    return array
end
calc_sort(array::AbstractVector)::AbstractVector = calc_sort!(copy(array))

#Порядковые статистики, алгоритм быстрого вычисления порядковых статистик
function order_statistics!(array::AbstractVector{T}, index::Integer)::T where T
	function part_sort!(indexes_range::AbstractUnitRange, b)
		K, L, M = indexes_range[1]-1, indexes_range[begin]-1, indexes_range[end] 
		#ИНВАРИАНТ: array[indexes_range[begin]:K] < b && array[K+1:L] == b && array[M+1:indexes_range[end]] > b
		while L < M 
			if array[L+1] == b
				L += 1
			elseif array[L+1] > b
				array[L+1], array[M] = array[M], array[L+1]
				M -= 1
			else 
				L += 1; K += 1
				array[L], array[K] = array[K], array[L]
			end
		end    
		return indexes_range[begin]:K, M+1:indexes_range[end] 
	end

	function find(indexes_range)
		left_range, right_range = part_sort!(indexes_range, array[rand(indexes_range)]) 
		if index in left_range
			return find(left_range) 
		elseif index in right_range
			return find(right_range)
		else
			return array[index]
		end
	end
	find(firstindex(array):lastindex(array))
end

order_statistics(array::AbstractVector, index::Integer) = order_statistics!(copy(array), index)

#Реализация кучи на базе массива O(n)
function heap!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    N = length(array)

    for i in 1:N÷2
        if array[i] < array[2i]
            array[i], array[2i] = array[2i], array[i]
        end
        
        if 2i+1 <= N && array[i] < array[2i+1]
            array[i], array[2i+1] = array[2i+1], array[i]
        end
    end

    return array
end
heap(array::AbstractVector)::AbstractVector = heap!(copy(array))


using Random
A = randperm(100000)[1:100000]
@showtime bubble_sort(A)
@showtime insert_sort(A)
@showtime comb_sort(A)
@showtime shell_sort(A)
@showtime merge_sort(A)
@showtime quick_sort(A)

#= Топ сортировок 
bubble_sort(A): 9.740503 seconds (21.70 k allocations: 1.927 MiB, 0.14% compilation time)
insert_sort(A): 1.242766 seconds (7.11 k allocations: 1.119 MiB, 0.82% gc time, 1.25% compilation time)
comb_sort(A): 0.023961 seconds (20.77 k allocations: 1.875 MiB, 68.58% compilation time)
shell_sort(A): 0.108704 seconds (124.69 k allocations: 7.244 MiB, 43.83% compilation time)
merge_sort(A): 0.262546 seconds (831.54 k allocations: 38.854 MiB, 97.07% compilation time)
quick_sort(A): 0.083688 seconds (375.24 k allocations: 18.645 MiB, 14.96% gc time, 89.28% compilation time)
=#

@showtime sort(A,alg=InsertionSort)
@showtime sort(A,alg=QuickSort)
@showtime sort(A,alg=MergeSort)

#= Библиотечные сортировки
sort(A, alg = InsertionSort): 1.206621 seconds (63.45 k allocations: 4.079 MiB, 2.13% compilation time)
sort(A, alg = QuickSort): 0.017171 seconds (15.88 k allocations: 1.670 MiB, 73.98% compilation time)
sort(A, alg = MergeSort): 0.051416 seconds (155.36 k allocations: 8.990 MiB, 89.43% compilation time)
=#