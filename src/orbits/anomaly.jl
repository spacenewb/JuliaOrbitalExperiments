export Anomaly, TA, MA, EA, HA, PA
export convert_anomaly
export NewtonRaphson


abstract type Anomaly{T<:Real} end

struct TA{T} <: Anomaly{T}
    θ::T
end
struct EA{T} <: Anomaly{T}
    θ::T
end
struct MA{T} <: Anomaly{T}
    θ::T
end
struct HA{T} <: Anomaly{T}
    θ::T
end
struct PA{T} <: Anomaly{T}
    θ::T
end

function convert_anomaly(A::Anomaly, e::Real, Typ)
    if (Typ<:TA) || (Typ<:EA) || (Typ<:MA) || (Typ<:HA) || (Typ<:PA)
        if typeof(A) <: Anomaly
            (Typ<:TA) ? op = anomaly_toT(A, e) : nothing;
            (Typ<:EA) ? op = anomaly_toE(A, e) : nothing;
            (Typ<:MA) ? op = anomaly_toM(A, e) : nothing;
            (Typ<:HA) ? op = anomaly_toH(A, e) : nothing;
            (Typ<:PA) ? op = anomaly_toP(A, e) : nothing;
            return op
        else
            @warn("Input not of type <Anomaly>")
            return nothing
        end
    else
        @warn("Output not of type <Anomaly>")
        return nothing
    end
end

function NewtonRaphson(f, fp, x0, tol=1e-8, maxIter = 1000)
    x = x0
    fx = f(x0)
    iter = 0
    while abs(fx) > tol && iter < maxIter
        x = x  - fx/fp(x)   # Iteration
        fx = f(x)           # Precompute f(x)
        iter += 1
    end
    return x
end

NewtonRaphson(f, x0, tol=1e-8, maxIter=1e3) = NewtonRaphson(f, autodiff(f), x0, tol, maxIter)

# General
anomaly_toT(A::TA, e) = A
anomaly_toE(A::EA, e) = A
anomaly_toM(A::MA, e) = A
anomaly_toH(A::HA, e) = A
anomaly_toP(A::PA, e) = A

# Convert to True Anomaly
function anomaly_toT(A::EA, e)
    E = A.θ
    β = e / (1 + (1 - e^2)^0.5)
    return TA((E + 2*atan(β*sin(E), (1 - β*cos(E)))))
end
function anomaly_toT(A::MA, e)
    M = A.θ
    return TA(EtoT(MtoE(M, e), e))
end
function anomaly_toT(A::HA, e)
    H = A.θ
    return TA((2*atan(tanh(H/2.0), ((e-1)/(e+1))^0.5)))
end
function anomaly_toT(A::PA, e)
    D = A.θ
    return TA((2*atan(D)))
end

# Convert to Mean Anomaly
function anomaly_toM(A::TA, e)
    T = A.θ
    return MA(EtoM(TtoE(T, e), e))
end
function anomaly_toM(A::EA, e)
    E = A.θ
    return MA((E - e*sin(E)))
end
function anomaly_toM(A::HA, e)
    H = A.θ
    return MA((e*sinh(H) - H))
end
function anomaly_toM(A::PA, e)
    D = A.θ
    return MA(anomaly_toM(anomaly_toT(D, e), e))
end

# Convert to Eccentric Anomaly
function anomaly_toE(A::TA, e)
    T = A.θ
    a = ((1+e)/(1-e))^(-0.5)
    return EA((2*atan(a*tan(T/2.0))))
end
function anomaly_toE(A::MA, e)
    M = A.θ
    fn(E) = (E - e*sin(E) - M)
    return EA(NewtonRaphson(fn, 0.0))
end
function anomaly_toE(A::HA, e)
    H = A.θ
    return EA(anomaly_toE(anomaly_toT(H, e), e))
end
function anomaly_toE(A::PA, e)
    D = A.θ
    return EA(anomaly_toE(anomaly_toT(D, e), e))
end

# Convert to Hyperbolic Anomaly
function anomaly_toH(A::TA, e)
    T = A.θ
    return HA((2*atanh(tan(T/2)*((e-1)/(e+1))^0.5)))
end
function anomaly_toH(A::EA, e)
    E = A.θ
    return HA(anomaly_toH(anomaly_toT(E, e), e))
end
function anomaly_toH(A::MA, e)
    M = A.θ
    fn(H) = (e*sinh(H) - H - M)
    return HA(NewtonRaphson(fn, 0.0))
end
function anomaly_toH(A::PA, e)
    D = A.θ
    return HA(anomaly_toH(anomaly_toT(D, e), e))
end

# Convert to Parabolic Anomaly
function anomaly_toD(A::TA, e)
    T = A.θ
    return PA(tan(T/2.0))
end
function anomaly_toD(A::EA, e)
    E = A.θ
    return PA(anomaly_toD(anomaly_toT(E, e), e))
end
function anomaly_toD(A::MA, e)
    M = A.θ
    return PA(anomaly_toD(anomaly_toT(M, e), e))
end
function anomaly_toD(A::HA, e)
    H = A.θ
    return PA(anomaly_toD(anomaly_toT(H, e), e))
end
