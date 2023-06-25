#1.Обобщённая функция, реализующая алгоритм быстрого возведения в степень
function pow(a, n :: Int)   # t*a^n = const
    t = one(a)
    while n>0
        if mod(n, 2) == 0
            n/=2
            a *= a 
        else
            n -= 1
            t *= a
        end
    end  
    return t
end

#Структура, представляющая квадратную матрицу размерности 2x2 с элементами типа T
struct Matrix{T}
    a11 :: T
    a12 :: T
    a21 :: T
    a22 :: T
end

#Функция определяет конструктор для создания пустой матрицы
Matrix{T}() where T = Matrix{T}(zero(T), zero(T), zero(T), zero(T))
#Функция возвращает матрицу с единицами на главной диагонали и нулями в остальных элементах
Base. one(::Type{Matrix{T}}) where T = Matrix{T}(one(T), zero(T), zero(T), one(T))
#Функция возвращает новую матрицу того же типа с единицами на главной диагонали и нулями в остальных элементах
Base. one(M :: Matrix{T}) where T = Matrix{T}(one(T), zero(T), zero(T), one(T))
#Функция возвращает пустую матрицу, где все элементы равны нулю
Base. zero(::Type{Matrix{T}}) where T = Matrix{T}()

#Функция выполняет умножение матриц M1 и M2 и возвращает новую матрицу Res
function Base. *(M1 :: Matrix{T}, M2 :: Matrix{T}) where T
    a11 = M1.a11 * M2.a11 + M1.a12 * M2.a21
    a12 = M1.a11 * M2.a12 + M1.a12 * M2.a22
    a21 = M1.a21 * M2.a11 + M1.a22 * M2.a21
    a22 = M1.a21 * M2.a12 + M1.a22 * M2.a22
    Res = Matrix{T}(a11, a12, a21, a22)
    return Res
end

#2.Функция, возвращающая n-ый член последовательности Фибоначчи
function fibonachi(n :: Int)
    Tmp = Matrix{Int}(1, 1, 1, 0) 
    Tmp = pow(Tmp, n)
    return Tmp.a11    
end

#3.Функция, вычисляющая с заданной точностью log_a x
function log(a, x, e) # a > 1        
    z = x
    t = 1
    y = 0
    #ИНВАРИАНТ z^t * a^y = x
    while z < 1/a || z > a || t > e 
        if z < 1/a
            z *= a 
            y -= t 
        elseif z > a
            z /= a
            y += t
        elseif t > e
            t /= 2 
            z *= z 
        end
    end
    return y
end

#4.Функция, реализующая приближенное решение уравнения вида f(x)=0 методом деления отрезка пополам
function bisection(f::Function, a, b, epsilon)
    if f(a)*f(b) < 0 && a < b
        f_a = f(a)
        #ИНВАРИАНТ: f_a*f(b) < 0
        while b-a > epsilon
            t = (a+b)/2
            f_t = f(t)
            if f_t == 0
                return t
            elseif f_a*f_t < 0
                b=t
            else
                a, f_a = t, f_t
            end
        end  
        return (a+b)/2
    else
        @warn("Некоректные данные")
    end
end

#5.Приближенное решение уравнения cos x = x методом деления отрезка пополам
bisection(x->cos(x)-x, 0, 1, 1e-8)

#6.Обобщенная функция, реализующая метод Ньютона приближенного решения уравнения вида f(x)=0
function newton(r::Function, x, epsilon, num_max = 10)
    dx = -r(x)
    k=0
    while abs(dx) > epsilon && k <= num_max
        x += dx
        dx = -r(x)
        k += 1
    end
    k > num_max && @warn("Требуемая точность не достигнута")
    return x
end

#7.Приближеннное решение уравнения cos x = x методом Ньютона
f(x) = cos(x) - x
r(x) = -f(x)/(sin(x)+1)

#8.Приближеннное решение какого-либо вещественного корня многочлена, заданного своими коэффициенами методом Ньютона
p(x) = 4*x^5 - 17*x^4 + 18*x^2 + 93
rp(x) = p(x) / (20*x^4 - 68*x^3 + 36*x)



