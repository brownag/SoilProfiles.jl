using DataFrames

# define SoilProfileCollection type
mutable struct SoilProfileCollection
    site::DataFrame
    layer::DataFrame
end

# site and layer accessor methods
site(p::SoilProfileCollection) = p.site
layer(p::SoilProfileCollection) = p.layer

# show method
Base.show(io::IO, p::SoilProfileCollection) = print(io, "Site data:\n", p.site, "\n---\nLayer data:\n", p.layer)
