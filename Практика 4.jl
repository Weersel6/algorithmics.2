#1.Функция, вычисляющая n-ю частичную сумму ряда Тейлора (Маклорена) функции для произвольно заданного значения аргумента x
function exp_partial_sum(x::Real, n::Int)
    sum = 0.0
    term = 1.0
    for i in 0:n
        sum += term
        term *= x / (i + 1)
    end
    return sum
end
println(exp_partial_sum(5.0, 6))

#2.Функция, вычиляющая значение с машинной точностью (с максимально возможной в арифметике с плавающей точкой)
function exp_with_max_precision(x) 
    y = 1.0
    term = 1.0
    k = 1
    while y + term != y 
        term *= x / k
        y += term
        k += 1
    end
    return y
end
println(exp_with_max_precision(5.0))

#3.Функция, вычисляющая функцию Бесселя (обобщение функции синуса, колебание струны с переменным толщеной, натяжением) 
#заданного целого неотрицательного порядка по ее ряду Тейлора с машинной точностью.
using Plots
function bessel(M::Integer, x::Real)
    sqrx = x*x
    a = 1/factorial(M)
    m = 1
    s = 0 
    while s + a != s
        s += a
        a = -a * sqrx /(m*(M+m)*4)
        m += 1
    end
    return s*(x/2)^M
end

values = 0:0.1:20
myPlot = plot()
for m in 0:5
	plot!(myPlot, values, bessel.(m, values))
end
display(myPlot)

#4.Реализовать алгорим, реализующий обратный ход алгоритма Жордана-Гаусса
using LinearAlgebra
function jordan_gauss(A::AbstractMatrix{T}, b::AbstractVector{T})::AbstractVector{T} where T
    @assert size(A, 1) == size(A, 2)
    n = size(A, 1) 
    x = zeros(T, n)
    for i in n:-1:1
        x[i] = b[i]
        for j in i+1:n
            x[i] =fma(-x[j] ,A[i,j] , x[i])
        end
        x[i] /= A[i,i]
    end
    return x
end

#5.Реализовать алгоритм, осуществляющий приведение матрицы к ступенчатому виду
function TransformToSteps!(matrix::AbstractMatrix, epsilon::Real = 1e-7)::AbstractMatrix
	@inbounds for k ∈ 1:size(matrix, 1)
		absval, Δk = findmax(abs, @view(matrix[k:end,k]))
		(absval <= epsilon) && throw("Вырожденая матрица")
		Δk > 1 && swap!(@view(matrix[k,k:end]), @view(matrix[k+Δk-1,k:end]))
		for i ∈ k+1:size(matrix,1)
			t = matrix[i,k]/matrix[k,k]
			@. @views matrix[i,k:end] = matrix[i,k:end] - t * matrix[k,k:end] 
		end
	end
	return matrix
end

#6.Реализовать алгоритм, реализующий метод Жордана-Гаусса решение СЛАУ для произвольной невырожденной матрицы (достаточно хорошо обусловленной).
@inline function sumprod(vec1::AbstractVector{T}, vec2::AbstractVector{T})::T where T
	s = zero(T)
	@inbounds for i in eachindex(vec1)
	s = fma(vec1[i], vec2[i], s) 
	end
	return s
end

function ReverseGauss!(matrix::AbstractMatrix{T}, vec::AbstractVector{T})::AbstractVector{T} where T
	#1. сначала расширенная матрица системы с помощью элементарных преобразований её строк приводится к ступенчатому виду
	x = similar(vec)
	N = size(matrix, 1)
	for k in 0:N-1
		#2. по очевидной простой формуле вычисляются значения элементов вектора решения, начиная с последнего элемента.
		x[N-k] = (vec[N-k] - sumprod(@view(matrix[N-k,N-k+1:end]), @view(x[N-k+1:end]))) / matrix[N-k,N-k]
	end
	return x
end

#8.Написать функцию, возвращающую ранг произвольной прямоугольной матрицы (реализуется на базе приведения матрицы к ступенчатому виду).
function rank!(matrix::AbstractMatrix{T},epsilon::Real = 1e-7) where T
    TransformToSteps!(Matrix)
	i = 1
    while abs(matrix[i,i]) <= epsilon
        i+=1
    end
    return i-1
end

#9.Написать функцию, возвращающую определитель произвольной квадратной матрицы (реализуется на основе приведения матрицы к ступенчатому виду).
function determinant!(matrix::AbstractMatrix{T}) where T
    TransformToSteps!(matrix)
    det = oneunit(T)
    i = 1
    while i <= size(matrix, 1)
		if matrix[i, i] == zero(T)
			break
		end
		det *= matrix[i, i]
		i += 1
    end
    return det
end
