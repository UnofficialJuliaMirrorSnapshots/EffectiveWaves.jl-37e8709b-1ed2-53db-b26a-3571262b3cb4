"A type for matched waves."
mutable struct MatchWave{T<:AbstractFloat}
    effective_waves::Vector{EffectiveWave{T}}
    average_wave::AverageWave{T}
    x_match::Vector{T} # waves are matched between average_wave.x_match
end

"Calculates the difference between the match of MatchWave.effective_waves and MatchWave.average_wave. This can be used as a proxi for convergence. "
function match_error(m_wave::MatchWave{T}; apply_norm::Function=norm) where T<:AbstractFloat
    avg_eff = AverageWave(m_wave.x_match, m_wave.effective_waves)
    j0 = findmin(abs.(m_wave.average_wave.x .- m_wave.x_match[1]))[2]
    len = length(m_wave.x_match)

    return apply_norm(m_wave.average_wave.amplitudes[j0:end,:,:][:] - avg_eff.amplitudes[:])/len
end

function MatchWave(ω::T, medium::Medium{T}, specie::Specie{T};
        radius_multiplier::T = 1.005,
        tol::T = T(1e-5), θin::T = zero(T),
        max_size::Int = 200,
        wave_effs::Vector{EffectiveWave{T}} = [zero(EffectiveWave{T})],
        x::AbstractVector{T} = [-one(T)],
        L_match::Int = 0,
        kws...
    ) where T<:Number

    k = real(ω/medium.c)

    if maximum(abs(w.k_eff) for w in wave_effs) == zero(T)
        wave_effs = effective_waves(k, medium, [specie];
            radius_multiplier=radius_multiplier,
            extinction_rescale = false,
            tol = T(10)*tol, θin=θin,
            kws...)
    end
    hankel_order = wave_effs[1].hankel_order
    # use non-dimensional effective waves
    wave_non_effs = deepcopy(wave_effs)
    # wave_effs = deepcopy(wave_effs) # uncomment to use wave_effs need to forget its pointers
    for w in wave_non_effs
       w.k_eff = w.k_eff/k
    end

    a12k = T(2)*radius_multiplier*specie.r*k
    if first(x) == - one(T)
        # using non-dimensional wave_non_effs and a12k results in non-dimensional mesh X
        L_match, X =  x_mesh_match(wave_non_effs; a12 = a12k, tol = tol, max_size=max_size)
    else
        X = x.*k
        if L_match == 0
            L_match = Int(round(length(X)/2))
        end
    end

    avg_wave_effs = [AverageWave(X[L_match:L_match+1], w) for w in wave_non_effs]
    for i in eachindex(wave_non_effs)
        wave_non_effs[i].amplitudes = wave_non_effs[i].amplitudes / norm(avg_wave_effs[i].amplitudes[1,:,1])
    end


    J = length(collect(X)) - 1
    len = (J + 1)  * (2hankel_order + 1)

    (MM_quad,b_mat) = average_wave_system(ω, X, medium, specie; tol=tol,
        radius_multiplier=radius_multiplier, hankel_order=hankel_order, θin=θin,  kws...);
    MM_mat = reshape(MM_quad, (len, len));
    b = reshape(b_mat, (len));

    (LT_mat, ER_mat, b_eff) = match_arrays(ω, wave_non_effs, L_match, X, medium, [specie]; θin=θin, a12k=a12k);

    B = b - ER_mat*b_eff
    As = (ER_mat*LT_mat + MM_mat)\B
    As_mat = reshape(As, (J+1, 2hankel_order+1, 1))

    αs = LT_mat*As + b_eff
    # use these αs to correct the magnitude of the amplitudes of the effective waves
    # and re-dimensionalise the effective wavenumbers
    for i in eachindex(wave_effs)
        wave_non_effs[i].amplitudes = αs[i] .* wave_non_effs[i].amplitudes
        wave_non_effs[i].k_eff = k * wave_non_effs[i].k_eff
    end


    # return MatchWave(wave_effs, AverageWave(hankel_order, collect(X)./k, As_mat), collect(X[L_match:end])./k)
    return MatchWave(wave_non_effs, AverageWave(hankel_order, collect(X)./k, As_mat), collect(X[L_match:end])./k)
end

"Returns (x,L), where x[L:end] is the mesh used to match with wave_effs."
function x_mesh_match(wave_effs::Vector{EffectiveWave{T}}; kws... ) where T<:AbstractFloat
    # wave_effs[end] establishes how long X should be, while wave_effs[1] estalishes how fine the mesh should be.

   # If there is only one wave, then it doesn't make sense to extend the mesh until it decays.
   # Instead we choose, arbitrarily, a quarter of the wavelength.
   # Note, having only one wave is very unusual, but tends to happen in the very low frequency limit.
    x = (length(wave_effs) > 1) ?
        x_mesh(wave_effs[end], wave_effs[1]; kws...) :
        x_mesh(wave_effs[1]; max_x = (pi/2)/abs(cos(wave_effs[1].θ_eff)*abs(wave_effs[1].k_eff)), kws...)

    x_match = x[end]
    x_max = (length(x) < length(wave_effs)*T(1.5)) ?
         x[end] + T(1.5)*(x[2] - x[1])*length(wave_effs) :
         T(2) * x[end]

    x = 0.0:(x[2] - x[1]):x_max

    L = findmin(abs.(x .- x_match))[2]

    return L, x
end
