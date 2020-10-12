module SoilProfiles

    greet() = print("SoilProfiles v0.1.0")

    using DataFrames
    import Base.show

    # define SoilProfileCollection type
    mutable struct SoilProfileCollection
        pidname::String
        site::DataFrame
        layer::DataFrame
    end

    # empty constructor
    SoilProfileCollection() = SoilProfileCollection("pid",
                                                    DataFrame(pid = Int64[]),
                                                    DataFrame(pid = Int64[],
                                                              top = Int64[],
                                                              bot = Int64[]))
    # site and layer accessor methods
    site(p::SoilProfileCollection) = p.site
    layer(p::SoilProfileCollection) = p.layer

    # profile ID name and profile ID vector accessors
    pidname(p::SoilProfileCollection) = p.pidname
    profile_id(p::SoilProfileCollection) = p.site[!, p.pidname]

    # show method
    Base.show(io::IO, p::SoilProfileCollection) =
        print(io, "Profile ID: ", p.pidname,"; # of Profiles: ", nrow(p.site),
                  "\nSite data:\n", p.site,
                  "\n---\nLayer data:\n", p.layer,"\n")

    # extraction method
    function extract(p::SoilProfileCollection, i::Any, j::Any)
        pid = SoilProfile.pidname(p)
        lyr = SoilProfile.layer(p)
        sitesub = DataFrame(SoilProfile.site(p)[i, :])
        jj = in.(lyr[!,pid], Ref(sitesub[!,pid]))
        gdf = combine(groupby(lyr[jj,:], pid)) do ldf
            ldf[in.(1:nrow(ldf), Ref(j)), :]
        end
        SoilProfileCollection(pid, sitesub, gdf)
    end

    # validity method (all layers must have a site)
    function isValid(p::SoilProfileCollection)
        pid = SoilProfile.pidname(p)
        sid = p.site[!, pid]
        lid = p.layer[!, pid]
        for i in 1:length(lid)
            found = false
            for j in 1:length(sid)
                if lid[i] == sid[j]
                    found = true
                    break
                end
            end
            if found == false
                return false
            end
        end
        return true
    end

    # sites without layers are possible
    function sitesWithoutLayers(p::SoilProfileCollection)
        pid = SoilProfile.pidname(p)
        sit = SoilProfile.site(p)
        ii = .!in.(sit[!,pid], Ref(SoilProfile.layer(p)[!,pid]))
        DataFrame(sit[ii,:])[!,pid]
    end

    # integrity method (site order matches horizon order)
    function checkIntegrity(p::SoilProfileCollection)

    end

    # topology method (no overlaps or gaps when top-depth sorted)
    function checkTopology(p::SoilProfileCollection)

    end

    # re-order sites (force horizon order to match [new] site order)
    function reorderSites(p::SoilProfileCollection)

    end

    export SoilProfileCollection, site, layer, pidname, profile_id,
           extract, isValid


end # module
