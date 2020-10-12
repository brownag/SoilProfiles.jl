using DataFrames, SoilProfiles, Test
s = DataFrame(pid = 1:6, elev = 100:105)
l = DataFrame(pid = [1,1,1,1,1,2,2,2,2,2,3,3,3,3,3],
              top = [0,10,20,30,40,0,5,10,15,20,0,20,40,60,80],
              bot = [10,20,30,40,50,5,10,15,20,25,20,40,60,80,100])
spc = SoilProfileCollection("pid", s, l)

@testset "Constructors" begin
    @test length(spc) == 6
    @test length(SoilProfileCollection()) == 0
    show(spc)
end

@testset "Extraction" begin
    res = extract(spc, 2:6, 2:4)
    @test length(res) == 5
    @test nrow(res) == 6
end

@testset "Integrity" begin
    @test isValid(spc) == true
    @test sitesWithoutLayers(spc) == [4,5,6]
end
