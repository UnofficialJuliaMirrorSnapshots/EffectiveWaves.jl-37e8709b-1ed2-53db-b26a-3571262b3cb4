# Effective waves are related to the ansatz u ~ amps.*exp(im*k_eff*x), where k_eff is the effective wavenumber with Im(k_eff) > 0.

export far_field_pattern, pair_field_pattern, diff_far_field_pattern

export wavenumbers_path, wavenumbers_mesh, reduce_kvecs

export wavenumber_challis, one_species_low_wavenumber,
        two_species_approx_wavenumber

export gray_square!, gray_square

export reflection_coefficient_low_volfrac, wavenumber_low_volfrac, wavenumber_very_low_volfrac

export wienerhopf_reflection_coefficient, wienerhopf_wavevectors

include("far_fields.jl")

include("effective_waves.jl")
include("effective_wavevectors.jl")
include("reflection_effective.jl")
include("wavenumber_effective.jl")
include("wavenumber_path.jl")
include("wavenumber_mesh.jl")
include("utils.jl")

include("low_frequency.jl")
include("low_volfrac.jl")
include("alternative_wavenumbers.jl")
include("two_species_approximate.jl")
