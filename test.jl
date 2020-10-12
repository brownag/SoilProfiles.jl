using SoilProfiles
using DataFrames

s = DataFrame(pid = 1:6, elev = 100:105)
l = DataFrame(pid = [1,1,1,1,1,2,2,2,2,2,3,3,3,3,3],
              top = [0,10,20,30,40,0,5,10,15,20,0,20,40,60,80],
              bot = [10,20,30,40,50,5,10,15,20,25,20,40,60,80,100])

spc = SoilProfileCollection("pid", s, l)
show(spc)

# empty SPC
show(SoilProfileCollection())

# site and layer extraction
res = extract(spc, 2:6, 2:4)
show(res)

# all layers have a site
println(isValid(res))

# but not all sites have layers [4,5,6]
println(sitesWithoutLayers(res))
