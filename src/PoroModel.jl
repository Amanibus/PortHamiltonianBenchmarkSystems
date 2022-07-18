using MAT
using LazyArtifacts

"""
    poro_elasticity_model(; n = 980, rho = 1e-3, alpha = 0.79, M = 1/7.80e3, kappanu = 633.33, eta = 1e-4)

This function returns a port-Hamiltonian model of linear poroelasticity in a
bounded Lipschitz domain as described in
    Altmann, Mehrmann, Unger: Port-Hamiltonian Formulations of Poroelastic
    Network Models
# Arguments
- `n`: System dimension (can only be either: 320, 980, or 1805). Default = 980.
- `rho`: density. Default = `1e-3`.
- `alpha`: Biot-Willis fluid-solid coupling coefficient. Default = 0.79.
- `bm`: Biot-Modulus. Default = `1/7.8e3`.
- `kappanu`: Quotient `kappa/Nu`, where `kappa` denotes the permeability and `nu` denotes the fluid viscosity. Default = 633.33.
- `eta`: artificial damping coefficient. Default = `1e-4`.
# Outputs
- ``E, J, R, B``, matrices to construct the transfer function ``H(s) = B^\\mathsf{T}(sE-(J-R))^{-1}B)``
"""
function poro_elasticity_model(;
    n = 980,
    rho = 1e-3,
    alpha = 0.79,
    bm = 1 / 7.80e3,
    kappanu = 633.33,
    eta = 1e-4,
)
    @assert n in [320, 980, 1805] "n must be one of 320, 980, or 1805"
    Y, D, M, K, Bp, Bf, A = load_poro_raw_data(n = n)
    Y = rho * sparse(Y)
    D = alpha * sparse(D)
    M = 1 / bm .* sparse(M)
    K = kappanu * sparse(K)
    A = sparse(A)
    Bp = Bp'
    Bf = Bf'
    n = size(A, 1)
    m = size(M, 1)
    E = [Y spzeros(n, n + m); spzeros(n, n) A spzeros(n, m); spzeros(m, n + n) M]
    J = [spzeros(n, n) -A D'; A spzeros(n, n + m); -D spzeros(m, n + m)]
    R = [spzeros(n, 2 * n + m); spzeros(n, 2 * n + m); spzeros(m, 2 * n) K] + eta * I
    B = [zeros(n, 1); Bf; Bp]
    return (E = E, J = J, R = R, B = B)
end

function load_poro_raw_data(; n = 980, force_download = false)
    poro_data = artifact"ph-poromodelsbasedata"
    matfile = joinpath(poro_data, "PH-PoroModelsBaseData/poro-n$n.mat")
    dd = matread(matfile)
    return dd["Y"], dd["D"], dd["M"], dd["K"], dd["Bp"], dd["Bf"], dd["A"]
end

export poro_elasticity_model
