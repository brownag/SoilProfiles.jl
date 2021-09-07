module SoilProfiles

    greet() = print("SoilProfiles v0.2.1\n")

    using DataFrames
    import Base.show, Base.length, Base.size, Base.iterate,
           Base.getindex, Base.firstindex, Base.lastindex,
           Base.eltype, Base.isempty, Base.indexin,
           DataFrames.nrow, DataFrames.groupby, DataFrames.combine

    # define SoilProfile type
    mutable struct SoilProfile
        pidname::String
        depthnames::Vector{String}
        site::DataFrame
        layer::DataFrame
    end

    # empty constructor
    SoilProfile() = SoilProfile("pid", ["top", "bot"],
                                DataFrame(pid = Int64[]),
                                DataFrame(pid = Int64[],
                                          top = Int64[], bot = Int64[]))

    # 0.1.x: backward compatibility: first two non-ID columns in layers become top/bottom
    SoilProfile(pid::String,
                sites::DataFrame,
                layers::DataFrame) = SoilProfile(pid,
                                                 names(layers)[findall(names(layers) .!= pid)],
                                                 sites, layers)

    # 0.2.1+: even simpler: site id first in first column, first two non-ID columns in layers become top/bottom
    SoilProfile(sites::DataFrame,
                layers::DataFrame) =  SoilProfile(names(sites)[1],
                                                  names(layers)[findall(names(layers) .!= names(sites)[1])],
                                                  sites, layers)
    # site and layer accessor methods
    site(p::SoilProfile) = p.site
    layer(p::SoilProfile) = p.layer

    # profile ID name and profile ID vector accessors
    pidname(p::SoilProfile) = p.pidname
    profile_id(p::SoilProfile) = p.site[!, p.pidname]

    # layer depth name accessors
    depthnames(p::SoilProfile) = p.depthnames
    depths(p::SoilProfile) = p.layer[!,depthnames(p)]

    # basic AbstractArray and DataFrame-like methods
    length(p::SoilProfile) = nrow(p.site)
    nrow(p::SoilProfile) = nrow(p.layer)

    # show method
    show(io::IO, p::SoilProfile) =
        print(io, "Profile ID: ", p.pidname,
                  "; # of Profiles: ", nrow(p.site),
                  "\n--- Site data ---\n", p.site,
                  "\n--- Layer data ---\n", p.layer,"\n")

    # extraction and iteration methods
    function getindex(p::SoilProfile, i)
        pid = pidname(p)
        lyr = layer(p)
        sitesub = DataFrame(site(p)[i, :])
        jj = in.(lyr[!,pid], Ref(sitesub[!,pid]))
        SoilProfile(pid, depthnames(p), sitesub, lyr[jj, :])
    end

    function getindex(p::SoilProfile, i, j)
        pid = pidname(p)
        lyr = layer(p)
        sitesub = DataFrame(site(p)[i, :])
        jj = in.(lyr[!, pid], Ref(sitesub[!, pid]))
        gdf = combine(groupby(lyr[jj, :], pid)) do ldf
            ldf[in.(1:nrow(ldf), Ref(j)), :]
        end
        SoilProfile(pid, depthnames(p), sitesub, gdf)
    end

    firstindex(p::SoilProfile) = 1
    lastindex(p::SoilProfile) = length(p)

    function iterate(p::SoilProfile, i = 1)
        (length(p) < i ? nothing : (p[i], i + 1))
    end

    eltype(::Type{SoilProfile}) = typeof(SoilProfile())
    isempty(v::SoilProfile) = (length(v) == 0)

    # validity method (all layers must have a site)
    function isValid(p::SoilProfile)
        pid = pidname(p)
        sum(.!in.(p.layer[!, pid], Ref(p.site[!, pid]))) == 0
    end

    # sites without layers are possible
    function sitesWithoutLayers(p::SoilProfile)
        pid = pidname(p)
        sit = site(p)
        ii = .!in.(sit[!, pid], Ref(layer(p)[!, pid]))
        DataFrame(sit[ii,:])[!, pid]
    end

    # integrity method (site order matches layer order (for sites with layers))
    function checkIntegrity(p::SoilProfile)
        lspc = unique(layer(p)[:, pidname(p)])
        sspc = unique(site(p)[:, pidname(p)])
        indexin(lspc, sspc) == 1:length(lspc)
    end

    # topology method (no overlaps or gaps when top-depth sorted)
    function checkTopology(p::SoilProfile)
        combine(groupby(layer(p), pidname(p)), depthnames(p) => ((top, bottom) -> (bottom[1:(length(bottom) - 1)] == top[2:(length(top))])) => "check")
    end

    # re-order sites (force layer order to match [new] site order)
    function reorder(p::SoilProfile)
        p.site = sort!(p.site, order(pidname(p)))
        p.layer = sort!(p.layer, [order(pidname(p)), order(depthnames(p)[1])])
        p
    end

    export SoilProfile, site, layer, pidname, profile_id,
           length, nrow, getindex, isValid, sitesWithoutLayers,
           depths, depthnames, checkIntegrity, checkTopology, reorder

end # module
