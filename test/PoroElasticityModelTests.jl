@testset "PoroElasticityModel" begin
    # Test if model with correct dimensions is returned
    for n in [320, 980, 1805]
        E, J, R, B = poro_elasticity_model(n = n)
        @test size(E) == (n, n)
        @test size(J) == (n, n)
        @test size(R) == (n, n)
        @test size(B) == (n, 1)
    end

    # Test if values are correct (n=980)
    # Compared to code from
    # https://zenodo.org/record/4632901#.YsrzZOxBwUF
    begin
        H1 = 5.4533e-05 - 3.1988e-06im
        s1 = 0.1im
        H2 = 4.0487e-05 - 2.3366e-05im
        s2 = 1.0im
        E, J, R, B = poro_elasticity_model(n = 980)
        H(s) = B' * ((s * E - (J - R)) \ B)
        @test norm(H(s1) - [H1][:, :]) < 1e-9
        @test norm(H(s2) - [H2][:, :]) < 1e-9
    end
end
