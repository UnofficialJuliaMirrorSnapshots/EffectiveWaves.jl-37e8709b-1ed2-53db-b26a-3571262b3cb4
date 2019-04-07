using EffectiveWaves, Test

# This case is numerically challenging, because wavenumber() has many roots close together. Make sure spacing in ωs is small to help the optimisation method
@testset "strong scatterers and low frequency" begin
    medium = Medium(ρ=1.0, c=1.0)
    species = [
        Specie(ρ=5.,r=0.004, c=0.002, volfrac=0.2),
        Specie(ρ=0.3, r=0.002, c=0.01, volfrac=0.1)
    ]
    tol=1e-7
    # ωs = [0.001,0.003]
    ωs = [0.001]
    eff_medium = effective_medium(medium, species)
    k_eff_lows = ωs./eff_medium.c

    k_eff_φs = wavenumber_low_volfrac(ωs, medium, species)
    # num_wavenumbers =1 almost always finds the wavenubmer with the smallest attenuation

    k_effs_arr = [
        wavenumbers(ω, medium, species; tol=tol, num_wavenumbers=1)
    for ω in ωs]

    inds = [argmin(abs.(k_effs_arr[i] .- k_eff_φs[i])) for i in eachindex(ωs)]
    k_effs2 = [k_effs_arr[i][inds[i]] for i in eachindex(inds)]

    @test norm(k_effs2 - k_eff_lows)/norm(k_effs2) < 5e-7
    @test norm(k_effs2[1] - k_eff_lows[1])/norm(k_eff_lows[1]) < 5e-7
    @test norm(k_effs2 - k_eff_φs)/norm(k_effs2) < 0.01
end
