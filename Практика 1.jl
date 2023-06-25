#1.Функция, вычисляющая НОД двух чисел (или многочленов)
function gcd(a::T, b::T) where T<:Integer
    while b > 0
        a, b = b, a % b
    end
    return a
end

#2.Функция, реализующая расширенный алгоритм Евклида, вычисляющая не только НОД, но и коэффициенты его линейного представления
function gcdx(a::T, b::T) where T<:Integer
    u, v = one(T), zero(T); u1, v1 = 0, 1
    #ИНВАРИАНТ:
    while b > 0
        k,r = divrem(a, b)
        a, b = b, r #a - k * b
        u, v, u1, v1 = u1, v1, u - k * u1, v - k * v1
    end
    
    return a, u, v
end

#Элемент кольца вычетов по модулю `N`
struct Z{T,N}
    a::T
    Z{T,N}(a::T) where {T<:Integer, N} = new(mod(a, N))
end

#3.Принимает объект типа `Z{T,N}` в качестве аргумента и возвращает обратный элемент к данному элементу в кольце вычетов по модулю `N`
function invmod(a::Z{T,N}) where {T<:Integer, N}
    if gcd(a.a, N) != 1 
        return nothing
    else
        f, s, d = gcdx(a.a, N)
        return Z{T,N}(s)
    end 
end

#4.Функция, которая возвращает решение диофантового уравнения ax+by=c, если уравнение разрешимо, и значение nothing - в противном случае
function diaphant_solve(a::T,b::T,c::T) where T<:Integer
    if mod(c,gcd(a,b))!=0
        return nothing
    end
    return gcdx(a,b)[2:3]
end

#5.Операции сложения, вычитания и умножения для пользовательского типа `Z{T,N}`, 
#который представляет целое число с фиксированной длиной, заданной типом `T` и количеством `N` цифр
Base. +(a::Z{T,N}, b::Z{T,N}) where {T<:Integer, N} = Z{T,N}(a.a + b.a)
Base. -(a::Z{T,N}, b::Z{T,N}) where {T<:Integer, N} = Z{T,N}(a.a - b.a)
Base. *(a::Z{T,N}, b::Z{T,N}) where {T<:Integer, N} = Z{T,N}(a.a * b.a)

#Операция унарного минуса и функция отображения числа для отладочных целей
Base. -(a::Z{T,N}) where {T<:Integer, N} = Z{T,N}(-a.a)
Base. display(a::Z{T,N}) where {T<:Integer, N} = println(string(a.a))

