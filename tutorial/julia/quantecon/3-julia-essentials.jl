using LinearAlgebra, Statistics, Plots

x = true

typeof(x)

y = 1 > 2  # now y = false


typeof(1.0)
typeof(1)

@show 2x - 3y
@show x + y;

# concatenate strings
@show "foo" * "bar"

s = "Charlie don't surf"
split(s)

replace(s, "surf" => "ski")

split("fee,fi,fo", ",")

strip(" foobar ")  # remove whitespace

match(r"(\d+)", "Top 10")  # find digits in string


x = ("foo", "bar")
y = ("foo", 2)

typeof(x), typeof(y)

x = [10, 20, 30, 40]

d = Dict("name" => "Frodo", "age" => 33)

d["name"]

keys(d)

collect(keys(d))


xs = 1:10000
f(x) = x^2
f_x = f.(xs)
sum(f_x)

f_x2 = [f(x) for x in xs]
@show sum(f_x2)
@show sum([f(x) for x in xs]); # still allocates temporary

using BenchmarkTools
@btime sum([f(x) for x in $xs])
@btime sum(f.($xs))
@btime sum(f(x) for x in $xs);

function chisq(k)
    @assert k > 0
    z = randn(k)
    return sum(z -> z^2, z)  # same as `sum(x^2 for x in z)`
end

n = 1:1:100
map( (x,y) -> x.*y , (1/n), (chisq.(n)) ) # converges to σ of standard normal

@. (1/n) * (chisq(n))

x = 1.0:1.0:5.0
y = [2.0, 4.0, 5.0, 6.0, 8.0]
z = similar(y)
z .= x .+ y .- sin.(x) # generates efficient code instead of many temporaries

f(x, y) = [1, 2, 3] ⋅ x + y   # "⋅" can be typed by \cdot<tab>
f([3, 4, 5], 2)   # uses vector as first parameter
f.(Ref([3, 4, 5]), [2, 3])   # broadcasting over 2nd parameter, fixing first
