using StaticOptim
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

# All of these tests are from OptimTestProblems.jl

using StaticArrays
sx = @SVector ones(2)
sx = 3.2 * sx
rosenbrock(x) =  (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
res = soptimize(rosenbrock, sx)
@test res.g_converged == true
@test rosenbrock(res.minimizer) == res.minimum
@test show(res) === nothing

res = soptimize(rosenbrock, sx, StaticOptim.Order3())
@test res.g_converged == true
@test rosenbrock(res.minimizer) == res.minimum

res = soptimize(rosenbrock, sx/2)
@test res.g_converged == true
@test rosenbrock(res.minimizer) == res.minimum


function fletcher_powell(x::AbstractVector)
    function theta(x::AbstractVector)
        if x[1] > 0
            return atan(x[2] / x[1]) / (2.0 * pi)
        else
            return (pi + atan(x[2] / x[1])) / (2.0 * pi)
        end
    end

    return 100.0 * ((x[3] - 10.0 * theta(x))^2 +
        (sqrt(x[1]^2 + x[2]^2) - 1.0)^2) + x[3]^2
end

sx = @SVector ones(3)
sx = 3.2 * sx
res = soptimize(fletcher_powell, sx)
@test res.g_converged == true
@test fletcher_powell(res.minimizer) == res.minimum
res = soptimize(fletcher_powell, sx/2)
@test res.g_converged == true
@test fletcher_powell(res.minimizer) == res.minimum

function himmelblau(x::AbstractVector)
    return (x[1]^2 + x[2] - 11)^2 + (x[1] + x[2]^2 - 7)^2
end
sx = @SVector ones(2)
sx = 3.2 * sx
res = soptimize(himmelblau, sx)
@test res.g_converged == true
@test himmelblau(res.minimizer) == res.minimum
res = soptimize(himmelblau, sx/2)
@test res.g_converged == true
@test himmelblau(res.minimizer) == res.minimum

function powell(x::AbstractVector)
    return (x[1] + 10.0 * x[2])^2 + 5.0 * (x[3] - x[4])^2 +
        (x[2] - 2.0 * x[3])^4 + 10.0 * (x[1] - x[4])^4
end
sx = @SVector ones(4)
sx = 3.2 * sx
res = soptimize(powell, sx)
@test res.g_converged == true
@test powell(res.minimizer) == res.minimum
res = soptimize(powell, sx/2)
@test res.g_converged == true
@test powell(res.minimizer) == res.minimum


### Univariate tests

f(x) = x^2 + 2*x
res = soptimize(f, 1.)
@test res.g_converged == true
@test f(res.minimizer) == res.minimum

function U(x)
    x = max(0., x)
    log(x)
end
f(h) = -(U(0.2 + h) + U(1 - h))
res = soptimize(f, 0.9)
@test res.g_converged == true
@test f(res.minimizer) == res.minimum

### Root finding
up(c) = c <= 0 ? Inf*c : 1/c
f(a) = up(2 - a) - .96up(2 + a)
out = sroot(f, 0.5)
@test out.fx < 1e-8
@test f(out.x) == out.fx

out = sroot(f, (-0.5, 0.5))
@test  out.isroot == true
@test f(out.x) == out.fx
