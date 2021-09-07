# SoilProfiles.jl

[![tests](https://github.com/brownag/SoilProfiles.jl/actions/workflows/test.yml/badge.svg)](https://github.com/brownag/SoilProfiles.jl/actions/workflows/test.yml)
[![codecov](https://codecov.io/github/brownag/SoilProfiles.jl/branch/main/graphs/badge.svg)](https://codecov.io/github/brownag/SoilProfiles.jl)

_SoilProfiles.jl_ is a [Julia](http://julialang.org) package for representing soil profile information using the "site-layer" model. Soil profiles are essentially cross sections where distinct "layers" are defined by a top and bottom depth for a point, line or area on the land surface.

 There is generally a many:one relationship between layers observed within a soil profile and the site-level information that identifies or summarizes that profile. The _SoilProfile_ object allows for simultaneous indexing and operations on paired or pooled site and layer data.

The _SoilProfile_ object in _SoilProfiles.jl_ conceptually mirrors the _SoilProfileCollection_ object defined by the [aqp](http://github.com/ncss-tech/aqp) **R** package. In Julia, we are using the _DataFrames.jl_ package instead of **R** _data.frame_ objects.

```julia
using SoilProfiles
using DataFrames

# 6 sites with 3 profiles of layer data
s = DataFrame(pid = 1:6, elev = 100:105)
l = DataFrame(pid = [1,1,1,1,1,2,2,2,2,2,3,3,3,3,3],
              top = [0,10,20,30,40,0,5,10,15,20,0,20,40,60,80],
              bot = [10,20,30,40,50,5,10,15,20,25,20,40,60,80,100])

# Construct a SoilProfile from DataFrames
#  Must specify:
#  - unique profile ID
#  - top and bottom depth column names in layer DataFrame
#  - site DataFrame and layer DataFrame

sp1 = SoilProfile("pid", ["top", "bot"], s, l)

# equivalent syntax
# when ID specified as argument
sp2 = SoilProfile("pid", s, l)
# or when ID as first column in site data
sp3 = SoilProfile(s, l)

show(sp1)

# empty SoilProfile
show(SoilProfile())

# site and layer extraction
res = spc[2:6, 2:4]
show(res)

# view the layer depths
depths(res)

# all layers have a site
println(isValid(res))

# but not all sites have layers [4,5,6]
println(sitesWithoutLayers(res))

# check that site and layer order are in sync
checkIntegrity(res)

# check that layers in top depth order have bottom depths matching adjacent top depths
checkTopology(res)

show(spc[1,1])

# iterate using for i in SoilProfile
for i in sp1
 show(i)
end

# or use foreach(::Function, ::SoilProfile)
foreach(show, sp1)
```
