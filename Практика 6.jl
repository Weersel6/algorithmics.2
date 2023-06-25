using Plots
using LinearAlgebra

#1.Спроектировать типы Vector2D и Segment2D с соответсвующими функциями.
Vector2D{T <: Real} = NamedTuple{(:x, :y), Tuple{T,T}}

Base. +(a::Vector2D{T},b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .+ Tuple(b))
Base. -(a::Vector2D{T}, b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .- Tuple(b))
Base. *(α::T, a::Vector2D{T}) where T = Vector2D{T}(α.*Tuple(a))

LinearAlgebra.norm(a::Vector2D) = norm(Tuple(a))

LinearAlgebra.dot(a::Vector2D{T}, b::Vector2D{T}) where T = dot(Tuple(a), Tuple(b))

Base. cos(a::Vector2D{T}, b::Vector2D{T}) where T = dot(a,b)/norm(a)/norm(b)

xdot(a::Vector2D{T}, b::Vector2D{T}) where T = a.x*b.y-a.y*b.x

Base.sin(a::Vector2D{T}, b::Vector2D{T}) where T = xdot(a,b)/norm(a)/norm(b)
Base.angle(a::Vector2D{T}, b::Vector2D{T}) where T = atan(sin(a,b),cos(a,b))
Base.sign(a::Vector2D{T}, b::Vector2D{T}) where T = sign(sin(a,b))

Segment2D{T <: Real} = NamedTuple{(:A, :B), NTuple{2,Vector2D{T}}}

stored_lims = [0,0,0,0]

function lims!(x1,y1,x2,y2)
	stored_lims[1] = min(x1-1,stored_lims[1])
	stored_lims[2] = min(y1-1,stored_lims[2])
	stored_lims[3] = max(x2+1,stored_lims[3])
	stored_lims[4] = max(y2+1,stored_lims[4])

	xlims!(stored_lims[1], stored_lims[3])
	ylims!(stored_lims[2], stored_lims[4])
end

lims!(x,y) = lims!(x,y,x,y)

function draw(vertices::AbstractArray{Vector2D{T}}) where T
	vertices = copy(vertices)
	push!(vertices,first(vertices))

	x = [v.x for v in vertices]
	y = [v.y for v in vertices]

	plot(x, y, color=:blue, legend=false)

	lims!( minimum(x) , minimum(y) , maximum(x) , maximum(y) )
end

function draw(point::Segment2D{T}) where T
	plot([point.A.x,point.B.x], [point.A.y,point.B.y], color=:yellow, legend=false)

	lims!( min(point.A.x,point.B.x) , min(point.A.y,point.B.y) , max(point.A.x,point.B.x) , max(point.A.y,point.B.y) )
end

function draw(point::Vector2D{T}) where T
	scatter!([point.x,point.x], [point.y,point.y], color=:red, markersize=5, legend=false)

	lims!( point.x , point.y )
end

function clear()
	fill!(stored_lims,0)

	xlims!(0,1)
	ylims!(0,1)

	plot!()
end

#2.Написать функцию, проверяющую, лежат ли две заданные точки по одну сторону от заданной прямой (прямая задается некоторым содержащимся в ней отрезком).
function oneside(P::Vector2D{T}, Q::Vector2D{T}, s::Segment2D{T})::Bool where T
	l = s.B - s.A
	return sin(l, P-s.A) * sin(l,Q-s.A) > 0
end

#3.Написать функцию, проверяющую, лежат ли две заданные точки по одну сторону от заданной кривой (кривая задается уравнением вида F(x,y) = 0).
oneside(F::Function, P::Vector2D, Q::Vector2D)::Bool =
	( F(P...) * F(Q...) > 0 )

#4.Написать функцию, возвращающую точку пересечения (если она существует) двух заданных отрезков.
isinner(P::Vector2D, s::Segment2D)::Bool =
	(s.A.x <= P.x <= s.B.x || s.A.x >= P.x >= s.B.x) &&
	(s.A.y <= P.y <= s.B.y || s.A.y >= P.y >= s.B.y)

function intersection(s1::Segment2D{T},s2::Segment2D{T})::Union{Vector2D{T},Nothing} where T
	A = [s1.B[2]-s1.A[2] s1.A[1]-s1.B[1]
		s2.B[2]-s2.A[2] s2.A[1]-s2.B[1]]

	b = [s1.A[2]*(s1.A[1]-s1.B[1]) + s1.A[1]*(s1.B[2]-s1.A[2])
		s2.A[2]*(s2.A[1]-s2.B[1]) + s2.A[1]*(s2.B[2]-s2.A[2])]

	x,y = A\b

	if isinner((;x, y), s1)==false || isinner((;x, y), s2)==false
		return nothing
	end

	return (;x, y) 
end
println("Пересечение: ",intersection( (A=(x=-1.0,y=-1.0),B=(x=1.0,y=2.0)) , (A=(x=1.0,y=-1.0),B=(x=-1.0,y=3.0)) ))

#5.Написать функцию, проверяющую лежит ли заданная точка внутри заданного многоугольника.
function isinside(point::Vector2D{T},polygon::AbstractArray{Vector2D{T}})::Bool where T
	@assert length(polygon) > 2
	sum = zero(Float64)
	for i in firstindex(polygon):lastindex(polygon)
		sum += angle( polygon[i] - point , polygon[i % lastindex(polygon) + 1] - point )
	end
	return abs(sum) > π
end

println("Внутри: ",isinside( (x=0,y=0),[(x=0,y=1),(x=1,y=-1),(x=-1,y=-1)] ))
println("Внутри: ",isinside( (x=5,y=0),[(x=0,y=1),(x=1,y=-1),(x=-1,y=-1)] ))

#6.Написать функцию, проверяющую, является ли заданный многоугольник выпуклым.
function isconvex(polygon::AbstractArray{Vector2D{T}})::Bool where T
	@assert length(polygon) > 2
	for i in firstindex(polygon):lastindex(polygon)
		if angle( polygon[i > firstindex(polygon) ? i - 1 : lastindex(polygon)] - polygon[i] , polygon[i % lastindex(polygon) + 1] - polygon[i] ) >= π
			return false
		end
	end
	return true
end

println("Выпуклый: ",isconvex( [
		(x=0,y=1),
		(x=1,y=-1),
		(x=-1,y=-1)
	] ))


# 9.Написать функцию вычисляющую площадь (ориентированную) заданного многоугольника методом трапеций.
function area_trapeze(poly::AbstractArray{Vector2D{T}})::T where T
    res = zero(T)

    for i in firstindex(poly):lastindex(poly)-1
        res += (poly[i].y + poly[i+1].y) * (poly[i+1].x - poly[i].x) / 2
    end

    return res
end

println("Площадь (Трапеция): ",area_trapeze( [
	(x=2.0,y=-1.0),
	(x=1.0,y=2.0),
	(x=-1.0,y=3.0),
	(x=-3.0,y=-1.0),
] ))

# 10.Написать функцию вычисляющую площадь (ориентированную) заданного многоугольника методом треугольников.
function area_triangle(poly::AbstractArray{Vector2D{T}})::T where T
    res = zero(T)

    for i in firstindex(poly)+1:lastindex(poly)-1
        res += xdot(poly[i] - (poly[1]), poly[i+1] - poly[1])
    end

    return res
end

println("Площадь (Треугольники): ",area_triangle( [
	(x=3.0,y=1.0),
	(x=1.0,y=2.0),
	(x=0.0,y=1.0),
	(x=1.0,y=0.5),
] ))

draw([(x=0,y=2),
(x=1,y=-1),
(x=-1,y=-1)])
draw((x=0,y=1))
draw((x=2,y=2))
draw((x=-2,y=2))
savefig("tri.png") 
clear()

draw([(x=-5,y=-5),
(x=-5,y=5),
(x=5,y=5),
(x=5,y=-5)])
draw((x=-1,y=0))
draw((x=1,y=0))
savefig("rect.png") 
clear()

