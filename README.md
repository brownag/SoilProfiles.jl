# SoilProfiles.jl

_SoilProfiles.jl_ is a [Julia](http://julialang.org) package for representing soil profile information using the "site-layer" model. Soil profiles are essentially cross sections where distinct "layers" are defined by a top and bottom depth for a point, line or area on the land surface.

 There is a possible many:one relationship between layers observed within a soil profile and the site-level information that identifies or summarizes that profile. The _SoilProfileCollection_ object allows for simultaneous indexing and operations on paired or pooled site and layer data.

The _SoilProfileCollection_ object in _SoilProfiles.jl_ mirrors the object defined by the [aqp](http://github.com/ncss-tech/aqp) **R** package, using the _DataFrames.jl_ package in the place of **R** _data.frame_ objects.

```
using SoilProfiles
using DataFrames

# 6 sites with 3 profiles of layer data
s = DataFrame(pid = 1:6, elev = 100:105)
l = DataFrame(pid = [1,1,1,1,1,2,2,2,2,2,3,3,3,3,3],
              top = [0,10,20,30,40,0,5,10,15,20,0,20,40,60,80],
              bot = [10,20,30,40,50,5,10,15,20,25,20,40,60,80,100])

# construct a SoilProfileCollection from DataFrames
spc = SoilProfileCollection("pid", s, l)
show(spc)

# empty SPC
show(SoilProfileCollection())

# site (2-6) and layer (2-4) extraction
res = extract(spc, 2:6, 2:4)
show(res)

# all layers have a site
println(isValid(res))

# but not all sites have layers [4,5,6]
println(sitesWithoutLayers(res))
```
