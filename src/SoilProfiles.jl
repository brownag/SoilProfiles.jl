module SoilProfiles

    greet() = print("SoilProfiles v0.1.1")

    using DataFrames
    import Base.show, Base.length, Base.size, Base.iterate,
           Base.getindex, Base.firstindex, Base.lastindex,
           Base.eltype, Base.isempty, DataFrames.nrow

    # define SoilProfile type
    mutable struct SoilProfile
        pidname::String
        site::DataFrame
        layer::DataFrame
    end

    # empty constructor
    SoilProfile() = SoilProfile("pid",
                                DataFrame(pid = Int64[]),
                                DataFrame(pid = Int64[],
                                          top = Int64[], bot = Int64[]))

    # site and layer accessor methods
    site(p::SoilProfile) = p.site
    layer(p::SoilProfile) = p.layer

    # profile ID name and profile ID vector accessors
    pidname(p::SoilProfile) = p.pidname
    profile_id(p::SoilProfile) = p.site[!, p.pidname]

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
        SoilProfile(pid, sitesub, lyr[jj, :])
    end

    function getindex(p::SoilProfile, i, j)
        pid = pidname(p)
        lyr = layer(p)
        sitesub = DataFrame(site(p)[i, :])
        jj = in.(lyr[!, pid], Ref(sitesub[!, pid]))
        gdf = combine(groupby(lyr[jj, :], pid)) do ldf
            ldf[in.(1:nrow(ldf), Ref(j)), :]
        end
        SoilProfile(pid, sitesub, gdf)
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

    # integrity method (site order matches horizon order)
    function checkIntegrity(p::SoilProfile)

    end

    # topology method (no overlaps or gaps when top-depth sorted)
    function checkTopology(p::SoilProfile)

    end

    # re-order sites (force horizon order to match [new] site order)
    function reorderSites(p::SoilProfile)

    end

    export SoilProfile, site, layer, pidname, profile_id,
           length, nrow, getindex, isValid, sitesWithoutLayers


end # module
