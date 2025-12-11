import numpy as np
from scipy.optimize import fsolve

def static_block(M, T, tau, L, alpha=0.5, theta=4.0, eta=1.5):
    """
    Solve the static block of the dynamic trade model for N=2 countries.
    Returns wages, prices, and trade shares for arbitrary parameters.
    """

    N = 2
    M, T, L = np.array(M, dtype=float), np.array(T, dtype=float), np.array(L, dtype=float)
    tau = np.array(tau, dtype=float)

    # === Nested helper: given log wages, compute equilibrium residuals ===
    def equilibrium_system(logw):
        w = np.exp(logw)
        
        # --- Step 1. compute intermediate good prices PM_s
        PM = np.ones(N)
        for _ in range(50):
            pM = np.zeros((N, N))
            for k in range(N):
                for d in range(N):
                    # Use wage and technology, not PM[k]
                    pM[k, d] = tau[k, d] * w[k] / (T[k]**(1/theta))
            PM_new = np.array([
                (np.sum(M * (pM[:, d])**(1 - eta)))**(1 / (1 - eta))
                for d in range(N)
            ])
            if np.max(np.abs(PM_new - PM)) < 1e-8:
                break
            PM = 0.5 * PM + 0.5 * PM_new

        # Step 2. Final-good trade shares λ^F_sd
        numer = np.zeros((N, N))
        for s in range(N):
            for d in range(N):
                numer[s, d] = T[s] * (PM[s]**(-theta * alpha)) \
                              * (w[s]**(-theta * (1 - alpha))) * tau[s, d]**(-theta)
        denom = numer.sum(axis=0, keepdims=True)
        lambdaF = numer / denom
        
        # Step 3. Goods-market clearing (income consistency)
        Y = w * L  # domestic income
        Y_new = np.zeros(N)
        for s in range(N):
            Y_new[s] = np.sum(lambdaF[s, :] * Y)  # income from all markets
        
        res = np.log(Y_new / Y)
        return res

    # === Step 2. Solve for wages (normalize w_0 = 1) ===
    def reduced_system(logw1_array):
        # fsolve always passes arrays, even if length 1
        logw1 = float(logw1_array[0])
        logw = np.array([0.0, logw1])
        res = equilibrium_system(logw)
        return np.array([res[1]])  # must return array, not scalar

    sol = fsolve(reduced_system, x0=[0.0])
    w = np.array([1.0, np.exp(sol[0])])

    # === Step 3. Recompute all equilibrium variables at solution ===
    PM = np.ones(N)
    for _ in range(100):
        pM = np.zeros((N, N))
        for k in range(N):
            for d in range(N):
                # use wages and technology as in equilibrium_system
                pM[k, d] = tau[k, d] * w[k] / (T[k]**(1.0 / theta))
        PM_new = np.array([
            (np.sum(M * (pM[:, d])**(1 - eta)))**(1.0 / (1 - eta))
            for d in range(N)
        ])
        if np.max(np.abs(PM_new - PM)) < 1e-10:
            break
        PM = 0.5 * PM + 0.5 * PM_new

    numer = np.zeros((N, N))
    for s in range(N):
        for d in range(N):
            numer[s, d] = T[s] * (PM[s]**(-theta * alpha)) \
                          * (w[s]**(-theta * (1 - alpha))) * tau[s, d]**(-theta)
    denom = numer.sum(axis=0, keepdims=True)
    lambdaF = numer / denom

    Y = w * L
    P = np.ones(N)
    for d in range(N):
        P[d] = np.sum(lambdaF[:, d] * (w * L))
    P /= P[0]  # normalize P1 = 1

    return dict(w=w, P=P, PM=PM, lambdaF=lambdaF, Y=Y)



M = [1.0, 0.8]
T = [1.0, 0.9]
tau = [[1.0, 1.2],
       [1.2, 1.0]]
L = [1.0, 0.8]

res = static_block(M, T, tau, L)
for k, v in res.items():
    print(f"{k}:\n{v}\n")

