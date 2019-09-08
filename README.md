[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://arturgower.github.io/EffectiveWaves.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://arturgower.github.io/EffectiveWaves.jl/dev)
[![Build Status](https://travis-ci.org/arturgower/EffectiveWaves.jl.svg?branch=master)](https://travis-ci.org/arturgower/EffectiveWaves.jl)
[![Coverage Status](https://coveralls.io/repos/github/arturgower/EffectiveWaves.jl/badge.svg?branch=master)](https://coveralls.io/github/arturgower/EffectiveWaves.jl?branch=master)
[![codecov.io](http://codecov.io/github/arturgower/EffectiveWaves.jl/coverage.svg?branch=master)](http://codecov.io/github/arturgower/EffectiveWaves.jl?branch=master)

# Multi-species effective waves

A Julia package for calculating, processing and plotting waves travelling in heterogeneous materials. The focus is on calculating the ensemble averaged waves, i.e. the statistical moments, of the waves.
You can run Julia on [JuliaBox](https://www.juliabox.com/) in your browser without installation.

At present, the packages calculates effective wavenumbers, wave transimission and wave reflection from random particulate materials in two-dimensions, see [arXiv preprint](https://arxiv.org/abs/1712.05427) for details on the mathematics, or [these notes](docs/src/theory/WavesInMultiSpecies.pdf) for the formulas.

## Get started
Type into Julia:
```julia
using Pkg
Pkg.clone("https://github.com/arturgower/EffectiveWaves.jl.git")

using EffectiveWaves
```

## Simple example
Effective wavenumbers for two species randomly (uniformly) distributed in Glycerol.
```julia
#where: ρ = density, r = radius, c = wavespeed, and volfrac = volume fraction

const WaterDistilled= Medium(ρ=0.998*1000, c = 1496.0)
const Glycerol      = Medium(ρ=1.26*1000,  c = 1904.0)

species = [
    Specie(ρ=WaterDistilled.ρ,r=30.e-6, c=WaterDistilled.c, volfrac=0.1),
    Specie(ρ=Inf, r=100.0e-6, c=2.0, volfrac=0.2)
]
# background medium
background = Glycerol
```

Calculate effective wavenumbers:
```julia

# angular frequencies
ωs = LinRange(0.01,1.0,60)*30.0e6
wavenumbers = wavenumber_low_volfrac(ωs, background, species)

speeds = ωs./real(wavenumbers)
attenuations = imag(wavenumbers)
```
For a list of possible materials go to [src/materials.jl](src/materials.jl).

## More examples
For more examples and details go to [docs/src/examples/](docs/src/examples/).

## Acknowledgements and contributing
This library was originally written by [Artur L Gower](https://arturgower.github.io/).
Please contribute, if nothing else, criticism is welcome, as I am relatively new to Julia.

## References
[[1]](http://rspa.royalsocietypublishing.org/content/474/2212/20170864) Gower AL, Smith MJ, Parnell WJ, Abrahams ID. Reflection from a multi-species material and its transmitted effective wavenumber. Proc. R. Soc. A. 2018 Apr 1;474(2212):20170864.

[[2]](https://arxiv.org/abs/1712.05427) Gower AL, Smith MJ, Parnell WJ, Abrahams ID. Reflection from a multi-species material and its transmitted effective wavenumber. arXiv preprint arXiv:1712.05427. 2017 Dec.
