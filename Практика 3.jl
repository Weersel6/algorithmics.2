#1.Функция, осуществлющая проверку, является ли заданное целое число простым
function isprime(x::Int)
    a = x
    while(a >= sqrt(x))
        a = a - 1
        if (mod(x,a) == 0)
            return false
        end
    end
    return true
end

#2.Функция, реализующая "решето" Эратосфена, т.е. возвращающая вектор всех простых чисел, не превосходящих заданное число 
function findall(x::SharedArray{Bool})
    a = Vector{Int}()
end

function reshetoeratosphenes(x::Int)
    a = SharedArray{Bool}(x)
    i = 2
    while (i < length(a))
        a[i] = 1
        i = i + 1
    end
    b = 2
    while b < x
        if (a[b] != 0)         
            i = b * b
            while (i < x)
                a[i] = 0
                i = i + b
            end
        end
        b = b + 1
    end
    return findall(a)
end

function eratosphenes_sieve(x::Int)
    a = SharedArray{Bool}(x)
    i = 2
    while (i < length(a))
        if (mod(x,i) == 0)
            a[i] = 1
        end
        i = i + 1
    end
    b = 2
    while b < x
        if (a[b] != 0)         
            i = b * b
            while (i < x)
                a[i] = 0
                i = i + b
            end
        end
        b = b + 1
    end
    return findall(a)
end

#3.Функция, осуществляющая разложение заданного целого числа на степени его простых делителей
function degree(x::Int, y::Int)
    i = 0
    while (x > 1 && mod(x,y) == 0)
        x = x/y
        i = i + 1
    end
    return i
end

function factorize(x::Int)
    a = resheto_spec(x)
    if (length(a) == 0)
        return ([x],[1])
    end
    b = SharedArray{Int}(length(a))
    i = 1
    while i <= length(a)
        b[i] = degree(x, a[i])
        i = i + 1
    end
    return (a,b)
end

function factorization(n)
    factors = []
    d = 2
    while n > 1
        while n % d == 0
            push!(factors, d)
            n /= d
        end
        d += 1
        if d * d > n
            if n > 1
                push!(factors, n)
                break
            end
        end
    end
    return factors
end

#4.Функция, осуществляющая вычисление среднего квадратического отклонения (от среднего значения) заданного числового массива за один
#проход этого массива
function standard_dev(data)
    n = length(data)
    mean_val = sum(data) / n
    deviations = [x - mean_val for x in data]
    std_dev = sqrt(sum(deviations .^ 2) / n)
    return mean_val, std_dev
end

function meanstd(aaa)
    T = eltype(aaa)
    n = 0; s¹ = zero(T); s² = zero(T)
    for a ∈ aaa
    n += 1; s¹ += a; s² += a*a
    end
    mean = s¹ ./ n
    return mean, sqrt(s²/n - mean*mean)
end
